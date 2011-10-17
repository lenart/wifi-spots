module GeoConversions
  def to_degrees
    # self * 0.0174532925
    self * Math::PI / 180 
  end
end

class Float
  include GeoConversions
end