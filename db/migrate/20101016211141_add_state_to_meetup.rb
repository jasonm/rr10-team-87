class AddStateToMeetup < ActiveRecord::Migration
  def self.up
    add_column :meetups, :state, :string
  end

  def self.down
    remove_column :meetups, :state
  end
end
