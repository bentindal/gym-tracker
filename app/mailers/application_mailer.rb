# frozen_string_literal: true

# The ApplicationMailer serves as the base mailer for all other mailers in the application.
# It provides default settings and layouts for outgoing emails.
class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:mailer, :default_from) || 'default@example.com'
  layout 'mailer'
end
