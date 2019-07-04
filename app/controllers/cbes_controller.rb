class CbesController < ApplicationController
  def index

  end

  def show
    render json: Cbe.last
  end

end
