module Ahoy
  class BaseController < ApplicationController
    skip_filter *_process_action_callbacks.map(&:filter)
    before_filter :load_authlogic

    def ahoy
      @ahoy ||= Ahoy::Tracker.new(controller: self, api: true)
    end

    private

    def load_authlogic
      Authlogic::Session::Base.controller = Authlogic::ControllerAdapters::RailsAdapter.new(self)
    end

  end
end