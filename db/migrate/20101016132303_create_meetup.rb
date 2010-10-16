class CreateMeetup < ActiveRecord::Migration
  def self.up
    create_table :meetups do |t|
      t.integer :first_user_id, :second_user_id
      t.timestamp :meet_at
      t.string :location

      t.timestamps
    end

    add_index :meetups, :first_user_id
    add_index :meetups, :second_user_id
    add_index :meetups, :location
  end

  def self.down
    drop_table :meetups
  end
end
