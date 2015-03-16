module DateTimeFormatter
  def human_readable(date_time)
    date_time.strftime("%m-%d-%Y %l:%M%P")
  end
end
