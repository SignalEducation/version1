class CorporateStudentsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['corporate_customer'])
  end
  before_action :get_variables

  def index
    @corporate_students = User
                          .where(user_group_id: UserGroup.where(corporate_student: true).first.id)
    if current_user.admin?
      @corporate_students = @corporate_students.where("corporate_customer_id is not null")
    else
      @corporate_students = @corporate_students.where(corporate_customer_id: current_user.corporate_customer_id)
      @corporate_customer = CorporateCustomer.where(id: current_user.corporate_customer_id).first

    end

    unless params[:search_term].blank?
      @corporate_students = @corporate_students.search_for(params[:search_term])
    end

    unless params[:corporate_group].blank?
      @corporate_students = @corporate_students.joins(:corporate_groups).where("corporate_groups_users.corporate_group_id = ?", params[:corporate_group])
    end

    @corporate_students = @corporate_students.paginate(per_page: 50, page: params[:page]).all_in_order
    @corporate_student = User.new
  end

  def new
    @corporate_student = User.new
  end

  def edit
  end

  def show
    course_logs = SubjectCourseUserLog.where(user_id: @corporate_student.id)
    compulsory_course_ids = @corporate_student.compulsory_subject_course_ids
    @compulsory_course_logs = course_logs.where(subject_course_id: compulsory_course_ids)

    @other_course_logs = course_logs.where.not(subject_course_id: compulsory_course_ids)
  end

  def create
    password = SecureRandom.hex(5)
    @corporate_student = User.new(allowed_params.merge({password: password,
                                                        password_confirmation: password,
                                                        user_group_id: UserGroup.where(corporate_student: true).first.id,
                                                        password_change_required: true}))

    @corporate_student.corporate_customer_id = current_user.corporate_customer_id if current_user.corporate_customer?
    @corporate_student.de_activate_user
    @corporate_student.locale = 'en'
    if @corporate_student.save
      @corporate_student.corporate_group_ids = params[:corporate_student][:corporate_group_ids]
      MandrillWorker.perform_async(@corporate_student.id,
                                   'send_verification_email',
                                   user_activation_url(activation_code: @corporate_student.account_activation_code))
      flash[:success] = I18n.t('controllers.corporate_students.create.flash.success')
      redirect_to corporate_students_url
    else
      render action: :new
    end
  end

  def update
    if @corporate_student.update_attributes(allowed_params)
      @corporate_student.corporate_group_ids = params[:corporate_student][:corporate_group_ids]
      flash[:success] = I18n.t('controllers.corporate_students.update.flash.success')
      redirect_to corporate_students_url
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
    @countries = Country.all_in_order
    if current_user.admin?
      @corporate_customers = CorporateCustomer.all_in_order
    elsif current_user.corporate_customer?
      @corporate_groups = CorporateGroup.where(corporate_customer_id: current_user.corporate_customer_id)
    end
    if params[:id].to_i > 0
      @corporate_student = User.where(id: params[:id]).first
    end
  end

  def allowed_params
    usr_params = [:first_name, :last_name, :country_id, :email, :employee_guid]
    usr_params << :corporate_customer_id if current_user.admin?
    params.require(:corporate_student).permit(usr_params)
  end

end
