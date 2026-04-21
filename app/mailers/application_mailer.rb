class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "Robin <noreply@robin.katskouta.one>")
  layout "mailer"
end
