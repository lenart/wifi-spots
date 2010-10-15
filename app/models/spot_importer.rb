module SpotImporter

  require 'nokogiri'
  require 'open-uri'
  
  def self.included(klass)
    klass.extend ClassMethods
  end
  
  module ClassMethods

    # Import spots from Google Maps
    def import_from_gmaps_rss(overwrite = false)

      doc = Nokogiri::XML(open('http://maps.google.com/maps/ms?ie=UTF8&hl=en&oe=UTF8&msa=0&output=georss&msid=115530814119313728840.00047d9535ae3d1256bef'))
      # doc = Nokogiri::XML(open('lib/data/tocke.xml'))
  
      spots = doc.search('item')

      logger.info "Starting import of #{spots.size} items! #{Time.now}"

      spots.each do |s|
        spot = Spot.find_or_create_by_permalink(s.at('guid').content)
  
        next if !overwrite && !spot.new_record?
    
        begin
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
        rescue => e
          logger.error "Problem parsing the node #{spot.permalink}"
        end
        
      end

      puts "Import completed. Done!"
    end
  
  # END ClassMethods
  end 
  
  
end