class User < ActiveRecord::Base
  DATING_START_STRING = '5PM EDT'
  DATING_END_STRING   = '10:59PM EDT'
  DATING_START        = Time.zone.parse(DATING_START_STRING)
  DATING_END          = Time.zone.parse(DATING_END_STRING)

  attr_protected :secret_code, :phone_number
  validates_presence_of :phone_number
  validate :secret_code_matches_or_nil
  validates_presence_of :name, :looking_for_minimum_age, :looking_for_maximum_age,
    :on => :update
  validate :at_least_one_gender, :on => :update
  validate :at_least_one_desired_gender, :on => :update
  validates_presence_of :dob, :on => :update
  validate :phone_number_new, :on => :create
  validates_length_of :phone_number, :is => 11

  before_validation :secret_code, :on => :create
  before_validation :normalize_phone_number
  after_create :deliver_secret_code, :start_annoyer
  after_save :deliver_confirmation_congratulations

  has_many :founded_meetups, :class_name => 'Meetup', :foreign_key => 'first_user_id', :dependent => :destroy
  has_many :offers, :foreign_key => "offered_user_id", :dependent => :destroy
  has_many :dflns

  attr_accessor :secret_code_confirmation

  def self.without_offers
    where('users.id NOT IN (SELECT offered_user_id FROM offers WHERE offers.state = "pending" OR ((offers.state = "canceled" OR offers.state = "retryable") AND offers.created_at > ?))', 1.hour.ago)
  end

  def self.sort_by_least_offered
    select('users.*, (SELECT MAX(offers.created_at) FROM offers WHERE offers.offered_user_id = users.id GROUP BY offers.offered_user_id) as last_offer_time').
      order('IFNULL(last_offer_time,0) ASC')
  end

  def self.without_founded_meetups_in_progress
    where("users.id NOT IN (SELECT first_user_id FROM meetups WHERE meetups.state = 'proposed' OR meetups.state = 'unscheduled')")
  end

  def self.within_age_range(min, max)
    where('DATEDIFF(:today, dob) >= :min * 365 AND DATEDIFF(:today,  dob) <= :max * 365', { :today => Date.today, :min => min, :max => max })
  end

  def self.looking_for(user)
    where('(users.looking_for_male = ? OR users.looking_for_female = ? OR users.looking_for_other = ?) AND ? >= users.looking_for_minimum_age AND ? <= users.looking_for_maximum_age',
          user.male, user.female, user.other, user.age_in_years, user.age_in_years)
  end

  def self.looking_for_sort_of_like(user)
    where('(users.looking_for_male = ? OR users.looking_for_female = ? OR users.looking_for_other = ?) AND ? >= users.looking_for_minimum_age AND ? <= users.looking_for_maximum_age',
          user.male, user.female, user.other, user.age_in_years + 2, user.age_in_years - 2)

  end

  # Produce only the users who identify as at least male. Currently unused but
  # interesting from irb. TODO: Use from a stats page.
  def self.men
    where('users.male')
  end

  # Produce only the users who identify as at least female. TODO: Use from a stats page.
  def self.women
    where('users.female')
  end

  # Produce only the users who identify as at least non-male, non-female.
  # Currently unused but interesting from irb. TODO: Use from a stats page.
  def self.other
    where('users.other')
  end

  def self.looking_for_gender(meetup)
    wheres = []
    wheres << 'users.male'   if meetup.desires_male
    wheres << 'users.female' if meetup.desires_female
    wheres << 'users.other'  if meetup.desires_other
    where(wheres.join(' OR '))
  end

  def self.exclude(user)
    where('users.id <> ?', user.id)
  end

  def self.incomplete
    where('dob IS NULL')
  end

  # The secret code that the user uses to prove that they have that phone
  # number.
  def secret_code
    read_attribute(:secret_code) ||
      write_attribute(:secret_code, generate_secret_code)
  end

  # A user is confirmed if they have a name
  def confirmed?
    self.name.present?
  end

  def unconfirmed?
    ! confirmed?
  end

  def age_in_years
    ((Date.today - dob).to_f / 365.0).floor
  end

  # The person this user has as a date right now
  def date
    Meetup.for(self).scheduled.newest.first.try(:for, self)
  end

  def matching_for_meetup(meetup)
    User.
      within_age_range(self.looking_for_minimum_age, self.looking_for_maximum_age).
      looking_for(self).
      without_offers.
      without_founded_meetups_in_progress.
      looking_for_gender(meetup).
      exclude(self).
      sort_by_least_offered
  end

  def skeeze_matching_for_meetup(meetup)
    User.
      within_age_range(self.looking_for_minimum_age, self.looking_for_maximum_age).
      looking_for_sort_of_like(self).
      without_offers.
      without_founded_meetups_in_progress.
      looking_for_gender(meetup)#.
     # exclude(self).
     # sort_by_least_offered
  end

  def deliver_secret_code
    self.tell(
      "Before you can become an instalover you must know this secret code: '#{self.secret_code}'. " +
      "Visit instalover.com to finish signing up.")
  end

  def latest_offer
    offers.pending.first
  end

  def tell(msg)
    Message.new(:to => self.phone_number, :message => msg).deliver
  end

  def incomplete?
    dob.nil?
  end

  def start_annoyer
    QUEUE.enqueue_at(7.days.from_now, ProfileAnnoyer, :user_id => self.id)
  end

  def handle_incoming(text)
    case text
    when /^\s*#{COMMANDS[:new_date].gsub(' ','.*')}/i
      handle_new_date
    when /^\s*#{COMMANDS[:ok].gsub(' ','.*')}/i
      handle_ok
    when /^\s*#{COMMANDS[:skeeze].gsub(' ','.*')}/i
      handle_ok :skeeze => true
    when /^\s*#{COMMANDS[:accept].gsub(' ','.*')}/i
      handle_accept
    when /^\s*#{COMMANDS[:sext].gsub(' ','.*')}\s*(.*)/i
      handle_texting_proxy($1)
    when /^\s*#{COMMANDS[:quit].gsub(' ','.*')}/i
      handle_safeword
    when /^\s*#{COMMANDS[:retry].gsub(' ','.*')}/i
      handle_retry
    when /^\s*#{COMMANDS[:women_only].gsub(' ','.*')}/i
      handle_new_date(:desires_male => false, :desires_female => true, :desires_other => false)
    when /^\s*#{COMMANDS[:men_only].gsub(' ','.*')}/i
      handle_new_date(:desires_male => true, :desires_female => false, :desires_other => false)
    when /^\s*#{COMMANDS[:other_only].gsub(' ','.*')}/i
      handle_new_date(:desires_male => false, :desires_female => false, :desires_other => true)
    when /^\s*#{COMMANDS[:anything].gsub(' ','.*')}/i
      handle_new_date(:desires_male => true, :desires_female => true, :desires_other => true)
    else
      handle_unknown
    end
  end

  def handle_texting_proxy(message)
    if self.date
      self.date.tell("#{self.name} says: #{message}")
    else
      self.tell("You have no date for us to share that with. Reply with '#{COMMANDS[:new_date]}'.")
    end
  end

  def handle_new_date(meetup_restrictions = {})
    if within_dating_hours?
      self.founded_meetups.proposed.destroy_all

      if self.founded_meetups.unscheduled.any?
        self.tell("Whoa there, pardner - we're looking for someone right now.  If nobody shows after 5 minutes, then you can ask again.")
      else
        self.offers.cancel_all
        ### TODO: cancel all retryable meetups for this user

        meetup = Meetup.create(
          meetup_restrictions.merge(
            :first_user => self,
            :description => DateSuggestion.next_place_and_time)
        )

        self.tell("Should we find you a date at #{meetup.description}? Reply 'ok' or 'new date' to try again.")
        QUEUE.enqueue_at(5.minutes.from_now, OkTimeoutMessageDelayer, :user_id => self.id)
      end
    else
      self.outside_dating_hours
    end
  end

  def handle_retry
    if within_dating_hours?
      if meetup = self.founded_meetups.retryable.last
        meetup.unschedule!
        self.matching_for_meetup(meetup).first(5).each do |matching_user|
          Offer.create(:offered_user => matching_user, :meetup => meetup)
        end
        QUEUE.enqueue_at(5.minutes.from_now, RejectMessageDelayer, :user_id => self.id)
        self.tell("Trying to get you a date. Back in five.")
      else
        self.handle_new_date
      end
    else
      ### TODO: untested
      self.outside_dating_hours
    end
  end

  def outside_dating_hours
    self.tell("Outside of the dating hours: #{DATING_START_STRING} to #{DATING_END_STRING}. Please try again then!")
  end

  def handle_ok(meetup_restrictions = {})
    meetup = self.founded_meetups.proposed.first
    if meetup
      meetup.unschedule!
      ### TODO: move this `if' out
      if meetup_restrictions[:skeeze]
        matches = self.skeeze_matching_for_meetup(meetup).first(5)
      else
        matches = self.matching_for_meetup(meetup).first(5)
      end
      matches.each do |matching_user|
        Offer.create(:offered_user => matching_user, :meetup => meetup)
      end
      QUEUE.enqueue_at(5.minutes.from_now, RejectMessageDelayer, :user_id => self.id)
    else
      self.handle_unknown
    end
  end

  def handle_unknown
    self.tell("Sorry, I don't know what to do with that. You can text '#{COMMANDS[:new_date]}' to get a date. To stop receiving texts, please text '#{COMMANDS[:quit]}'")
  end

  def handle_accept
    if accepted_offer = self.latest_offer
      accepted_offer.accept!

      meetup = accepted_offer.meetup
      meetup.pending_offers.each do |offer|
        ### TODO: move into #decline! ?
        offer.offered_user.tell("Too slow! Would you like to get a date? Reply '#{COMMANDS[:new_date]}'.")
        offer.decline!
      end
    else
      self.tell("You don't have any date offers to accept")
    end
  end

  def deliver_date(second_user)
    self.tell(%{Nice! You've got a date with #{second_user.name}. Describe yourself using '#{COMMANDS[:sext]}' followed by a message.})
  end

  def handle_safeword
    self.tell("I got it - 'no' means no!  We could just be friends, but we're not fooling anyone.  You're unsubscribed - have a nice life!")
    self.destroy
  end

  def handle_dfln(message)
    dfln = self.dflns.unwritten.last
    dfln.update_attributes(:text => message)
  end

  def handle_no_responses
    meetup = self.founded_meetups.unscheduled.first
    if !meetup.nil?
      self.tell("We called every number in our little black book, but only got answering machines. Try again with '#{COMMANDS[:retry]}'.")
      meetup.offers.pending.each do |offer|
        ### TODO: move into #cancel! ?
        offer.offered_user.tell("Too slow! Would you like to get a date? Reply '#{COMMANDS[:new_date]}'.")
        offer.cancel!
      end
      meetup.retryable!
    end
  end

  def handle_ok_timeout
    meetup = self.founded_meetups.proposed.first
    if !meetup.nil?
      # TODO: move into Meetup#cancel! ?
      self.tell("I guess you don't want to go on a date... Text '#{COMMANDS[:new_date]}' again when you change your mind")
      meetup.state = "cancelled"
      meetup.save!
    end
  end

  protected

  def normalize_phone_number
    normalized = self.phone_number.gsub(/[^0-9]/,'')
    self.phone_number = normalized.chars.first == '1' ? normalized : "1#{normalized}"
  end

  def phone_number_new
    user = User.find_by_phone_number(self.phone_number)
    if !user.nil?
      if user.confirmed?
        user.tell("You are already a user - text '#{COMMANDS[:new_date]}' to start getting dates and '#{COMMANDS[:quit]}' to quit")
      else
        user.deliver_secret_code
      end
      errors.add(:base, "That number has already been registered! We have retexted instructions.")
    end
  end

  def at_least_one_gender
    unless (male? || female? || other?)
      errors.add(:base, "must select at least one gender")
    end
  end

  def at_least_one_desired_gender
    unless (looking_for_male? || looking_for_female? || looking_for_other?)
      errors.add(:base, "must look for at least one gender")
    end
  end

  def secret_code_matches_or_nil
    return true if self.secret_code_confirmation.nil?

    if self.secret_code.try(:downcase) != self.secret_code_confirmation.try(:downcase)
      self.errors.add(:secret_code, "doesn't match")
    end
  end

  def generate_secret_code
    codes = %w(
      bunny
      love
      date
      heart
      marry
      divorce
      regret
      tiny
      huge
      cry
      nerd
      geek
      cheat
      friend
      hurt
      lemon
      small
      tissue
      lotion
      booze
      mucus
      sleep
      breakfast
      morning
      virgin
      lonely
      shaved)
    codes[rand(codes.length)]
  end

  def just_updated_for_the_first_time?
    we_have_updated            = self.updated_at     != self.created_at
    we_had_not_updated_before  = self.updated_at_was == self.created_at

    we_have_updated && we_had_not_updated_before
  end

  def deliver_confirmation_congratulations
    if just_updated_for_the_first_time?
      self.tell("Congrats, #{self.name}, you are now an instalover.  Text '#{COMMANDS[:new_date]}' to get a new date.")
    end
  end

  ### TODO: doesn't belong here
  def within_dating_hours?
    now = Time.zone.now
    now.hour >= DATING_START.hour &&
      now.hour <= DATING_END.hour
  end
end
