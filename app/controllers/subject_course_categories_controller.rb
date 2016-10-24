# == Schema Information
#
# Table name: subject_course_categories
#
#  id           :integer          not null, primary key
#  name         :string
#  payment_type :string
#  active       :boolean          default(FALSE)
#  subdomain    :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SubjectCourseCategoriesController < ApplicationController

  before_action :logged_in_required
  before_action do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables

  def index
    @subject_course_categories = SubjectCourseCategory.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  def show
  end

  def new
    @subject_course_category = SubjectCourseCategory.new
  end

  def edit
  end

  def create
    @subject_course_category = SubjectCourseCategory.new(allowed_params)
    if @subject_course_category.save
      flash[:success] = I18n.t('controllers.subject_course_categories.create.flash.success')
      redirect_to subject_course_categories_url
    else
      render action: :new
    end
  end

  def update
    if @subject_course_category.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.subject_course_categories.update.flash.success')
      redirect_to subject_course_categories_url
    else
      render action: :edit
    end
  end


  def destroy
    if @subject_course_category.destroy
      flash[:success] = I18n.t('controllers.subject_course_categories.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.subject_course_categories.destroy.flash.error')
    end
    redirect_to subject_course_categories_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @subject_course_category = SubjectCourseCategory.where(id: params[:id]).first
    end
  end

  def allowed_params
    params.require(:subject_course_category).permit(:name, :payment_type, :active, :subdomain)
  end

end
