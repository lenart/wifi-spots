class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :email,                     :string, :limit => 100, :null => false
      t.column :crypted_password,          :string, :null => false
      t.column :password_salt,             :string, :limit => 40, :null => false
      
      t.string :name,     :limit => 50,  :null => false, :default => ''
      
      t.string :persistence_token, :null => false
      t.string :perishable_token, :null => false
      
      t.timestamps
    end
    
    add_index :users, :email, :unique => true
    add_index :users, :perishable_token
  end

  def self.down
    drop_table "users"
  end
end