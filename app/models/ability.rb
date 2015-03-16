#encoding: utf-8
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new #guest

    if user.role? :admin
      can :all, :all
      can :drivers, :all
      can :cars, :all
      can :config, :all
      can :clients, :all
      can :client_approve, :all
      can :show_user, :all
      can :sub_accounts, :all
      can :manage_sub_account, :all
      can :admin, :all
      can :select_plate, :all
      can :multiple_instant, :all
      can :request, :create
      can :disable, :all
      can :timer_on_active, :all
    elsif user.role? :personal
      can :show_user, :self
      can :credit_card, :all
      can :request, :create
    elsif user.role? :business
      can :show_user, :subs
      can :sub_accounts, :all
      can :create_sub_account, :all
      can :manage_sub_account, :all
      can :credit_card, :all
      can :multiple_instant, :all
      can :charge_business_account, :all
      can :charge_passenger_credit_card, :all
      can :put_room_number, :all
      can :admin, :business_part
      can :timer_on_active, :all
      can :request, :create
      can :disable, :all
    elsif user.role? :sub_account
      can :show_user, :self
      can :credit_card, :all
      can :multiple_instant, :all
      can :charge_business_account, :all
      can :charge_passenger_credit_card, :all
      can :put_room_number, :all
      can :timer_on_active, :all
      can :request, :create
    elsif user.role? :sub_account_with_admin
      can :show_user, :subs
      can :sub_accounts, :all
      can :create_sub_account, :all
      can :manage_sub_account, :all
      can :credit_card, :all
      can :multiple_instant, :all
      can :charge_business_account, :all
      can :charge_passenger_credit_card, :all
      can :put_room_number, :all
      can :admin, :business_part
      can :timer_on_active, :all
      can :request, :create
      can :disable, :all
    elsif user.role? :driver
      can :select_plate, :all
    else

    end

  end
end