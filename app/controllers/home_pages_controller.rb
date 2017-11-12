# == Schema Information
#
# Table name: home_pages
#
#  id                            :integer          not null, primary key
#  seo_title                     :string
#  seo_description               :string
#  subscription_plan_category_id :integer
#  public_url                    :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  subject_course_id             :integer
#  custom_file_name              :string
#  group_id                      :integer
#  name                          :string
#  discourse_ids                 :string
#  home                          :boolean          default(FALSE)
#

class HomePagesController < ApplicationController

  before_action :logged_in_required
  before_action  do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables

  def index
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
  end

  def show

  end

  def new
    @home_page = HomePage.new
    @home_page.blog_posts.build
  end

  def edit
    @home_page.blog_posts.build
  end

  def create
    @home_page = HomePage.new(allowed_params)
    if @home_page.save
      flash[:success] = I18n.t('controllers.home_pages.create.flash.success')
      redirect_to home_pages_url
    else
      render action: :new
      @home_page.blog_posts.build
    end
  end

  def update
    if @home_page.update_attributes(allowed_params)
      flash[:success] = I18n.t('controllers.home_pages.update.flash.success')
      redirect_to home_pages_url
    else
      render action: :edit
    end
  end

  def destroy
    if @home_page.destroy
      flash[:success] = I18n.t('controllers.home_pages.destroy.flash.success')
    else
      flash[:error] = I18n.t('controllers.home_pages.destroy.flash.error')
    end
    redirect_to home_pages_url
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @home_page = HomePage.where(id: params[:id]).first
    end
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
    @groups = Group.all_active.all_in_order
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description,
                                      :subscription_plan_category_id, :public_url,
                                      :subject_course_id, :custom_file_name,
                                      :name, :home, :group_id,
                                      blog_posts_attributes: [:id, :home_page_id,
                                                              :title, :description,
                                                              :url, :_destroy,
                                                              :image, :image_file_name,
                                                              :image_content_type,
                                                              :image_file_size,
                                                              :image_updated_at
                                      ]
    )

  end

end
