class TutorApplicationsController < ApplicationController

  before_action :logged_in_required, except: [:new, :create]
  before_action except: [:new, :create] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @tutor_applications = TutorApplication.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @tutor_application = TutorApplication.new
  end

  def edit
  end

  def create
    @tutor_application = TutorApplication.new(allowed_params)
    if @tutor_application.save
      flash[:success] = I18n.t('controllers.tutor_applications.create.flash.success')
      redirect_to action: :new
    else
      render action: :new
    end
  end

  def update
    if @tutor_application.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.tutor_applications.update.flash.success')
      redirect_to tutor_applications_url
    else
      render action: :edit
    end
  end

  def destroy
    if @tutor_application.destroy
      flash[:success] = I18n.t('controllers.tutor_applications.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.tutor_applications.destroy.flash.error')
    end
    redirect_to tutor_applications_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @tutor_application = TutorApplication.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:tutor_application).permit(:first_name, :last_name, :email, :info, :description)
  end

end
