class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.references :meetup_id
      t.references :offered_user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
