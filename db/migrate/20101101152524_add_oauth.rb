class AddOauth < ActiveRecord::Migration
  def self.up
    add_column :users, :active_token_id, :integer
    add_index :users, :active_token_id
    change_column :users, :crypted_password, :string, :null => true
    change_column :users, :password_salt, :string, :null => true
    add_index :users, :persistence_token
    remove_index :users, :perishable_token
    change_column :users, :email, :string, :null => true
  end

  def self.down
    change_column :users, :email, :string, :null => false
    add_index :users, :perishable_token
    remove_index :users, :persistence_token
    change_column :users, :password_salt, :string, :null => false
    change_column :users, :crypted_password, :string, :null => false
    remove_index :users, :active_token_id
    remove_column :users, :active_token_id
  end
end
