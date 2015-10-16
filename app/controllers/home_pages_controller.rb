class HomePagesController < ApplicationController

  before_action :logged_in_required, except: [:show, :student_sign_up]
  before_action except: [:show, :student_sign_up] do
    ensure_user_is_of_type(['admin'])
  end
  before_action :get_variables, except: [:student_sign_up]

  def index
    @home_pages = HomePage.paginate(per_page: 10, page: params[:page]).all_in_order
  end

  def show
    if params[:first_element].to_s == '' && current_user
      redirect_to dashboard_url
    elsif params[:first_element].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: 500
    else
      first_element = '/' + params[:first_element].to_s
      @home_page = HomePage.where(public_url: first_element).first
      @user = User.new
      session[:sign_up_errors].each do |k, v|
        v.each { |err| @user.errors.add(k, err) }
      end if session[:sign_up_errors]
      session.delete(:sign_up_errors)
      @user.country_id = IpAddress.get_country(request.remote_ip).try(:id)
      # @user.subscriptions.build(subscription_plan_id: SubscriptionPlan.where(price: 0.0).pluck(:id).first)

      if @home_page
        seo_title_maker(@home_page.seo_title, @home_page.seo_description, false)
        cookies.encrypted[:latest_subscription_plan_category_guid] = {value: @home_page.subscription_plan_category.try(:guid), httponly: true}
        if @home_page.public_url == '/acca'
          render :acca
        elsif @home_page.public_url == '/cfa'
          render :cfa
        elsif @home_page.public_url == '/wso'
          render :wso
        end
      end
    end
  end

  def new
    @home_page = HomePage.new
  end

  def edit
  end

  def create
    @home_page = HomePage.new(allowed_params)
    if @home_page.save
      flash[:success] = I18n.t('controllers.home_pages.create.flash.success')
      redirect_to home_pages_url
    else
      render action: :new
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

  def student_sign_up
    if current_user
      redirect_to dashboard_url
    else
      currency = IpAddress.get_country(request.remote_ip).try(:currency_id) || Currency.where(iso_code: 'USD').first
      subscription_plan = SubscriptionPlan.in_currency(currency).where(price: 0.0).first
      if subscription_plan
        @user = User.new(student_allowed_params.merge({
                                                        "subscriptions_attributes" => { "0" => { "subscription_plan_id" =>  subscription_plan.id } }
                                                      }))
        @user.user_group_id = UserGroup.default_student_user_group.try(:id)
        @user.country_id = IpAddress.get_country(request.remote_ip).id

        @user.account_activation_code = SecureRandom.hex(10)
        @user.set_original_mixpanel_alias_id(mixpanel_initial_id)
        if cookies.encrypted[:crush_offers]
          @user.crush_offers_session_id = cookies.encrypted[:crush_offers]
          cookies.delete(:crush_offers)
        end
        if cookies.encrypted[:latest_subscription_plan_category_guid]
          subscription_plan_category = SubscriptionPlanCategory.where(guid: cookies.encrypted[:latest_subscription_plan_category_guid]).first
          @user.subscription_plan_category_id = subscription_plan_category.try(:id)
        end
        if @user.valid? && @user.save
          clear_mixpanel_initial_id
          MixpanelUserSignUpWorker.perform_async(
            @user.id,
            request.remote_ip
          )

          MandrillWorker.perform_async(@user.id,
                                       'send_verification_email',
                                       user_activation_url(activation_code: @user.account_activation_code))

          if cookies.encrypted[:referral_data]
            code, referrer_url = cookies.encrypted[:referral_data].split(';')
            if code
              referral_code = ReferralCode.find_by_code(code)
              @user.create_referred_signup(referral_code_id: referral_code.id,
                                           subscription_id: @user.subscriptions.first.id,
                                           referrer_url: referrer_url) if referral_code
              cookies.delete(:referral_data)
            end
          end

          @user.assign_anonymous_logs_to_user(current_session_guid)
          flash[:success] = I18n.t('controllers.home_pages.student_sign_up.flash.success')
          redirect_to personal_sign_up_complete_url
        else
          # This is the way to restore model errors after redirect. In referrer method
          # (which in our case can be one of three static pages - root, cfa or acca) we
          # are restoring errors to the @user. Otherwise our redirect would destroy errors
          # and sign-up form would not display them properly.
          session[:sign_up_errors] = @user.errors unless @user.errors.empty?
          redirect_to root_url
        end
      else
        # This is the way to restore model errors after redirect. In referrer method
        # (which in our case can be one of three static pages - root, cfa or acca) we
        # are restoring errors to the @user. Otherwise our redirect would destroy errors
        # and sign-up form would not display them properly.
        session[:sign_up_errors] = {} if session[:sign_up_errors].nil?
        session[:sign_up_errors][:subscription] = ["undefined default value"] if subscription_plan.nil?
        redirect_to request.referrer
      end
    end
  end

  protected

  def get_variables
    if params[:id].to_i > 0
      @home_page = HomePage.where(id: params[:id]).first
    end
    @subscription_plan_categories = SubscriptionPlanCategory.all_in_order
  end

  def allowed_params
    params.require(:home_page).permit(:seo_title, :seo_description, :subscription_plan_category_id, :public_url)
  end

  def student_allowed_params
    params.require(:user).permit(
          :email, :first_name, :last_name,
          :country_id, :locale,
          :password, :password_confirmation,
    )
  end
end
