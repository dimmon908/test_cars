#encoding: utf-8
class Configurations < ActiveRecord::Base

  @@values = {}

  has_one :config_group

  after_initialize :after_init
  before_save :before_save
  after_save :after_save

  attr_accessible :config_groups_id, :internal_name, :key, :scope, :value, :text_value
  attr_accessor :text_value

  validates :text_value, :config => true

  def set_config_groups_id(value)
    if value.is_a?Fixnum
      self.config_groups_id = value
    elsif value
      group = ConfigGroup::find_or_create_by_internal_name value
      self.config_groups_id = group.id
    end
  end

  def self.[] name
    return @@values[name] if @@values[name]

    begin
      MessagePack.unpack Configurations::find_by_internal_name(name).value
    rescue
      nil
    end
  end

  def self.[]=(name, object)
    if object.is_a? Hash
      value = object[:value]
      group = object[:area]
    else
      value = object
    end

    value ||= ''
    group ||= :general

    config       = Configurations::find_or_create_by_internal_name name
    config.value = value
    config.set_config_groups_id group

    config.save(:validate => false)

    puts "config[#{name}]=#{value}"

    @@values[name] = value
    value
  end

  private
  def after_init
    self.text_value = MessagePack.unpack(self.value) rescue nil
  end

  def before_save
    if self.text_value
      self.value = MessagePack.pack(self.text_value) rescue nil
    end
  end

  def after_save
    self.text_value = MessagePack.unpack(self.value) rescue nil
  end
end