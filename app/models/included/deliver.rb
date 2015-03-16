module Included
  module Deliver

    def success!
      self.status = :success
      self.success_stamp = Time.now
      self.save
    end

    def fail!
      self.fail_stamp = Time.now
      self.status = :error
      self.save
    end

    def proceed!
      self.status = :proceed
      save
    end
    def process
      nil
    end

    def send_message
      begin
        (res = false) and return unless user
        proceed!
        res = process
      rescue Exception => e
        Log.exception e
        res = false
      ensure
        res ? success! : fail!
        res
      end
    end

    protected
    def def_to

    end
    private
    def after_init
      if !self.params.blank? && self.params.is_a?(String)
        begin
          self.params = JSON.parse self.params
        rescue Exception => e
          Log.exception e
        end
      end
      self.params ||= {}
    end


    def before_save
      self.params = params.to_json if params.is_a?(Hash) || params.is_a?(Array)
      self.status ||= :new
      def_to
    end
  end
end