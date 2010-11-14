class MessagesController < ApplicationController
  def index
    # This is when we send messages to user
    if relay?
      ### TODO: untested
      json = Message.new(params[:session][:parameters]).json_for_relay
      render :json => json

    # This is when we receive messages from a user
    else
      Message.new(:to => phone_number, :message => message_text).handle_incoming
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
