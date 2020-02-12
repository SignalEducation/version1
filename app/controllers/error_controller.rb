# frozen_string_literal: true

class ErrorController < ApplicationController
  def internal_error
    render file: 'public/500.html', layout: nil, status: :internal_server_error
  end
end
