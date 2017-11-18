# == Schema Information
#
# Table name: currencies
#
#  id              :integer          not null, primary key
#  iso_code        :string
#  name            :string
#  leading_symbol  :string
#  trailing_symbol :string
#  active          :boolean          default(FALSE), not null
#  sorting_order   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class CurrenciesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w(content_management_access))
  end
  before_action :get_variables

  def index
    @currencies = Currency.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @currency = Currency.new(sorting_order: 1)
  end

  def edit
  end

  def create
    @currency = Currency.new(allowed_params)
    if @currency.save
      flash[:success] = I18n.t('controllers.currencies.create.flash.success')
      redirect_to currencies_url
    else
      render action: :new
    end
  end

  def update
    if @currency.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.currencies.update.flash.success')
      redirect_to currencies_url
    else
      render action: :edit
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Currency.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @currency.destroy
      flash[:success] = I18n.t('controllers.currencies.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.currencies.destroy.flash.error')
    end
    redirect_to currencies_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @currency = Currency.where(id: params[:id]).first
    end
    seo_title_maker(@currency.try(:name) || 'Currencies', '', true)
    @layout = 'management'
  end

  def allowed_params
    params.require(:currency).permit(:iso_code, :name, :leading_symbol, :trailing_symbol, :active, :sorting_order)
  end

end
