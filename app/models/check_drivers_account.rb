class CheckDriversAccount
  def do_interesting_things
     Classes::DriverAccount.
        where(:role_id => Role.driver.id).
        where('NOT EXISTS(SELECT 1 FROM `drivers` WHERE `drivers`.`user_id` = `users`.`id`)').each do |user|
      driver = Driver.new
      driver.user = user
      driver.enabled = 1
      driver.save :validate => false
    end

    self.delay(:run_at => 1.day.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end
