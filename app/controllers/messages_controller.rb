class MessagesController < ApplicationController
  def index
    #This is when we send messages to user
    if params[:session][:parameters][:relay]
      json = Message.json_for_relay(params[:session][:parameters])
      render :json => json
    #This is when we receive messags from a user
    else
      if user = User.find_by_phone_number(phone_number)
        @date = user.schedule_date_in(params[:session][:initialText])
        if @date.save
          render :json => date_response_message_for(user)
        else
          render :json => failed_to_save_date_message
        end
      else
        render :json => must_register_first_message
      end
    end
  end

  protected

  def date_response_message_for(user)
    if @date.scheduled?
      # Tell the user
      @user = user
      build_sms(render :action => 'date_complete')
      # Tell the date
      @user = @date.for(user)
      build_sms(render(:action => 'date_complete'), :to => @user.phone_number)
    else
      ### Also enqueue a follow-up 15m later
      build_sms(render :action => 'date_pending')
    end
  end

  def failed_to_save_date_message
    build_sms("Technical issue with making your date: #{@date.errors.full_messages.join(', ')}")
  end

  def must_register_first_message
    build_sms("You must register first at instalover.com")
  end

  def must_be_sms_message
    build_sms("Only phone texting is supported for now")
  end

  def phone_number
    params[:session].try(:[],:from).try(:[], :id)
  end

  def build_sms(s, opts = {})
    if opts[:to]
      Tropo::Generator.new do
        message :message => s, :to => "tel:+1#{opts[:to]}"
      end
    else
      Tropo::Generator.say(s)
    end
  end
end
