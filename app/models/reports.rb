class Reports < ActiveRecord::Base
  after_initialize :after_init
  before_save :before_save

  PARAMS = %w(sales s_from s_to s_trip s_driver s_car s_user s_business s_full_price s_gratuity s_reward s_else refund r_from r_to r_trip r_driver r_car r_user r_business r_full_price r_gratuity r_amount driver d_from d_to d_id d_car d_start d_end d_breaks d_gratuity d_roting)

  attr_accessible :name, :date, :params, :results, :a_params, :a_results,
                  :sales, :s_from, :s_to, :s_trip, :s_driver, :s_car, :s_user, :s_business, :s_full_price, :s_gratuity, :s_reward, :s_else,
                  :refund, :r_from, :r_to, :r_trip, :r_driver, :r_car, :r_user, :r_business, :r_full_price, :r_gratuity, :r_amount,
                  :driver, :d_from, :d_to, :d_id, :d_car, :d_start, :d_end, :d_breaks, :d_gratuity, :d_roting

  attr_accessor :a_params, :a_results

  def initialize(hash = {})
    self.a_params ||= {}
    @sale = nil
    @refund = nil
    @driver = nil

    super hash
  end

  def method_missing(name, *args, &block)
    name2 = name.to_s.delete('=')
    if name.to_s.include?('=') && args[0]
      self.a_params[name2] = args[0]
    else
      self.a_params[name2]
    end
  end

  def respond_to?(name, *args)
    name2 = name.to_s.delete('=')
    return true if PARAMS.include?(name2)
    super(name, *args)
  end

  def generate_results
    a_results['sales'] = sale_report.generate if self.sales.to_i > 0
    a_results['refund'] = refund_report.generate if self.refund.to_i > 0
    a_results['driver'] = driver_report.generate if self.driver.to_i > 0
  end

  def create_sale_report
    from = Time::strptime(self.s_from.to_s, HelperTools::JS_DATE_FORMAT) rescue nil
    to = Time::strptime(self.s_from.to_s, HelperTools::JS_DATE_FORMAT) rescue nil

    report = Report::Sales.new(from, to)
    report.trip = self.s_trip
    report.driver = self.s_driver
    report.car = self.s_car
    report.user = self.s_user
    report.business = self.s_business
    report.full_price = self.s_full_price
    report.gratuity = self.s_gratuity
    report.reward = self.s_reward
    report.else = self.s_else
    report
  end
  # @return [Report::Sales]
  def sale_report
    @sale = create_sale_report unless @sale
    @sale
  end

  def create_refund_report
    from = Time::strptime(self.r_from.to_s, HelperTools::JS_DATE_FORMAT) rescue nil
    to = Time::strptime(self.r_from.to_s, HelperTools::JS_DATE_FORMAT) rescue nil

    report = Report::Refund.new(from, to)
    report.trip = self.r_trip
    report.driver = self.r_driver
    report.car = self.r_car
    report.user = self.r_user
    report.business = self.r_business
    report.full_price = self.r_full_price
    report.gratuity = self.r_gratuity
    report.refund = self.r_amount

    report
  end
  # @return [Report::Refund]
  def refund_report
    @refund = create_refund_report unless @refund
    @refund
  end

  def create_driver_report
    from = Time::strptime(self.d_from.to_s, HelperTools::JS_DATE_FORMAT) rescue nil
    to = Time::strptime(self.d_from.to_s, HelperTools::JS_DATE_FORMAT) rescue nil

    report = Report::Driver.new(from, to)
    report.driver = self.d_id
    report.car = self.d_car
    report.start = self.d_start
    report.end = self.d_end
    report.breaks = self.d_breaks
    report.gratuity = self.d_gratuity
    report.roting = self.d_roting

    report
  end
  def driver_report
    @driver = create_driver_report unless @driver
    @driver
  end

  def to_csv
    CSV.generate do |csv|
      if self.sales.to_i > 0
        csv << %w(Sales)
        csv << sale_report.columns
        a_results['sales'].each do |row| csv << row.values end
      end

      if self.refund.to_i > 0
        csv << %w(Refund)
        csv << refund_report.columns
        a_results['refund'].each do |row| csv << row.values end
      end

      if self.driver.to_i > 0
        csv << %w(Driver)
        csv << driver_report.columns
        a_results['driver'].each do |row| csv << row.values end
      end
    end
  end



  private
  def after_init
    self.a_params = MessagePack::unpack self.params if self.params
    self.a_results = MessagePack::unpack self.results if self.results

    self.a_results ||= {}
    self.a_params ||= {}

    generate_results if self.a_results.blank? && !self.a_params.blank?
  end

  def before_save
    generate_results if self.a_results.blank? && !self.a_params.blank?

    self.results = MessagePack::pack self.a_results if self.a_results
    self.params = MessagePack::pack self.a_params if self.a_params
    self.date ||= Time.now
  end
end