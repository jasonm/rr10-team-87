class CreateDflns < ActiveRecord::Migration
  def self.up
    create_table :dflns do |t|
      t.string :text
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :dflns
  end
end
