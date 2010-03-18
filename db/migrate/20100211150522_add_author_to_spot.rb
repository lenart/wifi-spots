class AddAuthorToSpot < ActiveRecord::Migration
  def self.up
    add_column :spots, :author, :string
  end

  def self.down
    remove_column :spots, :author
  end
end
