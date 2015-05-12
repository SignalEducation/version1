class CorporateCustomersController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @corporate_customers = CorporateCustomer.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @corporate_customer = CorporateCustomer.new
  end

  def edit
  end

  def create
    @corporate_customer = CorporateCustomer.new(allowed_params)
    if @corporate_customer.save
      flash[:success] = I18n.t('controllers.corporate_customers.create.flash.success')
      redirect_to corporate_customers_url
    else
      render action: :new
    end
  end

  def update
    if @corporate_customer.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.corporate_customers.update.flash.success')
      redirect_to corporate_customers_url
    else
      render action: :edit
    end
  end


  def destroy
    if @corporate_customer.destroy
      flash[:success] = I18n.t('controllers.corporate_customers.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_customers.destroy.flash.error')
    end
    redirect_to corporate_customers_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @corporate_customer = CorporateCustomer.where(id: params[:id]).first
    end
    @countries = Country.all_in_order
    @owners = User.all_in_order
    seo_title_maker(@corporate_customer.try(:organisation_name) || 'Corporate Customers', '', true)
  end

  def allowed_params
    params.require(:corporate_customer).permit(:organisation_name, :address, :country_id, :payments_by_card, :is_university, :owner_id, :stripe_customer_guid, :can_restrict_content)
  end

end
