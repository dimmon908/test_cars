#encoding: utf-8
class PromoCode < ActiveRecord::Base

  before_save :before_save_callback
  after_save :after_save
  after_initialize :after_init

  attr_accessible :enabled, :from, :max_uses_number, :name, :order_over, :per_user, :single, :promo_type, :until, :uses_count, :value, :code, :orders_type, :over_value

  validates :name, :presence => true, :promo_name_unique => true
  validates :code, :presence => true, :promo_code_unique => true
  validates :value, :presence => true

  # @return [PromoCode]
  def self.get_promo(code)
    promo = PromoCode::find_by_code code
    promo = PromoCode::find_by_name code unless promo
    promo
  end

  def check(user_id)
    errors = []
    errors << I18n.t('model.errors.custom.promo_code') if from && from > Time.now
    errors << I18n.t('model.errors.custom.promo_code') if self.until && self.until < Time.now
    errors << I18n.t('model.errors.custom.promo_code') unless enabled

    errors << I18n.t('model.errors.custom.promo_code') if single? && PromoCodeHistory::where(:promo_code_id => id).any?
    errors << I18n.t('model.errors.custom.promo_code') if once_per_user? && PromoCodeHistory::where(:promo_code_id => id, :user_id => user_id).any?
    errors
  end

  def type_name
    return 'USD' if self.promo_type.to_i == 0
    'Percentage'
  end

  def status_name
    return 'Active' if self.enabled?
    'Disabled'
  end

  def orders_type_name
    if self.orders_type.to_i == 0
      'All Orders'
    elsif self.orders_type.to_i == 1
      "Order over $#{self.over_value}"
    end
  end

  def valid_dates
    "#{(self.from.strftime Driver::DATE_FORMAT rescue nil)}-#{self.until.strftime Driver::DATE_FORMAT rescue nil}"
  end

  def before_save_callback
    unless self.code
      self.code = loop do
        code = SecureRandom.urlsafe_base64(nil, false)[0..10]
        break code unless self.class.exists?(code: code)
      end
    end

    begin
      if self.from.is_a?(String) && self.from =~ Driver::DATE_REGEXP
        self.from = Time.strptime self.from, Driver::DATE_FORMAT
      end

      if self.until.is_a?(String) && self.until =~ Driver::DATE_REGEXP
        self.until = Time.strptime self.until, Driver::DATE_FORMAT
      end
    rescue Exception => e
      Log.exception e
    end
  end

  def init_date
    self.from = self.from.strftime Driver::DATE_FORMAT if self.from
    self.until = self.until.strftime Driver::DATE_FORMAT if self.until
  end

  def format_from
    begin
      self.from.strftime Driver::DATE_FORMAT
    rescue
      nil
    end
  end

  def format_until
    begin
      self.until.strftime Driver::DATE_FORMAT
    rescue
      nil
    end
  end

  def after_save
    self.init_date
  end

  def from_date
    return Time.strptime self.from, Driver::DATE_FORMAT if self.from.to_s =~ Driver::DATE_REGEXP
    self.from
  end

  def until_date
    return Time.strptime self.until, Driver::DATE_FORMAT if self.until.to_s =~ Driver::DATE_REGEXP
    self.until
  end

  def after_init
    self.enabled ||= 1
    self.promo_type ||= 0

    self.init_date
  end

  def single?
    self.max_uses_number.to_sym == :single
  end

  def unlimited?
    self.max_uses_number.to_sym == :unlimited
  end

  def once_per_user?
    self.max_uses_number.to_sym == :once_per_user
  end

  def percentage?
    self.promo_type.to_i != 0
  end

  def stable?
    self.promo_type.to_i == 0
  end

  def text_value
    if self.stable?
      "#{self.value} USD"
    else
      "#{self.value}%"
    end
  end

  def calc_discount(price)
    if self.percentage?
      price * (self.value.to_f/100)
    else
      self.value
    end
  end

  def self.calc_discount(promo_code = '', user_id = 0, rate = 0)
    promo = get_promo(promo_code)
    if promo && !(promo.check(user_id)).blank?
      discount = promo.calc_discount rate
    end
    discount ||= 0
    (rate - discount)
  end

end
