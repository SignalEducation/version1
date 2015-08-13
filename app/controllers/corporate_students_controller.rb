class CorporateStudentsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['corporate_customer'])
  end
  before_action :get_variables

  def index
    @corporate_students = User
                          .where(corporate_customer_id: current_user.corporate_customer_id)
                          .where(user_group_id: UserGroup.where(corporate_student: true).first.id)
                          .paginate(per_page: 50, page: params[:page])
                          .all_in_order
  end

  def new
    @corporate_student = User.new
  end

  def edit
  end

  def create
    @corporate_student = User
                         .new(allowed_params.merge({corporate_customer_id: current_user.corporate_customer_id,
                                                   user_group_id: UserGroup.where(corporate_student: true).first.id}))
    @corporate_student.de_activate_user
    @corporate_student.locale = 'en'
    if @corporate_student.save
      Mailers::OperationalMailers::ActivateAccountWorker.perform_async(@corporate_student.id)
      flash[:success] = I18n.t('controllers.corporate_students.create.flash.success')
      redirect_to corporate_students_url
    else
      render action: :new
    end
  end

  def update
    if @corporate_student.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.corporate_students.update.flash.success')
      if current_user.admin?
        redirect_to users_url
      else
        redirect_to corporate_students_url
      end
    else
      render action: :edit
    end
  end

  def destroy
    @corporate_student.de_activate_user
    if @corporate_student.save
      flash[:success] = I18n.t('controllers.corporate_students.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_students.destroy.flash.error')
    end
    redirect_to corporate_students_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @corporate_student = User.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:corporate_student).permit(:first_name, :last_name, :email, :employee_guid)
  end

end
