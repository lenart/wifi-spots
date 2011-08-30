# encoding: utf-8
class Search
  
  include Geokit::Geocoders
  
  MAX_SEARCH_RADIUS = 20
  PER_PAGE = 50
  
  # => @string user search query
  # => @distance used for user-defined search radius; internaly we use radius()
  # => @page used internaly for pagination
  # => radius() ensures user-defined radius is never bigger than MAX_SEARCH_RADIUS
  # => @address is extracted from @string and geo-located using GeoKit
  # => @location holds geo location (after search is run)
  
  CITIES = [
    ["ce", "celje"],
    ["kp", "koper"],
    ["kr", "kranj"],
    ["lj", "ljubljana"],
    ["mb","maribor"],
    ["ms", "murska sobota"],
    ["nm", "novo mesto"],
    ["po", "postojna"],
    ["ravne", "ravne na koroškem"],
    ["ve", "velenje"]
  ]
  
  NORMALIZATIONS = [
    ["wi-fi", "wifi"],
    ["internet", "wifi"],
    ["net", "wifi"],
    ["inet", "wifi"]
    # ["pri", "blizu"]  # This can appear in Spot.title!
  ]
  
  attr_reader :page, :location, :address
  attr_accessor :string, :distance, :geo_search
  
  def initialize(params)
    @string = @query = params[:q].to_s
    @page = (params[:page] || 1).to_i
    @address = @location = nil
    @distance = params[:distance] || 2
    @geo_search = params[:geo].blank? ? true : false
  end
  
  def blank?
    @query.blank?
  end
  
  def radius
    (@distance.to_i > MAX_SEARCH_RADIUS) ? MAX_SEARCH_RADIUS.to_i : @distance.to_i
  end
  
  def query
    normalize
  end
  
  def run
    raise Search::EmptyQuery if self.blank?
    
    if @geo_search
      @location = Geokit::Geocoders::MultiGeocoder.geocode(@query + ", slovenija")
    end
      
    if @location && @location.success
      logger "Searching for spots: #{@query} near [#{@location.lat}, #{@location.lng}]"
      # results = Spot.all(:conditions => ["distance < ? AND deleted=false", self.radius], :geo => [@location.lat, @location.lng], :order => "distance asc").paginate :page => @page, :per_page => PER_PAGE
      raise "ThinkingSphinx has new API!"
      results = Spot.search(:geo => [@location.lat, @location.lng]).paginate :page => @page, :per_page => PER_PAGE
    else
      logger "Searching for spots: #{@query}"
      results = Spot.search @query, :with => {:deleted => false}, :page => @page, :per_page => PER_PAGE
    end
    
    raise Search::NoResults.new(self.string, self.geo_search) if results.empty?
    results
  end
  
  private

    def geocode
      @address = self.query.scan(/blizu (.+)/).flatten.to_s
      return if @address.blank?
      @query = self.query.scan(/^(.+) blizu/).flatten.to_s

      logger "Geocoding address: #{@address.to_s}"
      @location = Geokit::Geocoders::MultiGeocoder.geocode(@address + ", slovenija")
      raise Search::NoGeoLocation.new(@address) unless @location.success
    end
  
    def normalize
      returning @query.downcase do |q|
        q.strip!

        NORMALIZATIONS.each do |replacement|
          q.gsub!(/\b#{replacement.first}\b/, replacement.last)
        end
    
        CITIES.each do |replacement|
          q.gsub!(/\b#{replacement.first}\b/, replacement.last)
        end
      end
    end
  
end



class Search::EmptyQuery < ArgumentError
  def initialize
    Rails.logger.warn "Empty search attempted."
  end
end

class Search::NoResults < RangeError
  attr_reader :query, :geo_search
  def initialize(query, geo_search)
    @query = query
    @geo_search = geo_search
  end
end

class Search::NoGeoLocation < RangeError
  def initialize(address)
    Rails.logger.warn "Unable to geocode: '#{address}'"
  end
end

def logger(message)
  Rails.logger.info message
end
