# frozen_string_literal: true

module Admin
  class CbesController < ApplicationController
    layout 'cbe_layout'
    before_action :logged_in_required
    before_action do
      ensure_user_has_access_rights(%w(system_requirements_access))
    end

    def new; end
  end
end
