module Excluded
  module User
    #@param [Role] role
    #@param [Fixnum] user_id
    #@return [User]
    def user_object_by_role(role, user_id)
      begin
        case role.internal_name.to_sym
          when :admin
            Classes::AdminAccount::find user_id
          when :personal
            Classes::PersonalAccount::find user_id
          when :business
            Classes::BusinessAccount::find user_id
          when :sub_account
            Classes::SubAccount::find user_id
          when :sub_account_with_admin
            Classes::SubAccount::find user_id
          when :driver
            Driver::find_by_user_id user_id
          else
            User::find user_id
        end
      rescue Exception => e
        Log.exception e
      end
    end

    # @return [User]
    def find_for_authentication(conditions={})
      unless conditions[:email] =~ /^([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})$/i
        if conditions[:email] =~ /^([\d\+\-\(\)]+)$/i
          conditions[:phone] = conditions.delete(:email)
        else
          conditions[:username] = conditions.delete(:email)
        end
      end
      super
    end

    def all_by_role role
      self::where(:role_id => Role::select(:id).where(:internal_name => role).all.collect{|r| r.id})
    end

    def get
      self
    end
  end
end
