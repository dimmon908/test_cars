#encoding utf-8
#PDFKit.configure do |config|
#  config.wkhtmltopdf = '/usr/bin/wkhtmltopdf'
#  config.default_options = {:page_size => 'Legal'}
#end

#PDFKit.configure do |config|
#  config.wkhtmltopdf = '/usr/local/bin/wkhtmltopdf' if Rails.env.production?
#end

#PDFKit.configure do |config|
#  config.wkhtmltopdf ='/usr/local/bin/wkhtmltopdf'
#
#  config.default_options = {
#      :encoding=>"UTF-8",
#      :page_size=>"Ledger",
#      :zoom => '1.3',
#      :disable_smart_shrinking=>false
#  }
#end