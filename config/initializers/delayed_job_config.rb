Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.logger = Rails.logger