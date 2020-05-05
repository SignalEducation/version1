# frozen_string_literal: true

module Api
  class CronTasksController < Api::BaseController
    protect_from_forgery except: :create

    def create
      CronService.new.initiate_task(params[:id])
    end
  end
end
