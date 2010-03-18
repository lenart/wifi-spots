class CreateSpots < ActiveRecord::Migration
  def self.up
    create_table :spots do |t|
      t.string :title, :limit => 100
      t.references :category
      t.text :location, :limit => 100
      t.string :city, :limit => 50
      t.text :notes
      t.references :user
      t.timestamps
    end
    
    add_index :spots, :category_id
  end

  def self.down
    drop_table :spots
  end
end