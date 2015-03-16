module Included
  module Role
    def role_class
      @class = ::User::user_object_by_role role, id unless @class
      @class
    end

    def role?(role)
      self.role.internal_name.to_sym == role rescue nil
    end

    def client?
      (Role::client.collect{|r| r.id}).include? role_id
    end
    def personal?
      Role.personal? self
    end

    def business?
      (Role::business.collect{|r| r.id}).include? role_id
    end

    def users?
      (Role::users.collect{|r| r.id}).include? role_id
    end

    def admin?
      Role::admins.first.id == role_id
    end

    def driver?
      Role::drivers.first.id == role_id
    end

    protected
    def create_role
      if role_id && role.nil?
        self.role = ::Role::find role_id
        return role
      end

      self.role = ::Role.find_by_internal_name :personal unless role_id
    end

  end
end