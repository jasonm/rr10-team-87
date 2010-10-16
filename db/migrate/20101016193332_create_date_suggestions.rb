class CreateDateSuggestions < ActiveRecord::Migration
  def self.up
    create_table :date_suggestions do |t|
      t.string :text
      t.timestamps
    end
  end

  def self.down
    drop_table :date_suggestions
  end
end
