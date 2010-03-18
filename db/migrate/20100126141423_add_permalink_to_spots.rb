class AddPermalinkToSpots < ActiveRecord::Migration
  def self.up
    add_column :spots, :permalink, :string
  end

  def self.down
    remove_column :spots, :permalink
  end
end
