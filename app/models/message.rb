class Message
  HANGUP_RESPONSE     = '{"tropo": [{"hangup": null}]}'

  attr_accessor :to, :text

  def initialize(params)
    self.to = params[:to]
    self.text = params[:message]
  end

  def deliver(deliver_in_development = false)
    if Rails.env.development? && !deliver_in_development
      raise "Tried to deliver an SMS in development without passing deliver_in_development = true."
    end

    Rails.logger.info "Enqueued SMS: TO: #{to}: #{text}"

    params = Addressable::URI.new
    params.query_values = {
      "relay" => "relay",
      "to" => self.to,
      "message" => self.text,
      "token" => MESSAGE_TOKEN,
      "action" =>"create"
    }
    param_string = params.query

    QUEUE.enqueue(MessageSender, "#{TROPO_URL}/sessions?#{param_string}")
  end

  ### TODO: untested
  def json_for_relay
    tropo = Tropo::Generator.new do
      message({
        :to => "tel:+#{self.to}",
        :channel => 'TEXT',
        :network => 'SMS'
      }) do
        say :value => self.text
      end
    end

    tropo.response
  end

  def handle_incoming
    Rails.logger.info("SMS INCOMING: FROM #{self.to}: #{self.text}")

    user = User.find_by_phone_number(self.to)

    if user.nil?
      Message.new(:to => self.to, :message => "Sorry, you must register first at instalover.com").deliver
    elsif user.unconfirmed?
      user.deliver_secret_code
    elsif user.dflns.unwritten.any?
      user.handle_dfln(text)
    else
      user.handle_incoming(self.text)
    end
  end
end
