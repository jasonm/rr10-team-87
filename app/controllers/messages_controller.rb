class MessagesController < ApplicationController
  def index
    # This is when we send messages to user
    if relay?
      ### TODO: untested
      json = Message.json_for_relay(params[:session][:parameters])
      render :json => json

    # This is when we receive messages from a user
    else
      Message.handle_incoming(phone_number, message_text)
      render :status => 200, :text => Message::HANGUP_RESPONSE
    end
  end

  protected

  def relay?
    params[:session].try(:[], :parameters).try(:[], :relay)
  end

  def phone_number
    params[:session].try(:[],:from).try(:[], :id)
  end

  def message_text
    params[:session].try(:[], :initialText)
  end
end
