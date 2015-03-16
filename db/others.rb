#encoding: utf-8
RequestCancelReason::create([:reason => :user_cancel, :comment => 'User cancel request']) and puts 'create RequestCancelReason user_cancel' unless RequestCancelReason::where(:reason => :user_cancel).any?
RequestCancelReason::create([:reason => :no_client, :comment => 'No client on pickup place']) and puts 'create RequestCancelReason no_client' unless RequestCancelReason::where(:reason => :no_client).any?

#Promo
PromoCode.create :code => '111111', :from => Time.now, :name => 'Trololo', :promo_type => 0, :value => 1000 , :per_user => 10, :uses_count => 0, :max_uses_number => 1000, :enabled => true unless PromoCode.find_by_code '111111'