# encoding: utf-8
class Spot < ActiveRecord::Base
  
  DEFAULT_LAT = 46.0620023
  DEFAULT_LNG = 14.5096064
  DEFAULT_ZOOM = 9
  
  # RESERVED_PERMALINKS = %w(spot spots city cities admin login logout signup)

  include SpotImporter
  
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere  
  versioned
  
  has_friendly_id :title,
                  :use_slug => true,
                  :approximate_ascii => true #, :reserved_words => RESERVED_PERMALINKS 
  
  after_initialize :set_defaults
  before_validation :geocode_address
  

  belongs_to :category
  belongs_to :user
  
  validates_presence_of :title
  validates_presence_of :category
  validates_presence_of :reason, :unless => Proc.new { |spot| spot.deleted == false }
  
  validates_uniqueness_of :permalink, :allow_blank => true
  
  scope :recent, :order => "created_at DESC", :limit => 10, :conditions => { :deleted => false }
  scope :deleted, :conditions => { :deleted => true }
  scope :active, :conditions => { :deleted => false }
  
  scope :invalid, :conditions => ["lat=? AND lng=? AND deleted=false", Spot::DEFAULT_LAT, Spot::DEFAULT_LNG]
  
  define_index do
    indexes title
    indexes location, city
    indexes ssid, key
    indexes notes
    
    has :open, :as => 'open' # should be written like this open is reserved by ruby

    # lat, lng should always be in radians not degrees
    has "RADIANS(lat)", :as => :latitude, :type => :float
    has "RADIANS(lng)", :as => :longitude, :type => :float

    # we don't index deleted spots
    where "deleted=false"
  end
  
  def set_defaults
    self.lat, self.lng = DEFAULT_LAT, DEFAULT_LNG
    self.zoom = DEFAULT_ZOOM
  end
  
  def validate
    errors.add_to_base "Prosimo, da določite kje se točka nahaja! Na zemljevidu (zgoraj) postavite marker na željeno lokacijo." if self.lat == Spot::DEFAULT_LAT && self.lng == Spot::DEFAULT_LNG
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
  
  def has_notes?
    not (location.blank? && city.blank? && url.blank?)
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