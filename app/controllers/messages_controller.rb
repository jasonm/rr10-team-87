class MessagesController < ApplicationController
  before_filter :must_be_sms

  def index
    if @user = User.find_by_phone_number(phone_number)
      @date = @user.schedule_date_in(params[:session][:initialText])
      if @date.save
        render :json => date_response_message
      else
        render :json => failed_to_save_date_message
      end
    else
      render :json => must_register_first_message
    end
  end

  protected

  def must_be_sms
    network = params[:session].try(:[], :from).try(:[], :network)
    render :json => must_be_sms_message if network != 'SMS'
  end

  def date_response_message
    if @date.scheduled?
      ### Also tell the date
      send_sms(render :action => 'date_complete')
    else
      ### Also enqueue a follow-up 15m later
      send_sms(render :action => 'date_pending')
    end
  end

  def failed_to_save_date_message
    send_sms("Technical issue with making your date: #{@date.errors.full_messages.join(', ')}")
  end

  def must_register_first_message
    send_sms("You must register first at instalover.com")
  end

  def must_be_sms_message
    send_sms("Only phone texting is supported for now")
  end

  def phone_number
    params[:session].try(:[],:from).try(:[], :id)
  end

  def send_sms(s)
    Tropo::Generator.say(s)
  end
end
