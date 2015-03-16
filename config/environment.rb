#encoding: utf-8
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Test::Application.initialize!

def out_time(diff)
  #hour = diff.to_i/3600
  min = diff.to_i/60 - hour * 60
  sec = diff.to_i - (hour * 3600 + min * 60)
  "#{min.rjust(2, '0')}:#{sec.rjust(2, '0')}"
end
