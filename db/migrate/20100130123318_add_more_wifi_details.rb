class AddMoreWifiDetails < ActiveRecord::Migration
  def self.up
    add_column :spots, :deleted, :boolean, :default => false
    add_column :spots, :url, :string
    
    add_column :spots, :open, :boolean
    add_column :spots, :ssid, :string, :limit => 50
    add_column :spots, :key, :string, :limit => 50
  end

  def self.down
    remove_column :spots, :open
    remove_column :spots, :ssid
    remove_column :spots, :key
    remove_column :spots, :deleted
    remove_column :spots, :url
  end
end
