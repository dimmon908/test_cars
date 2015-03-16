#encoding: utf-8
class NotificationPull < ActiveRecord::Base
  scope :only_new, ->(user_id) {where(:status => :new, :user_id => user_id)}
  scope :readed, ->(user_id) {where(:status => :readed, :user_id => user_id)}
  scope :visible, ->(user_id) {where('`status` IN (\'new\', \'readed\') AND `user_id` = ?', user_id)}
  after_initialize :after_init
  before_save :before_save

  belongs_to :notification
  belongs_to :user
  attr_accessible :params, :status, :notification, :notification_id, :user, :user_id

  def get_notification
    self.notification = Notification::find self.notification_id unless self.notification
    self.notification
  end

  def readed!
    self.status = :readed
    self.save
    end

  def to_js
    {
        :id => id,
        :status => status,
        :body => (notification_id.to_i > 0 ? notification.body_with_params(params) : text_field)
    }
  end

  def hide
    self.status = :hide
    save
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
  end

  def before_save
    self.params = self.params.to_json if self.params.is_a?(Hash) || self.params.is_a?(Array)
    self.status ||= :new
  end

end
