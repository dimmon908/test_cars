class CcsClient
=begin
  API_KEY = AIzaSyBFFIEcRbwbMZgiEFllWF1iRmj-NjG4bOo
  SENDER =  110798137699
=end

  GCM_SERVER = 'gcm.googleapis.com'.freeze
  # GCM_SERVER = 'jabbim.cz'.freeze
  GCM_POST = 5235.freeze

  GCM_ELEMENT_NAME = 'gcm'.freeze
  GCM_NAMESPACE = 'google:mobile:data'.freeze

  GCM_USER_NAME = '132269386474'.freeze
  GCM_PASSWORD = 'test'.freeze

  @@connection = nil

  def self.init_connection
    puts "started connection"
    @@connection = Jabber::Client.new(Jabber::JID.new(GCM_USER_NAME + '@' + GCM_SERVER))
    @@connection.on_exception { |e|
      Rails.logger.fatal "@@connection = #{e.message}"
      puts "@@connection = #{e.message}"
    }
    #@@connection.connect GCM_SERVER, GCM_POST
    @@connection.connect nil, GCM_POST
    @@connection.auth GCM_PASSWORD
    @@connection.send(Jabber::Presence.new.set_show(nil))
    puts "end connection"
  end

  def self.send_message(registration_id, data)
    message = Jabber::Message.new registration_id, data.to_s
    message.set_type :chat

    connection.send message
  end

  # @return [Jabber::Client]
  def self.connection
    init_connection unless @@connection
    @@connection
  end

end