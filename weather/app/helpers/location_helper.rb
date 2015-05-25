module LocationHelper

  def distance(location1, location2)
    rad_per_deg = Math::PI/180
    rkm = 6371
    rm = rkm * 1000

    dlat_rad = (location2[0]-location1[0]) * rad_per_deg
    dlon_rad = (location2[1]-location1[1]) * rad_per_deg

    lat1_rad, lon1_rad = location1.map {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = location2.map {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    rm * c
  end

  def get_nearest_postcode(location1)
    postcodes = Postcode.all
    nearest_postcode = nil
    dist = 999999999999999
    postcodes.each do |pc|
      new_dist = distance(location1, [pc.latitude, pc.longitude])
      if new_dist < dist
        dist = new_dist
        nearest_postcode = pc
      end
    end
    return nearest_postcode
  end
end
