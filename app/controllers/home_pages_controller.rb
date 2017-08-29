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
#

class HomePagesController < ApplicationController

  before_action :logged_in_required, only: [:index, :new, :edit, :update, :create]
  before_action :check_logged_in_status, only: [:home, :show, :subscribe]
  before_action except: [:home, :show, :subscribe] do
    ensure_user_is_of_type(%w(admin))
  end
  before_action :get_variables, except: [:home]
  before_action :layout_variables, only: [:home, :show]
  before_action :create_user_object, only: [:home, :show]

  def home
    @home_page = HomePage.where(custom_file_name: 'home').where(public_url: '/').first
    if @home_page
      @group = @home_page.group
    else
      @group = Group.all_active.all_in_order.first
    end
    #TODO Remove limit(3)
    @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order.limit(3)
    if @home_page.discourse_ids
      ids = @home_page.discourse_ids.split(",")
      @topics = get_discourse_topics(ids)
    end
    @form_type = 'Home Page Contact'
  end

  def show
    @home_page = HomePage.find_by_public_url(params[:home_pages_public_url])
    if @home_page
      @group = @home_page.group
      @subject_course = @home_page.subject_course

      #TODO Remove limit(3)
      @subscription_plans = SubscriptionPlan.where(subscription_plan_category_id: nil).includes(:currency).for_students.in_currency(@currency_id).all_active.all_in_order.limit(3)

      seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)

      # This is for sticky sub plans
      cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
      if @home_page.discourse_ids
        ids = @home_page.discourse_ids.split(",")
        @topics = get_discourse_topics(ids)
      end

    else
      redirect_to root_url
    end

    @form_type = 'Landing Page Contact'
  end

  def subscribe
    email = params[:email][:address]
    name = params[:first_name][:address]
    #list_id = '866fa91d62' # Dev List
    list_id = 'a716c282e2' # Production List
    if !email.blank?
      begin
        @mc.lists.subscribe(list_id, {'email' => email}, {'fname' => name})

        respond_to do |format|
          format.json{render json: {message: "Success! Check your email to confirm your subscription."}}
        end
      rescue Mailchimp::ListAlreadySubscribedError
        respond_to do |format|
          format.json{render json: {message: "#{email} is already subscribed to the list"}}
        end
      rescue Mailchimp::ListDoesNotExistError
        respond_to do |format|
          format.json{render json: {message: "The list could not be found."}}
        end
      rescue Mailchimp::Error => ex
        if ex.message
          respond_to do |format|
            format.json{render json: {message: "There is an error. Please enter valid email id."}}
          end
        else
          respond_to do |format|
            format.json{render json: {message: "An unknown error occurred."}}
          end
        end
      end
    else
      respond_to do |format|
        format.json{render json: {message: "Email Address Cannot be blank. Please enter valid email id."}}
      end
    end
  end

  def index
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
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

  def create_user_object
    @user = User.new
    # Setting the country and currency by the IP look-up, if it fails both values are set for primary marketing audience (currently GB). This also insures values are set for test environment.
    ip_country = IpAddress.get_country(request.remote_ip)
    @country = ip_country ? ip_country : Country.find_by_name('United Kingdom')
    @user.country_id = @country.id
    @currency_id = @country.currency_id
    #To allow displaying of sign_up_errors and valid params since a redirect is used at the end of student_create because it might have to redirect to home_pages controller
    if session[:sign_up_errors] && session[:valid_params]
      session[:sign_up_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end
      @user.first_name = session[:valid_params][0]
      @user.last_name = session[:valid_params][1]
      @user.email = session[:valid_params][2]
      @user.terms_and_conditions = session[:valid_params][3]
      session.delete(:sign_up_errors)
      session.delete(:valid_params)
    end
  end

  def check_logged_in_status
    if params[:home_pages_public_url].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: 500
    elsif current_user
      redirect_to student_dashboard_url
    end
  end

  def layout_variables
    @navbar = false
    @top_margin = false
    @footer = true
  end

  def get_discourse_topics(topic_ids)
    @client = DiscourseApi::Client.new(ENV['learnsignal_discourse_api_host'])
    @client.api_key = ENV['learnsignal_discourse_api_key']
    @client.api_username = ENV['learnsignal_discourse_api_username']
    topics = []
    topic_ids.each do |topic_id|
      topic = @client.topic(topic_id)
      object = OpenStruct.new(topic)
      topics << object
    end
    topics
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description,
                                      :subscription_plan_category_id, :public_url,
                                      :subject_course_id, :custom_file_name,
                                      :name, :group_id, :discourse_ids,
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
