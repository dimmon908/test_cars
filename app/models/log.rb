class Log < ActiveRecord::Base
  before_save :before_save

  belongs_to :user
  attr_accessible :data, :user_id, :log_type, :user, :request, :session, :params, :request_url

  def self.<<(data)
    log = Log.new

    if data.is_a? Hash
      log.data     = data[:data]
      log.user     = data[:user]
      log.log_type = data[:type]
    else
      log.data     = data
      log.log_type = :notice
    end

    log.save
  end

  def username
    if self.user
      self.user.full_name
    else
      'anonymous'
    end
  end

  def self.exception(e = nil, user = nil)
    data = {}
    data = {:exception => e.to_s, :backtrace => e.backtrace.to_s} if e
    Log::create({
                    :data     => data.to_json,
                    :log_type => :error,
                    :user     => user
                }) rescue nil
  end

  private
  def before_save

    self.data ||= ''
    self.log_type ||= :notice
    self.request ||= ''
    self.session ||= ''
    self.params ||= ''

  end

end
