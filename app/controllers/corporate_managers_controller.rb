class CorporateManagersController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['corporate_customer'])
  end
  before_action :get_variables

  def index
    @corporate_managers = User.where(user_group_id: UserGroup.where(corporate_customer: true).first.id).all_in_order
    if current_user.admin?
      @corporate_managers = @corporate_managers.where("corporate_customer_id is not null")
    else
      @corporate_managers = @corporate_managers.where(corporate_customer_id: current_user.corporate_customer_id)
    end
    unless params[:search_term].blank?
      @corporate_managers = @corporate_managers.search_for(params[:search_term])
    end
    @corporate_managers = @corporate_managers.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def new
    @corporate_manager = User.new
  end

  def edit
  end

  def show
  end

  def create

    if Rails.env.production?
      password = SecureRandom.hex(5)
    else
      password = '123123123'
    end

    @corporate_manager = User.new(allowed_params.merge({password: password, password_confirmation: password, user_group_id: UserGroup.where(corporate_customer: true).first.id, password_change_required: true}))

    @corporate_manager.corporate_customer_id = current_user.corporate_customer_id if current_user.corporate_customer?
    @corporate_manager.activate_user
    @corporate_manager.country_id = current_user.corporate_customer.country_id  if current_user.corporate_customer?
    @corporate_manager.generate_email_verification_code
    @corporate_manager.locale = 'en'
    if @corporate_manager.save
      #IntercomCreateCorporateManagerWorker.perform_async(@corporate_manager.id, @corporate_manager.email, @corporate_manager.full_name, @corporate_manager.created_at, @corporate_manager.guid, @corporate_manager.user_group.name, @corporate_manager.corporate_customer_id, @corporate_manager.corporate_customer.organisation_name) unless Rails.env.test?
      #IntercomUserInviteEmailWorker.perform_at(1.minute.from_now, @corporate_manager.email, user_verification_url(email_verification_code: @corporate_manager.email_verification_code)) unless Rails.env.test?

      MandrillWorker.perform_async(@corporate_manager.id, @corporate_manager.corporate_customer_id,
                                   'send_verification_email',
                                   user_verification_url(email_verification_code: @corporate_manager.email_verification_code))


      flash[:success] = I18n.t('controllers.corporate_managers.create.flash.success')
      redirect_to corporate_managers_url
    else
      render action: :new
    end
  end

  def update
    if @corporate_manager.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.corporate_managers.update.flash.success')
      redirect_to corporate_managers_url
    else
      render action: :edit
    end
  end

  def destroy
    @corporate_manager.de_activate_user
    if @corporate_manager.save
      flash[:success] = I18n.t('controllers.corporate_managers.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_managers.destroy.flash.error')
    end
    redirect_to corporate_managers_url
  end

  protected

  def get_variables
    if current_user.admin?
      @corporate_customers = CorporateCustomer.all_in_order
    end
    if params[:id].to_i > 0
      @corporate_manager = User.where(id: params[:id]).first
    end
    @footer = nil
  end

  def allowed_params
    usr_params = [:first_name, :last_name, :country_id, :email, :employee_guid]
    usr_params << :corporate_customer_id if current_user.admin?
    params.require(:corporate_manager).permit(usr_params)
  end

end
