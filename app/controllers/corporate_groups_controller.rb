class CorporateGroupsController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin', 'corporate_customer'])
  end
  before_action :get_variables

  def index
    @corporate_groups = []
    if current_user.admin?
      @corporate_groups = CorporateGroup.paginate(per_page: 50, page: params[:page]).all_in_order
      @corporate_customers =CorporateCustomer.all
    elsif current_user.corporate_customer? && current_user.corporate_customer_id
      @corporate_groups = CorporateGroup
                          .where(corporate_customer_id: current_user.corporate_customer_id)
                          .paginate(per_page: 50, page: params[:page]).all_in_order
    end
    @corporate_groups
    if current_user.corporate_customer?
      @corporate_customer = CorporateCustomer.where(id: current_user.corporate_customer_id).first
    end
  end

  def show
    @users = @corporate_group.users
    @completed_comp_courses = SubjectCourseUserLog.where(completed: true).where(subject_course: @corporate_group.compulsory_subject_course_ids)
    @other_courses = SubjectCourseUserLog.where.not(subject_course: @corporate_group.compulsory_subject_course_ids)
  end

  def new
    @corporate_group = current_user.admin? ?
                         CorporateGroup.new :
                         CorporateGroup.new(corporate_customer_id: current_user.corporate_customer_id, corporate_manager_id: current_user.id)
    @corporate_managers = User
                              .where(user_group_id: UserGroup.where(corporate_customer: true).first.id).all_in_order
  end

  def edit
    if current_user.corporate_customer? && current_user.corporate_customer_id != @corporate_group.corporate_customer_id
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to corporate_groups_url
    end
    @corporate_managers = User.where(user_group_id: UserGroup.where(corporate_customer: true).first.id).all_in_order
  end

  def edit_members
    @corporate_group = CorporateGroup.find(params[:corporate_group_id]) rescue nil
    if @corporate_group.nil? ||
       (current_user.corporate_customer? && current_user.corporate_customer_id != @corporate_group.corporate_customer_id)
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to corporate_groups_url
    end
  end

  def create
    @corporate_group = CorporateGroup.new(allowed_params)
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group.save
      process_grants
      flash[:success] = I18n.t('controllers.corporate_groups.create.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :new
    end
  end

  def update
    name = allowed_params[:name]
    id = allowed_params[:corporate_manager_id]
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group.update_attributes(name: name)
       @corporate_group.update_attributes(corporate_manager_id: id)
      process_grants
      flash[:success] = I18n.t('controllers.corporate_groups.update.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :edit
    end
  end

  def update_members
    @corporate_group = CorporateGroup.find(params[:corporate_group_id]) rescue nil
    if @corporate_group &&
       (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id)
      @corporate_group.user_ids = params[:corporate_group][:corporate_student_ids]
      flash[:success] = I18n.t('controllers.corporate_groups.update_members.flash.success')
      redirect_to corporate_groups_url
    else
      render action: :edit_members
    end
  end

  def destroy
    if (current_user.admin? || current_user.corporate_customer_id == @corporate_group.corporate_customer_id) &&
       @corporate_group &&
       @corporate_group.destroy
      flash[:success] = I18n.t('controllers.corporate_groups.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.corporate_groups.destroy.flash.error')
    end
    redirect_to corporate_groups_url
  end

  protected

  def get_variables
    @corporate_customers = CorporateCustomer.all
    if params[:id].to_i > 0
      @corporate_group = CorporateGroup.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:corporate_group).permit(:corporate_customer_id,
                                            :name, :corporate_manager_id)
  end

  def process_grants
    # First we will update existing grants or destroy
    # them if flags were cleared.
    subject_course_ids = params[:courses].try(:keys) || []
    group_ids = params[:groups].try(:keys) || []
    remove_grants = []
    @corporate_group.corporate_group_grants.each do |cgg|
      if cgg.subject_course_id && cgg.group_id.nil?
        if subject_course_ids.include?(cgg.subject_course_id.to_s)
          cgg.compulsory = params[:courses][cgg.subject_course_id.to_s] == "compulsory"
          cgg.restricted = params[:courses][cgg.subject_course_id.to_s] == "restricted"
          subject_course_ids.delete(cgg.subject_course_id.to_s)
          cgg.save
        else
          cgg.destroy
        end
      elsif cgg.subject_course_id.nil? && cgg.group_id
        if group_ids.include?(cgg.group_id.to_s)
          cgg.compulsory = params[:groups][cgg.group_id.to_s] == "compulsory"
          cgg.restricted = params[:groups][cgg.group_id.to_s] == "restricted"
          group_ids.delete(cgg.group_id.to_s)
          cgg.save
        else
          cgg.destroy
        end
      end
    end
    # Now let's add new ones.
    subject_course_ids.each do |sci|
      @corporate_group.corporate_group_grants.create(subject_course_id: sci,
                                                     compulsory: params[:courses][sci] == "compulsory",
                                                     restricted: params[:courses][sci] == "restricted")
    end
    group_ids.each do |gi|
      @corporate_group.corporate_group_grants.create(group_id: gi,
                                                     compulsory: params[:groups][gi] == "compulsory",
                                                     restricted: params[:groups][gi] == "restricted")
    end
  end
end
