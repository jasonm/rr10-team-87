class AgesAreNumbers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.change :looking_for_minimum_age, :integer
      t.change :looking_for_maximum_age, :integer
    end
  end

  def self.down
    change_table :users do |t|
      t.change :looking_for_minimum_age, :boolean
      t.change :looking_for_maximum_age, :boolean
    end
  end
end
