class MessagesController < ApplicationController
  def index
    #This is when we send messages to user
    if params[:session] &&
       params[:session][:parameters] &&
       params[:session][:parameters][:relay]
      json = Message.json_for_relay(params[:session][:parameters])
      render :json => json
    #This is when we receive messags from a user
    else
      Message.handle_incoming(phone_number, message_text)
      # @date = user.schedule_date_in(params[:session][:initialText])
      # if @date.save
      #   render :json => date_response_message_for(user)
      # else
      #   render :json => failed_to_save_date_message
      # end
      render :status => 200, :text => "OK"
    end
  end

  protected

  def phone_number
    params[:session].try(:[],:from).try(:[], :id)
  end

  def message_text
    params[:session].try(:[], :initialText)
  end
end
