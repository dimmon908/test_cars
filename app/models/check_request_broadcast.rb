class CheckRequestBroadcast
  def do_interesting_things(id)
    return false unless Request::where(:id => id).any?

    request = Request::find id
    return false unless Trip::Status::instant?(request)

    request.broadcast
    self.delay(:run_at => 30.second.from_now).do_interesting_things(id)
  end

  def self.start_me_up(id)
    self.new.do_interesting_things(id)
  end
end