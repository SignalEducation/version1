class CbesController < ApplicationController

  skip_before_action :verify_authenticity_token

  def index

  end

  def show
    render json: Cbe.last
  end

  def create
    Cbe.new (params)
  end

  def create_it

    puts '**** Create'
    #Cbe.new (params)
  end

end
