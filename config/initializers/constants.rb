# frozen_string_literal: true

LEARNSIGNAL_HOST =
  case Rails.env
  when 'development'
    'http://localhost:3000'
  when 'staging', 'test'
    'https://staging.learnsignal.com'
  when 'production'
    'https://learnsignal.com'
  end
