class CreateSlugs < ActiveRecord::Migration
  def self.up
    create_table :slugs do |t|
      t.string :name
      t.integer :sluggable_id
      t.integer :sequence, :null => false, :default => 1
      t.string :sluggable_type, :limit => 40
      t.string :scope
      t.datetime :created_at
    end
    add_index :slugs, :sluggable_id
    add_index :slugs, [:name, :sluggable_type, :sequence, :scope], :name => "index_slugs_on_n_s_s_and_s", :unique => true
    
    add_column :spots, :cached_slug, :string
    add_column :cities, :cached_slug, :string
    
    add_index :spots, :cached_slug
    add_index :cities, :cached_slug
  end

  def self.down
    remove_index :cities, :cached_slug
    remove_index :spots, :cached_slug
    
    remove_column :cities, :cached_slug
    remove_column :spots, :cached_slug
    
    drop_table :slugs
  end
end
