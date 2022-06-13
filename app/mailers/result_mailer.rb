class ResultMailer < ApplicationMailer
    default from: 'nokiatv7738@gmail.com'
    def result_share_email(toEmail,reportFile)
        @url = reportFile
        mail(to: toEmail, subject: "Data analysis report")
    end
end