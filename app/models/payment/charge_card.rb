module Payment
  class ChargeCard < Payment::Base
    def check_possibility
      true
    end

    def void
      true
    end

    protected
    def proceed
      true
    end
  end
end