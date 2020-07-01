# frozen_string_literal: true

SALES_REPORT_EMAIL = Rails.env.production? ? 'sales-reports@learnsignal.com' : 'giordano@learnsignal.com'
MARKETING_EMAIL = Rails.env.production? ? 'marketing-team@learnsignal.com' : 'giordano@learnsignal.com'
LEARNSIGNAL_HOST =
  case Rails.env
  when 'development'
    'http://localhost:3000'
  when 'staging', 'test'
    'https://staging.learnsignal.com'
  when 'production'
    'https://learnsignal.com'
  end
