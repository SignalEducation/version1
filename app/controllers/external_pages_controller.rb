# frozen_string_literal: true

class ExternalPagesController < ApplicationController
  before_action :check_logged_in_status, only: %i[home]
  before_action :layout_variables, only: %i[home about group pricing]
  before_action :check_group, only: %i[group]
  before_action :subscription_variables, except: %i[group]

  def home
    @home_page = HomePage.where(home: true).where(public_url: '/').first
    @vimeo_as_main = vimeo_as_main?

    if @home_page
      seo_title_maker(@home_page.seo_title, @home_page.seo_description, @home_page.seo_no_index)
      @footer = @home_page.footer_option
    else
      seo_title_maker('The Smarter Way to Study | LearnSignal',
                      'Discover learnsignal professional courses designed by experts and delivered online so that you can study on a schedule that suits your learning needs.',
                      false)
      @footer = 'white'
    end
    @form_type = 'Home Page Contact'
  end

  def about

  end

  def group
    @exam_body = @group.exam_body

  end

  def pricing
    @currency_id =
        if current_user
          current_user.country_id
        else
          ip_country = IpAddress.get_country(request.remote_ip)
          country = ip_country || Country.find_by(name: 'United Kingdom')
          country.currency_id
        end

    @group = Group.find_by(name_url: params[:name_url])
    if @currency_id && @group
      @subscription_plans = SubscriptionPlan.where(
          subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id
      ).includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
    else
      @subscription_plans = SubscriptionPlan.where(
          subscription_plan_category_id: nil
      ).includes(:currency).in_currency(@currency_id).all_active.all_in_order
    end
    @preferred_plan = @subscription_plans.last
  end

  private

  def check_group
    @group = Group.find_by(name_url: params[:name_url])
    redirect_to root_url and return unless @group&.active && @group&.exam_body&.active
    seo_title_maker(@group.seo_title, @group.seo_description, nil)
  end

  def check_logged_in_status
    if params[:home_pages_public_url].to_s == '500-page'
      render file: 'public/500.html', layout: nil, status: :internal_server_error
    elsif current_user
      redirect_to student_dashboard_url
    end
  end

  def layout_variables
    @navbar = false
    @top_margin = false
    @footer = true
  end

  def subscription_variables
    @currency_id =
        if current_user
          current_user.country_id
        else
          ip_country = IpAddress.get_country(request.remote_ip)
          country = ip_country || Country.find_by(name: 'United Kingdom')
          country.currency_id
        end

    if @currency_id && @group
      @subscription_plans = SubscriptionPlan.where(
          subscription_plan_category_id: nil, exam_body_id: @group.exam_body_id
      ).includes(:currency).in_currency(@currency_id).all_active.all_in_order.limit(3)
      @preferred_plan = @subscription_plans.where(payment_frequency_in_months: @home_page.preferred_payment_frequency).first
    end
  end

end