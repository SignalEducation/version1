# frozen_string_literal: true

class CronTasksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    CronService.new.initiate_task(params[:id])
  end
end
