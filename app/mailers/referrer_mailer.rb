class ReferrerMailer < ActionMailer::Base
  default from: 'notifications@test.cc'

  # @param [Referrer] referrer
  def invite_message(referrer)

    render = AbstractController::Rendering.new
    body = render.render_to_string 'emails/referrer/new'
    body.gsub /\%last_name\%/,

    @subject = 'Get a free ride'
    @body = body
    @recipients = referrer.email

  end
end
