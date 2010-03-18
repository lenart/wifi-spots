class Category < ActiveRecord::Base
  
  has_many :spots, :dependent => :nullify
  
  validates_presence_of :name
  validates_presence_of :description

  validates_uniqueness_of :name, :case_sensitive => false
    
end
