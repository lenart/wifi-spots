class Spot < ActiveRecord::Base
  
  # RESERVED_PERMALINKS = %w(spot spots city cities admin login logout signup)
  
  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere
  
  has_friendly_id :title, :use_slug => true, :approximate_ascii => true #, :reserved_words => RESERVED_PERMALINKS 
  versioned
  
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
  
  define_index do
    indexes title
    indexes location, city
    indexes ssid, key
    indexes notes
    
    has :open, :as => 'open' # should be written like this open is reserved by ruby
    has lat, lng, deleted
    where "deleted=false"
  end
  
  def latlng
    [self.lat, self.lng]
  end
  
  def full_location
    [location, city].join(" ").strip
  end  
  
  def self.import_from_rss(overwrite = false)
    require 'nokogiri'
    require 'open-uri'
    
    doc = Nokogiri::XML(open('http://maps.google.com/maps/ms?ie=UTF8&hl=en&oe=UTF8&msa=0&output=georss&msid=115530814119313728840.00047d9535ae3d1256bef'))
    # doc = Nokogiri::XML(open('lib/data/tocke.xml'))
        
    spots = doc.search('item')
    
    logger.info "Starting import of #{spots.size} items! #{Time.now}"
    puts "Starting import of #{spots.size} items! #{Time.now}"
    
    spots.each do |s|
      spot = Spot.find_or_create_by_permalink(s.at('guid').content)
      
      next if !overwrite && !spot.new_record?
      
      spot.title = s.at('title').content
      spot.permalink = s.at('guid').content
      spot.category_id = 1
      
      latlng = s.xpath('georss:point').first.content.gsub!(/\n/,'').strip!.split(' ')
      spot.lat = latlng[0]
      spot.lng = latlng[1]
      spot.zoom = 17
      
      spot.notes = s.at('description').inner_html
      spot.author = s.at('author').content
      
      spot.deleted = false
      spot.open = !spot.notes.include?('zaklenjen')
      
      # Clean up google html
      spot.notes.gsub!(/<br>/i,"\n")
      spot.notes.gsub!(/<\/?div(.|\n)*?>/i,"")
      spot.notes.gsub!(/<\/?span(.|\n)*?>/i,"")
      spot.notes.gsub!(/<\/?font(.|\n)*?>/i,"")
      spot.notes.gsub!(/<\/?b(.|\n)*?>/i,"*")
      spot.notes.gsub!('&nbsp;'," ")
      
      if spot.save
        logger.info "Added new spot #{spot.title}"
        puts "Added new spot #{spot.title}"
      else
        logger.error "Spot not saved #{spot.permalink}, #{spot.title}"
        # puts "Spot not saved #{spot.permalink}, #{spot.title}"
        print "."
      end
    end
    
    puts "Import completed. Done!"
  end
  
  def restore
    self.update_attributes({:deleted => false, :reason => nil})
  end
  
  def delete(reason)
    self.update_attributes({:deleted => true, :reason => reason})
  end
  
  def destroy!
    self.destroy
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