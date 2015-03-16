#encoding: utf-8
class Card < ActiveRecord::Base
  scope :less_expire, ->(date) { where('card_expire < ?', date) }
  scope :reminders, ->(name) { where('NOT EXISTS(SELECT 1 FROM `reminders` r WHERE r.user_id = credit_card_info.user_id AND name = ? AND rm_hash = card_hash)', name) }
  self.table_name = :credit_card_info

  CARD_TYPES = {
      :amex                      => 'American Express',
      :diners_club_carte_blanche => 'Diners Club Carte Blanche',
      :diners_club_international => 'Diners Club International',
      :discover                  => 'Discover Card',
      :jcb                       => 'JCB',
      :laser                     => 'Laser',
      :maestro                   => 'Maestro',
      :mastercard                => 'MasterCard',
      :visa                      => 'Visa',
      :visa_electron             => 'Visa Electron'
  }

  after_initialize :after_init
  before_save :before_save
  after_save :after_save
  before_create :before_create

  belongs_to :user

  attr_accessible :id, :card_number, :card_expire, :cvv, :checked, :owner, :user_id, :postal_code, :type_name,
                  :expiration_date_month, :expiration_date_year, :encrypted

  attr_accessor :expiration_date_month, :expiration_date_year, :first_name, :last_name

  validates :cvv, :presence => true, :length => {:within => 3..4}
  validates :card_number, :presence => true, :credit_card => true, :credit_card_length => true, :credit_card_online_server => :hash?

  def get_user
    if user.blank? && !user_id.blank?
      self.user = User::find user_id rescue nil
    end
    user
  end

  def hash?
    card_hash.to_s != m_hash.to_s
  end

  def m_hash
    Digest::MD5.hexdigest "#{id}_#{card_number}_#{card_expire}_#{cvv}"
  end

  def show_card
    "#{card_number.to_s[0, 4]} .... .... #{card_number.to_s[-4, 4]}"
  end

  private

  def after_init
    self.encrypted ||= false

    if card_expire
      self.expiration_date_month = card_expire.utc.strftime('%m').to_i
      self.expiration_date_year  = card_expire.utc.strftime('%y').to_i
    end

    if self.enc_card_number.blank?
      self.card_number = '' if card_number.blank?
    else
      self.card_number = MessagePack.unpack enc_card_number.force_encoding(Encoding::BINARY)
    end

    if self.enc_cvv.blank?
      self.cvv = '' if cvv.blank?
    else
      self.cvv = MessagePack.unpack enc_cvv.force_encoding(Encoding::BINARY)
    end

    if id && user_id.blank?
      self.user = User::where('card_id = ?', id).first if User::where('card_id = ?', id).any?
      save
    end
  end

  def before_save
    if expiration_date_month
      self.card_expire = DateTime.parse "#{expiration_date_year}-#{expiration_date_month.to_s.rjust(2, '0')}-01"
    end
    self.card_hash = m_hash

    self.enc_card_number = MessagePack.pack card_number
    self.enc_cvv = MessagePack.pack cvv

    self.card_number = ''
    self.cvv = ''
    self.encrypted = true
  end

  def after_save
    self.card_number = MessagePack.unpack enc_card_number.force_encoding(Encoding::BINARY)
    self.cvv = MessagePack.unpack enc_cvv.force_encoding(Encoding::BINARY)
  end

  def before_create
    self.checked ||= Time.now

    self.owner   = user.full_name if owner.to_s == '' && user
  end
end