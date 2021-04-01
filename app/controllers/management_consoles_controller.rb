# frozen_string_literal: true

class ManagementConsolesController < ApplicationController
  before_action :logged_in_required
  before_action except: :system_requirements do
    ensure_user_has_access_rights(%w[non_student_user])
  end
  before_action only: :system_requirements do
    ensure_user_has_access_rights(%w[marketing_resources_access system_requirements_access])
  end
  before_action :management_layout

  def index
    @verified_users = User.where(email_verified: true)
    total_years_of_data_to_show = 4
    define_year_month_instance_vars(total_years_of_data_to_show)
  end

  def system_requirements
    @home_pages = HomePage.paginate(per_page: 40, page: params[:page]).all_in_order
  end

  def public_resources
    @faq_sections = FaqSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  private

  def year_months(last_month)
    months = [['-', '']]
    (1..last_month).each { |m| months << [Date::MONTHNAMES[m], m] }
    months.drop(1)
  end

  def define_year_month_instance_vars(years_back)
    @months_to_date = year_months(Time.zone.today.month)
    @all_months = year_months(12)
    year_arr = []
    Array.new(years_back) do |i|
      year_4_digit = Time.zone.today.year - i
      year_2_digit = ((Time.zone.today + 6).year - i) % 100
      year_arr << year_4_digit
      if i < 1
        @months_to_date.map { |month, index| instance_variable_set("@#{month.downcase}_users", @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(year_4_digit, index).beginning_of_month, Date.new(year_4_digit, index).end_of_month)) }
      else
        @all_months.map { |month, index| instance_variable_set("@#{month.downcase}_users#{year_2_digit}", @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(year_4_digit, index).beginning_of_month, Date.new(year_4_digit, index).end_of_month)) }
      end
      @year_arr = year_arr.reverse
    end
  end
end
