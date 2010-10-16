class AddDateSuggestionsLastSuggestedAt < ActiveRecord::Migration
  def self.up
    add_column :date_suggestions, :last_suggested_at, :datetime
  end

  def self.down
    remove_column :date_suggestions, :last_suggested_at
  end
end
