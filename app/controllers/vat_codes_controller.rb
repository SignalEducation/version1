# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string
#  label      :string
#  wiki_url   :string
#  created_at :datetime
#  updated_at :datetime
#

class VatCodesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables

  def index
    @vat_codes = VatCode.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @vat_code = VatCode.new
    @vat_code.vat_rates.build
  end

  def edit
  end

  def create
    @vat_code = VatCode.new(allowed_params)
    if @vat_code.save
      flash[:success] = I18n.t('controllers.vat_codes.create.flash.success')
      redirect_to vat_codes_url
    else
      render action: :new
    end
  end

  def update
    if @vat_code.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.vat_codes.update.flash.success')
      redirect_to vat_codes_url
    else
      render action: :edit
    end
  end


  def destroy
    if @vat_code.destroy
      flash[:success] = I18n.t('controllers.vat_codes.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.vat_codes.destroy.flash.error')
    end
    redirect_to vat_codes_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @vat_code = VatCode.where(id: params[:id]).first
    end
    @countries = Country.all_in_order
    seo_title_maker(@vat_code.try(:name) || 'VAT Codes', '', true)
  end

  def allowed_params
    params.require(:vat_code).permit(:country_id, :name, :label, :wiki_url,
    vat_rates_attributes: [:id, :percentage_rate, :effective_from])
  end

end
