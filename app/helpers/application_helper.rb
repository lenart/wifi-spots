# encoding: UTF-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def hide_map?
    @hide_map || false
  end
  
  def textilize(text)
    # RedCloth.new(text)
    RDiscount.new(text).to_html.html_safe
  end
  
  def tweet_this(text)
    "http://twitter.com/home?status=#{CGI.escape(text)}"
  end
  
  def facebook_this(text,url = "http://wifi-tocke.si")
    "http://www.facebook.com/sharer.php?u=#{URI.encode(url)}&t=#{CGI.escape(text)}"
  end
  
  def reci
    "kaj pa je to zdej"
  end


  #
  # Page headers
  # Defining variable @content_for_myvar = "123" is the same as doing content_for :myvar { "123" }
  # 
  
  def default_keywords
    'wifi točke, brezžična omrežja, brezplačne točke, brezplačen internet, dostop do interneta, wi-fi, wireless'
  end
  
  def default_description
    'Seznam WiFi točk v Sloveniji, kjer lahko brezplačno dostopate do interneta. Poznaš tudi ti kako? Dodaj jo na zemljevid!'
  end
  
  def title(page_title)
    content_for :title, h(page_title.to_s + " | WiFi točke")
  end
  
  def keywords(content)
    content_for :keywords, h(content.to_s)
  end

  def description(content)
    content_for :description, h(content.to_s)
  end
  
  
  
  
  
  def spots_center(spots)
    maxlat, maxlng, minlat, minlng = -Float::MAX, -Float::MAX, Float::MAX, Float::MAX
    spots.each do |spot|
      maxlat = spot.lat if spot.lat > maxlat
      minlat = spot.lat if spot.lat < minlat
      maxlng = spot.lng if spot.lng > maxlng
      minlng = spot.lng if spot.lng < minlng
    end
    return [(maxlat + minlat)/2, (maxlng + minlng)/2]
  end
  
  
end