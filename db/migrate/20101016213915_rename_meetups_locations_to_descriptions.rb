class RenameMeetupsLocationsToDescriptions < ActiveRecord::Migration
  def self.up
    rename_column :meetups, :location, :description
  end

  def self.down
    rename_column :meetups, :description, :location
  end
end
