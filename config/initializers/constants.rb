# frozen_string_literal: true

SALES_REPORT_EMAIL = Rails.env.production? ? 'sales-reports@learnsignal.com' : 'giordano@learnsignal.com'
MARKETING_EMAIL = Rails.env.production? ? 'marketing-team@learnsignal.com' : 'giordano@learnsignal.com'
DAYS_TO_VERIFY_EMAIL = 3
LEARNSIGNAL_HOST =
  case Rails.env
  when 'development'
    'http://localhost:3000'
  when 'staging', 'test'
    'https://staging-app.learnsignal.com'
  when 'production'
    'https://app.learnsignal.com'
  end
