class EventsController < ApplicationController
  def index
    @events = Event.recent
  end
end
