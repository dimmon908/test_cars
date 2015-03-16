module Excluded
  module Deliver
    def deliver
      begin
        for_send.each { |mail| mail.send_message }
      rescue Exception => e
        ::Log.exception e
      end
    end
  end
end