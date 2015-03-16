class ApnPushMessages

  def self.send(type, trip, tok="")
    require 'uri'
    require 'net/https'
    Thread.new do
      params = {
        :ios => {
          :alert => {
            :body => 'Incoming Request',
            :data => {
              :lt => trip.from_coord['lat'],
              :ln => trip.from_coord['lng'],
              :rq => trip.id,
              :rt => type,
	      :tk => tok
            }
          }
        }
      }

      uri = URI.parse('https://pushtech.services.test.cc/send')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
      request.body = params.to_json

      response = http.request(request)
      response
    end
  end

end
