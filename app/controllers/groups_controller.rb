# == Schema Information
#
# Table name: groups
#
#  id                    :integer          not null, primary key
#  name                  :string
#  name_url              :string
#  active                :boolean          default(FALSE), not null
#  sorting_order         :integer
#  description           :text
#  subject_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_customer_id :integer
#  destroyed_at          :datetime
#  image_file_name       :string
#  image_content_type    :string
#  image_file_size       :integer
#  image_updated_at      :datetime
#  background_colour     :string
#

class GroupsController < ApplicationController

  before_action :logged_in_required, except: [:show]
  before_action except: [:show] do
    ensure_user_is_of_type(['admin', 'content_manager'])
  end
  before_action :get_variables

  def index
    if current_user.corporate_customer?
      @groups = Group.where(corporate_customer_id: current_user.corporate_customer_id)
    else
      @groups = Group.where(corporate_customer_id: nil).paginate(per_page: 50, page: params[:page])
    end
    @footer = nil
  end

  def show
    if @group.nil?
      redirect_to library_url
    else
      courses = @group.try(:active_children)
      if current_user && (current_user.corporate_student? || current_user.corporate_customer?)
        corporate_courses = courses.where(corporate_customer_id: current_user.corporate_customer_id).all_in_order
        non_restricted_courses = courses.where.not(id: current_user.restricted_group_ids).all_in_order
        allowed_courses = corporate_courses + non_restricted_courses
        @courses = allowed_courses.uniq
      else
        courses = courses.try(:all_not_restricted)
        @courses = courses.try(:all_in_order)
      end
      if current_user
        @logs = SubjectCourseUserLog.where(user_id: current_user.id)
      end
      seo_title_maker(@group.try(:name), @group.try(:description), nil)
      tag_manager_data_layer(@group.try(:name))
    end
  end

  def admin_show
    @group = Group.where(id: params[:group_id]).first
    @courses = @group.try(:active_children)
  end

  def new
    @group = Group.new
    @corporates = CorporateCustomer.all_in_order
    @footer = nil
  end

  def edit
    @footer = nil
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
    @footer = nil
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
    @group = Group.where(name_url: params[:group_name_url]).first || Group.where(id: params[:id]).first
  end

  def allowed_params
    params.require(:group).permit(:name, :name_url, :active, :sorting_order, :description, :subject_id, :image, :background_colour, :corporate_customer_id)
  end

end
