class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :phone_number, :location, :name, :secret_code
      t.text :description
      t.boolean :male, :female, :other
      t.boolean :looking_for_male, :looking_for_female, :looking_for_other
      t.boolean :looking_for_minimum_age, :looking_for_maximum_age
      t.date :dob

      t.timestamps
    end

    add_index :users, :phone_number
    add_index :users, [:male, :female, :other, :dob]
  end

  def self.down
    drop_table :users
  end
end
