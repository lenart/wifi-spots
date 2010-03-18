class AddGeoToItems < ActiveRecord::Migration
  def self.up
    add_column :spots, :lat, :double
    add_column :spots, :lng, :double
    add_column :spots, :zoom, :integer
    
    add_index :spots, [:lat, :lng]
  end

  def self.down
    remove_column :spots, :lat
    remove_column :spots, :lng
    remove_column :spots, :zoom
    
    remove_index :spots, [:lat, :lng]
  end
end
