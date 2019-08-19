# frozen_string_literal: true

class HomePagesController < ApplicationController
  before_action :logged_in_required
  before_action do
    ensure_user_has_access_rights(%w[system_requirements_access marketing_resources_access])
  end
  before_action :management_layout
  before_action :get_variables

  def index
    @home_pages = HomePage.paginate(per_page: 40, page: params[:page]).all_in_order
  end

  def new
    @home_page = HomePage.new
    @home_page.blog_posts.build
    @home_page.external_banners.build(sorting_order: 1, active: true, background_colour: '#FFFFFF')
    @home_page.student_testimonials.build(sorting_order: 1)
  end

  def edit
    @home_page.blog_posts.build
    @home_page.external_banners.build(sorting_order: 1, active: true, background_colour: '#FFFFFF') unless @home_page.external_banners.any?
    @home_page.student_testimonials.build(sorting_order: 1)
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
    @home_page = HomePage.where(id: params[:id]).first if params[:id].to_i > 0
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
    @subject_courses = SubjectCourse.all_active.all_in_order
    @groups = Group.all_active.all_in_order
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description,
                                      :subscription_plan_category_id, :public_url,
                                      :subject_course_id, :custom_file_name,
                                      :name, :home, :group_id, :background_image,
                                      :mailchimp_list_guid, :logo_image,
                                      :registration_form, :pricing_section,
                                      :footer_link, :seo_no_index,
                                      :login_form, :preferred_payment_frequency,
                                      :header_h1, :header_paragraph,
                                      :registration_form_heading, :login_form_heading,
                                      :footer_option, :video_guid, :header_h3, :background_image,
                                      blog_posts_attributes: [:id, :home_page_id,
                                                              :title, :description,
                                                              :url, :_destroy,
                                                              :image, :image_file_name,
                                                              :image_content_type,
                                                              :image_file_size,
                                                              :image_updated_at
                                      ],
                                      external_banners_attributes: [:id, :name, :background_colour,
                                                                    :text_content, :sorting_order,
                                                                    :_destroy],
                                      student_testimonials_attributes: [:id, :text, :signature,
                                                                    :sorting_order,
                                                                        :image, :image_file_name,
                                                                        :image_content_type,
                                                                        :image_file_size,
                                                                        :image_updated_at,
                                                                        :_destroy]
    )

  end
end
