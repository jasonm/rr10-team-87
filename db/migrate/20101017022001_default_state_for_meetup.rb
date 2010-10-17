class DefaultStateForMeetup < ActiveRecord::Migration
  def self.up
    change_column_default :meetups, :state, 'proposed'
  end

  def self.down
    change_column_default :meetups, :state, ''
  end
end
