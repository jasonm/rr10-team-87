class AddDflnsMeetupId < ActiveRecord::Migration
  def self.up
    add_column :dflns, :meetup_id, :integer
  end

  def self.down
    remove_column :dflns, :meetup_id
  end
end
