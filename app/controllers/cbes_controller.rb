class CbesController < ApplicationController


  def index

  end

  def show
    render json: Cbe.last
  end

  def new
    Cbe.new (params)
  end
end
