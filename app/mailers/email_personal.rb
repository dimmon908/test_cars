class EmailPersonal < ActionMailer::Base
  default from: "notifications@test.cc"

  def success(user, email, params)

    mail(to: user.email, subject: 'trololo', body: email.body_with_params(params), content_type: "text/html", subject: email.title)

  end
end
