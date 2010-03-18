# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def textilize(text)
    RedCloth.new(text).to_html
  end
  
  def tweet_this(text)
    "http://twitter.com/home?status=#{CGI.escape(text)}"
  end
  
  def facebook_this(text,url = "http://wifi-tocke.si")
    "http://www.facebook.com/sharer.php?u=#{URI.encode(url)}&t=#{CGI.escape(text)}"
  end
  
  # Page headers
  
  def title(page_title)
    @content_for_title = h(page_title.to_s + " | WiFi točke")
  end
  
  def keywords(content)
    @content_for_keywords = h(content.to_s)
  end

  def description(content)
    @content_for_description = h(content.to_s)
  end
  
end