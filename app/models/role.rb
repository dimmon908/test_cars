#encoding: utf-8
class Role < ActiveRecord::Base
  scope :business, -> {select(:id).where('internal_name IN (?)', [:business, :sub_account, :sub_account_with_admin])}
  scope :client, -> {select(:id).where('internal_name IN (?)', [:business, :sub_account, :sub_account_with_admin, :personal])}
  scope :admins, -> {select(:id).where('internal_name = ?', :admin)}
  scope :personal, -> {select(:id).where('internal_name = ?', :personal)}
  scope :users, -> {select(:id).where('internal_name IN (?)', [:sub_account, :sub_account_with_admin])}
  scope :drivers, -> {select(:id).where('internal_name = ?', :driver)}

  self.table_name = :roles
  has_and_belongs_to_many :user
  attr_accessible :description, :internal_name


  # @param [User] user
  def self.client?(user)
    (client.collect { |r| r.id }).include? user.role_id
  end

  # @param [User] user
  def self.personal?(user)
    user.role_id == personal.first.id
  end

  # @param [User] user
  def self.business?(user)
    (business.collect { |r| r.id }).include? user.role_id
  end

  # @param [User] user
  def self.users?(user)
    (users.collect { |r| r.id }).include? user.role_id
  end

  # @param [User] user
  def self.admin?(user)
    admin.id == user.role_id
  end

  # @param [User] user
  def self.driver?(user)
    driver.id == user.role_id
  end

  def self.admin
    admins.first
  end

  # @return [Role]
  def self.driver
    drivers.first
  end
end
