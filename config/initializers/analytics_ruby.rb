# frozen_string_literal: true

require 'segment/analytics'

Analytics = Segment::Analytics.new({ write_key: Rails.application.credentials[Rails.env.to_sym][:segment][:write_key],
                                     on_error: Proc.new { |status, msg| print msg } })