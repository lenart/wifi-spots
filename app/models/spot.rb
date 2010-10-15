class Spot < ActiveRecord::Base
  
  # RESERVED_PERMALINKS = %w(spot spots city cities admin login logout signup)

  include SpotImporter
  
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere  
  versioned
  
  has_friendly_id :title,
                  :use_slug => true,
                  :approximate_ascii => true #, :reserved_words => RESERVED_PERMALINKS 
  
  before_validation :geocode_address
  
  belongs_to :category
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :category
  validates_presence_of :reason, :unless => Proc.new { |spot| spot.deleted == false }
  
  validates_uniqueness_of :permalink, :allow_blank => true
  
  named_scope :recent, :order => "created_at DESC", :limit => 10, :conditions => { :deleted => false }
  named_scope :deleted, :conditions => { :deleted => true }
  named_scope :active, :conditions => { :deleted => false }
  
  named_scope :invalid, :conditions => ["lat=? AND lng=? AND deleted=false", ApplicationController::DEFAULT_LAT, ApplicationController::DEFAULT_LNG]
  
  define_index do
    indexes title
    indexes location, city
    indexes ssid, key
    indexes notes
    
    has :open, :as => 'open' # should be written like this open is reserved by ruby
    has lat, lng, deleted
    where "deleted=false"
  end
  
  def validate
    errors.add_to_base "Prosimo, da določite kje se točka nahaja! Na zemljevidu (zgoraj) postavite marker na željeno lokacijo." if self.lat == ApplicationController::DEFAULT_LAT && self.lng == ApplicationController::DEFAULT_LNG
  end
  
  def latlng
    [self.lat, self.lng]
  end
  
  def full_location
    [location, city].join(" ").strip
  end
  
  def restore
    skip_version do
      update_attributes({:deleted => false, :reason => nil})
    end
  end
  
  def delete(reason)
    skip_version do
      update_attributes({:deleted => true, :reason => reason})
    end
  end
  
  def destroy!
    self.destroy
  end
  
  
  def client_side_json
    options = {}
    options[:only] = [:id, :title, :lat, :lng, :zoom, :description]
    # options[:methods] = [:unanswered_questions, :skips_left, :question_count, :textilized_instructions]
    to_json(options)
  end
  
  

###########################
# PRIVATE
###########################
  
  private
  
    def geocode_address
      unless self.lat && self.lng
        geo = Geokit::Geocoders::MultiGeocoder.geocode(full_location)
        errors.add(:address, "Žal nismo uspeli najti podatkov o lokaciji na Google Maps. Preverite vnešene podatke.") if !geo.success
        self.lat, self.lng = geo.lat, geo.lng if geo.success
      end
    end
    
end