class ReasonForDeletion < ActiveRecord::Migration
  def self.up
    add_column :spots, :reason, :string
  end

  def self.down
    remove_column :spots, :reason
  end
end
