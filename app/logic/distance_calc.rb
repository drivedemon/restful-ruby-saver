# app/logic/distance_calc.rb
module DistanceCalc
  module_function
  # return FixNum in meters
  def distance(loc1, loc2)
    rad_per_deg = Math::PI/180  # PI / 180
    rkm         = 6371          # Earth radius in kilometers
    # rm          = rkm * 1000    # Radius in meters

    dlat_rad    = (loc2[0] - loc1[0]) * rad_per_deg # Delta, converted to rad
    dlon_rad    = (loc2[1] - loc1[1]) * rad_per_deg

    lat1_rad    = loc1.map {|i| i * rad_per_deg }.first
    lat2_rad    = loc2.map {|i| i * rad_per_deg }.first

    a           = Math.sin(dlat_rad / 2) ** 2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c           = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1 - a))

    rkm * c # Delta in meters
  end

  def coordinate_distance_calculator(lat1 = nil, long1 = nil, lat2 = nil, long2 = nil)
    loc1 = [lat1.to_f, long1.to_f] # === current location
    loc2 = [lat2.to_f, long2.to_f] # === database location
    (distance(loc1, loc2)).round(2)
  end
end
