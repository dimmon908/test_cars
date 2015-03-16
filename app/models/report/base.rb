module Report
  class Base
    HANDLERS = {}

    attr_accessor :driver, :car, :start, :end, :breaks, :roting, :gratuity

    def initialize(from = nil, to = nil)
      @from = from || Time.now
      @from = @from.beginning_of_day
      @to = to || Time.now
      @to = @to.end_of_day
    end

    def rows
      ActiveRecord::Base
    end

    def generate
      hand = active_handlers
      results = []
      rows.each { |row|
        result = {}
        hand.each_key {|h| result[h] = self.class::HANDLERS[h].call row }
        results << result
      }
      results
    end



    def fill_handlers(hand)
      hand
    end

    def active_handlers
      hand = {}
      fill_handlers hand
      hand
    end

    def columns
      []
    end
  end
end
