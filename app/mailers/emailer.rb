class Emailer < ActionMailer::Base
  default from: "notifications@test.cc"

  def email(body, to, subject, headers = {})
    @subject = subject
    @body = body
    @recipients = to
    @headers = headers

    mail(:body => @body, subject: @subject, :to => @recipients, :headers => @headers)
  end
end
