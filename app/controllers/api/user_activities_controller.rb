class Api::UserActivitiesController < ApplicationController

  def create


    render json: {}, status: :ok
  end

  protected

  def allowed_params
    params.permit(:event_name, :id, :parameters)
  end

end
