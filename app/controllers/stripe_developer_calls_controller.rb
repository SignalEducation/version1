class StripeDeveloperCallsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @stripe_developer_calls = StripeDeveloperCall.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @stripe_developer_call = StripeDeveloperCall.new
  end

  def edit
  end

  def create
    @stripe_developer_call = StripeDeveloperCall.new(allowed_params)
    @stripe_developer_call.user_id = current_user.id
    if @stripe_developer_call.save
      flash[:success] = I18n.t('controllers.stripe_developer_calls.create.flash.success')
      redirect_to stripe_developer_calls_url
    else
      render action: :new
    end
  end

  def update
    if @stripe_developer_call.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.stripe_developer_calls.update.flash.success')
      redirect_to stripe_developer_calls_url
    else
      render action: :edit
    end
  end


  def destroy
    if @stripe_developer_call.destroy
      flash[:success] = I18n.t('controllers.stripe_developer_calls.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.stripe_developer_calls.destroy.flash.error')
    end
    redirect_to stripe_developer_calls_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @stripe_developer_call = StripeDeveloperCall.where(id: params[:id]).first
    end
    @users = User.all_in_order
  end

  def allowed_params
    params.require(:stripe_developer_call).permit(:user_id, :params_received, :prevent_delete)
  end

end
