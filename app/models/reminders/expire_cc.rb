module Reminders
  class ExpireCc
    def reminder
      remind(30, :card_reminder_30)
      remind(15, :card_reminder_15)
      remind(3, :card_reminder_3)
      remind(1, :card_reminder_1)
      self.delay(:run_at => 1.day.from_now).reminder
    end

    def remind(days, name)
      Card.less_expire(Time.now + days.to_i.day).reminders(name).each do |card|
        unless card.card_hash
          card.card_hash = card.m_hash
          card.save
          next if Reminder::where('user_id = ? AND name = ? AND rm_hash = ?', card.user_id, name, card.card_hash).any?
        end

        next unless card.user
        EmailsPull::create(
            :email => Email::find_by_internal_name(name),
            :params => {last_name: card.user.last_name, first_name: card.user.first_name, card: card.show_card}
        )
        Reminder::create({user_id: card.user_id, name: name, rm_hash: card.card_hash})
      end
    end

    def self.start_me
      new.reminder
    end
  end
end
