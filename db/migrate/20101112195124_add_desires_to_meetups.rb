class AddDesiresToMeetups < ActiveRecord::Migration
  def self.up
    add_column :meetups, :desires_female, :boolean
    add_column :meetups, :desires_male, :boolean
    add_column :meetups, :desires_other, :boolean
  end

  def self.down
    remove_column :meetups, :desires_other
    remove_column :meetups, :desires_male
    remove_column :meetups, :desires_female
  end
end
