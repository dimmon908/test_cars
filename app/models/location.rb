class Location < ActiveRecord::Base
  attr_accessible :address, :latitude, :longitude

  geocoded_by :address
  after_validation :geocode, :if => :address_changed?


  def self.calc_distance_from_route route
    distance = 0
    route['legs'].each do |leg|
      distance += leg['distance']['value']
    end
    distance
  end

  def self.calc_time_from_route route
    duration = 0
    route['legs'].each do |leg|
      duration += leg['duration']['value']
    end
    duration
  end

  def self.distance(from, to)
    distance = 0
    duration = 0

    json = self.route from, to

    if json['status'] == 'OK'
      routes = json['routes'].collect do |route|
        self.calc_distance_from_route route
      end
      times = json['routes'].collect do |route|
        self.calc_time_from_route route
      end
      distance = routes.max
      duration = times[routes.index(distance)]
    end

    return distance, duration
  end

  def self.direct_distance (a, b)  #distance without google APIs
    rad_per_deg = Math::PI/180  # PI / 180
    rkm = 6371                  # Earth radius in kilometers
    rm = rkm * 1000             # Radius in meters

    dlon_rad = (b[1]-a[1]) * rad_per_deg  # Delta, converted to rad
    dlat_rad = (b[0]-a[0]) * rad_per_deg

    lat1_rad, lon1_rad = a.map! {|i| i * rad_per_deg }
    lat2_rad, lon2_rad = b.map! {|i| i * rad_per_deg }

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin(Math.sqrt(a))

    rm * c # Delta in meters
  end

  def self.direct_distance2 (a, b)
    rad_per_deg = Math::PI/180
    rm = 6371 * 1000

    dlon_rad = (b['lng'].to_f-a['lng'].to_f) * rad_per_deg.to_f
    dlat_rad = (b['lat'].to_f-a['lat'].to_f) * rad_per_deg.to_f

    aa = Math.sin(dlat_rad/2)**2 + Math.cos(a['lng'].to_f * rad_per_deg) * Math.cos(b['lng'].to_f * rad_per_deg) * Math.sin(dlon_rad/2)**2
    c = 2 * Math.asin(Math.sqrt(aa))

    rm * c
  end

  def self.route(from, to)
    sfrom   = from.gsub(/ /, '+')
    sto     = to.gsub(/ /, '+')
    client  = HTTPClient.new
    content = client.get_content("http://maps.googleapis.com/maps/api/directions/json?origin=#{sfrom}&destination=#{sto}&sensor=false")
    JSON.parse(content)
  end

  def self.geocode(address)
    address = address.gsub(' ', '+')
    client  = HTTPClient.new
    content = client.get_content("http://maps.googleapis.com/maps/api/geocode/json?address=#{address}&sensor=false")
    JSON.parse(content)
  end

  def self.complete(address)
    address = address.gsub(' ', '+')
    client  = HTTPClient.new
    content = client.get_content("https://maps.googleapis.com/maps/api/geocode/json?input=#{address}&sensor=false")
    JSON.parse(content)
  end

  def self.coordinates(location)
    Gmaps4rails.geocode location
  end

  # @param [Hash] from
  # @param [Hash] to
  # @return [Float]
  def self.distance_between_coordinates(from, to)
    dtor = Math::PI/180
    r = 6371*1000

    rlat1 = from['lat'].to_f * dtor.to_f
    rlong1 = from['lng'].to_f * dtor.to_f
    rlat2 = to['lat'].to_f * dtor.to_f
    rlong2 = to['lng'].to_f * dtor.to_f

    dlon = rlong1.to_f - rlong2.to_f
    dlat = rlat1.to_f - rlat2.to_f

    a = Math.sin(dlat/2) ** 2 + Math.cos(rlat1) * Math.cos(rlat2) * Math.sin(dlon/2) ** 2
    #c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    c = 2 * Math.asin(Math.sqrt(a))
    d = r * c

    d
  end
end
