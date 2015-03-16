class CheckOnlineJob
  def do_interesting_things
    Driver.online.last_api_access(Time.now - Configurations[:online_timeout].minute).each do |driver|
      driver.online = 0
      driver.save :validate => false
    end

    #UserProfile.online.last_api_access(Time.now - Configurations[:online_timeout].minute).each do |profile|
    #  profile.online = 0
    #  profile.save :validate => false
    #end

    self.delay(:run_at => 30.seconds.from_now).do_interesting_things
  end

  def self.start_me_up
    new.do_interesting_things
  end
end