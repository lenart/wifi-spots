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
  

  #
  # Page headers
  # Defining variable @content_for_myvar = "123" is the same as doing content_for :myvar { "123" }
  # 
  
  def title_or_default
    content_for?(:title) ? content_for(:title) : "WiFi točke - seznam brezplačnih wifi točk po Sloveniji"
  end
  
  def keywords_or_default
    content_for?(:keywords) ? content_for(:keywords) : 'wifi točke, brezžična omrežja, brezplačne točke, brezplačen internet, dostop do interneta, wi-fi, wireless'
  end
  
  def description_or_default
    content_for?(:description) ? content_for(:description) : 'Seznam WiFi točk v Sloveniji, kjer lahko brezplačno dostopate do interneta. Poznaš tudi ti kako? Dodaj jo na zemljevid!'
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
  
  
end