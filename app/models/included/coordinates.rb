module Included
  module Coordinates
    def from_coord
      from = self.params['from_coordinates'] rescue nil
      from = nil if from && (from['lat'] == 'undefined' || from['lng'] == 'undefined')
      unless from
        from = Gmaps4rails.geocode(self.from)[0] rescue nil
        if from
          from['lat'] = from[:lat]
          from['lng'] = from[:lng]
          from['name'] = self.from
          self.params['from_coordinates'] = from
        end
      end
      from = {:lat.to_s => 0, :lng.to_s => 0, :name.to_s => self.from} if from.blank?
      from
    end

    def to_coord(index = nil)
      index = self.to.length - 1 if index.blank?
      to = {}

      to = self.params['to_coordinates'][index] if self.params['to_coordinates'] && self.params['to_coordinates'][index]
      to = self.params["to_coordinates_#{index}"] if to.blank? && self.params["to_coordinates_#{index}"]

      to = {} if to['lat'].to_s == :undefined.to_s || to['lng'].to_s == :undefined.to_s

      if to.blank?
        to = Gmaps4rails.geocode(self.to[index])[0] rescue nil
        if to
          to['lat'] = to[:lat]
          to['lng'] = to[:lng]
          to['name'] = self.to[index]

          self.params['to_coordinates'] ||= []
          self.params['to_coordinates'][index] = to

        end
      end

      to = {:lat.to_s => 0, :lng.to_s => 0, :name.to_s => self.to[index]} if to.blank?
      to
    end

    def coordinates
      coord = []
      coord << from_coord

      to.each do |to, index|
        begin
          coord << to_coord(index)
        rescue Exception => e
          Log.exception e
        end
      end

      coord
    end
  end
end