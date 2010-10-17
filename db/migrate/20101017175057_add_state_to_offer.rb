class AddStateToOffer < ActiveRecord::Migration
  def self.up
    add_column :offers, :state, :string, :default => 'pending'
    add_index :offers, :state
  end

  def self.down
    remove_column :offers, :state
  end
end
