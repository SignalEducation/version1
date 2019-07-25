# frozen_string_literal: true

class ApiConstraint
  attr_reader :version

  def initialize(options)
    @version = options.fetch(:version)
  end

  def matches?(request)
    request.
      headers.
      fetch(:accept).
      include?("version=#{version}") ||
    version == 1
  end
end
