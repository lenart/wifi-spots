# encoding: utf-8
module SpotsHelper
  
  def spot_type(open)
    open ? "Odprto WiFi omrežje" : "Zaprto WiFi omrežje"
  end
  
end