class GoogleAddress

  attr_accessor :route, :locality, :country, :postal_code, :street_number, :state, :county, :neighborhood, :name

  def initialize(address_components = [], name = '')
    self.name = name
    address_components.each do |address|
      case address['types'][0].to_sym
        when :route
          self.route = address[:long_name]
        when :locality
          self.locality = address[:long_name]
        when :country
          self.country = address[:long_name]
        when :administrative_area_level_2
          self.county = address[:long_name]
        when :administrative_area_level_1
          self.state = address[:long_name]
        when :postal_code_prefix
          self.postal_code = address[:long_name]
        when :postal_code
          self.postal_code = address[:long_name]
        when :street_number
          self.street_number = address[:long_name]
        when :neighborhood
          self.neighborhood = address[:neighborhood]
      end
    end
  end

  def street
    "#{self.street_number} #{self.route}"
  end

  def city
    "#{self.locality} #{self.postal_code}"
  end

  def to_json
    {:route => self.route, :locality => self.locality, :country => self.country, :county => self.county, :state => self.state, :postal_code => self.postal_code, :street_number => self.street_number, :neighborhood => self.neighborhood, :name => self.name}
  end

  def self.from_json(json)
    address = GoogleAddress.new
    address.route ||= json[:route]
    address.locality ||= json[:locality]
    address.county ||= json[:county]
    address.country ||= json[:country]
    address.state ||= json[:state]
    address.postal_code ||= json[:postal_code]
    address.street_number ||= json[:street_number]
    address.neighborhood ||= json[:neighborhood]
    address.name ||= json[:name]
    address
  end
end