class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :kind
      t.string :actor
      t.string :subject
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
