module Inits
  class CheckCC
    def do_interesting_things
      Card.where(:encrypted => 0).find_each do |card|
        card.encrypted = 1
        card.save :validate => false
      end
    end

    def self.start_me_up
      new.do_interesting_things
    end
  end
end
