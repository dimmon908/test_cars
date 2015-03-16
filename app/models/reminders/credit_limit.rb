module Reminders
  class CreditLimit
    def reminder
      remind(0.2, 0.1, :credit_reminder_20)
      remind(0.1, 0.05, :credit_reminder_10)
      remind(0.05, 0.00, :credit_reminder_5)
      self.delay(:run_at => 1.day.from_now).reminder
    end

    def remind(from, to, name)
      UserProfile.over_credit(from).less_credit(to).reminder(name).each do |profile|
        EmailsPull::create(
            :email => Email::find_by_internal_name(name),
            :params => {last_name: profile.user.last_name, first_name: profile.user.first_name}
        )
        Reminder::create({user_id: profile.user_id, name: name, rm_hash: profile.credit})
      end
    end

    def self.start_me
      new.reminder
    end
  end
end
