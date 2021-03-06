#encoding: utf-8
class Notification < ActiveRecord::Base
  after_initialize :after_init
  before_save :before_save
  after_save :after_save
  after_create :after_create

  attr_accessible :body_template, :internal_name, :lifetime, :react, :scope, :title, :body_type, :template, :desc
  attr_accessor :template

  validates_presence_of   :internal_name
  validates_uniqueness_of :internal_name

  def body_with_params(params)
    if self.file?
      view = ActionView::Base.new
      view.view_paths = ActionController::Base.view_paths
      text = view.render( :type => :builder, :file => self.body_template)
    end

    text ||= self.body_template

    if params.is_a?String
      params = JSON::parse params rescue nil
    end

    if params.is_a?Hash
    params.each do |key, value|
        text.gsub! "%#{key}%", value.to_s
    end
    end

    text
  end

  def file?
    self.body_type == 'file' && File.exist?(self.body_template)
  end

  protected
  def after_init
    self.template ||= File.read(self.body_template) if self.file?
    self.template ||= self.body_template
  end

  def before_save
    self.body_template = self.template if self.template && !self.file?
  end

  def after_save
    if self.file? && self.template
      open(self.body_template, 'w') { |f| f.puts self.template }
    end
  end

  def after_create
    puts "Notification '#{self.internal_name}' was created"
  end

end
