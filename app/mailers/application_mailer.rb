class ApplicationMailer < ActionMailer::Base
  default from: ENV['EMAIL_FROM']
  default to: ENV['EMAIL_TO']
  layout 'mailer'

  def send_document(subject, filename)
    attachments["#{subject}.txt"] = File.read(filename)
    mail subject: subject
  end
end
