class GroupsController < ApplicationController

  before_action :logged_in_required, except: [:show]
  before_action except: [:show] do
    ensure_user_is_of_type(['admin', 'content_manager', 'corporate_customer'])
  end
  before_action :get_variables, except: [:show]

  def index
    if current_user.corporate_customer?
      @groups = Group.where(corporate_customer_id: current_user.corporate_customer_id)
    else
      @groups = Group.where(corporate_customer_id: nil).paginate(per_page: 50, page: params[:page])
    end

  end

  def show
    @group = Group.where(name_url: params[:group_name_url]).first
    courses = @group.try(:active_children)
    if current_user && (current_user.corporate_student? || current_user.corporate_customer?)
      @courses = courses.where(corporate_customer_id: current_user.corporate_customer_id).where.not(id: current_user.restricted_group_ids)
    else
      @courses = courses.try(:all_not_restricted)
    end
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def edit_courses
    @group = Group.find(params[:group_id]) rescue nil
    if current_user.corporate_customer?
      @subject_courses = SubjectCourse.all_active.all_in_order.where(corporate_customer_id: current_user.corporate_customer_id)
    else
      @subject_courses = SubjectCourse.all_active.all_in_order.where(corporate_customer_id: nil)
    end
    if @group.nil? ||
        (current_user.corporate_customer? && current_user.corporate_customer_id != @group.corporate_customer_id)
      flash[:error] = I18n.t('controllers.application.you_are_not_permitted_to_do_that')
      redirect_to groups_url
    end
  end

  def create
    @group = Group.new(allowed_params)
    if current_user.corporate_customer
      @group.corporate_customer_id = current_user.corporate_customer_id
    end
    if @group.save
      flash[:success] = I18n.t('controllers.groups.create.flash.success')
      redirect_to groups_url
    else
      render action: :new
    end
  end

  def update
    if @group.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.groups.update.flash.success')
      redirect_to groups_url
    else
      render action: :edit
    end
  end

  def update_courses
    @group = Group.find(params[:group_id]) rescue nil
    if @group &&
        (current_user.admin? || current_user.corporate_customer_id == @group.corporate_customer_id)
      @group.subject_course_ids = params[:group][:subject_course_ids]
      flash[:success] = I18n.t('controllers.groups.update_subjects.flash.success')
      redirect_to groups_url
    else
      render action: :edit_members
    end
  end

  def reorder
    array_of_ids = params[:array_of_ids]
    array_of_ids.each_with_index do |the_id, counter|
      Group.find(the_id.to_i).update_attributes(sorting_order: (counter + 1))
    end
    render json: {}, status: 200
  end

  def destroy
    if @group.destroy
      flash[:success] = I18n.t('controllers.groups.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.groups.destroy.flash.error')
    end
    redirect_to groups_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @group = Group.where(id: params[:id]).first
    end
    #@subjects = Subject.all_in_order
  end

  def allowed_params
    params.require(:group).permit(:name, :name_url, :active, :sorting_order, :description, :subject_id)
  end

end
