class City < ActiveRecord::Base
  
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true
  
  validates_presence_of :name
  validates_presence_of :lat, :lng
  
  default_scope :order => "name desc"
  
  def latlng
    [lat,lng]
  end
  
  def spots(options = {})
    defaults = { :within => 15 }.merge!(options)
    
    Spot.find(:all, :origin => [self.lat, self.lng], :within => defaults[:within], :order => 'distance')
  end
  
end
