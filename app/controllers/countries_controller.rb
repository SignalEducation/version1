# frozen_string_literal: true

class CountriesController < ApplicationController
  before_action :logged_in_required
  before_action { ensure_user_has_access_rights(%w[system_requirements_access]) }
  before_action :management_layout
  before_action :get_variables

  # Standard Actions #
  def index
    @term = params[:term]
    @countries = Country.includes(:currency).
                   search(@term).
                   paginate(per_page: 50, page: params[:page]).
                   all_in_order
  end

  def show; end

  def new
    @country = Country.new(sorting_order: 1)
  end

  def create
    @country = Country.new(allowed_params)

    if @country.save
      flash[:success] = I18n.t('controllers.countries.create.flash.success')
      redirect_to countries_url
    else
      render action: :new
    end
  end

  def edit; end

  def update
    if @country.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.countries.update.flash.success')
      redirect_to countries_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Country.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end

    render json: {}, status: :ok
  end

  def destroy
    if @country.destroy
      flash[:success] = I18n.t('controllers.countries.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.countries.destroy.flash.error')
    end

    redirect_to countries_url
  end

  protected

  def get_variables
    @continents = Country::CONTINENTS
    @country    = Country.find_by(id: params[:id])
    @currencies = Currency.all_in_order

    seo_title_maker(@country.try(:name) || 'Countries', '', true)
  end

  def allowed_params
    params.require(:country).permit(:name, :iso_code, :country_tld, :sorting_order, :in_the_eu, :currency_id, :continent)
  end
end
