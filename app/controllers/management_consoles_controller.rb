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

    @january_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 1).beginning_of_month, Date.new(2018, 1).end_of_month)
    @february_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 2).beginning_of_month, Date.new(2018, 2).end_of_month)
    @march_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 3).beginning_of_month, Date.new(2018, 3).end_of_month)
    @april_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 4).beginning_of_month, Date.new(2018, 4).end_of_month)
    @may_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 5).beginning_of_month, Date.new(2018, 5).end_of_month)
    @june_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 6).beginning_of_month, Date.new(2018, 6).end_of_month)
    @july_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 7).beginning_of_month, Date.new(2018, 7).end_of_month)
    @august_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 8).beginning_of_month, Date.new(2018, 8).end_of_month)
    @september_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 9).beginning_of_month, Date.new(2018, 9).end_of_month)
    @october_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 10).beginning_of_month, Date.new(2018, 10).end_of_month)
    @november_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 11).beginning_of_month, Date.new(2018, 11).end_of_month)
    @december_users18 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2018, 12).beginning_of_month, Date.new(2018, 12).end_of_month)

    @january_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 1).beginning_of_month, Date.new(2019, 1).end_of_month)
    @february_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 2).beginning_of_month, Date.new(2019, 2).end_of_month)
    @march_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 3).beginning_of_month, Date.new(2019, 3).end_of_month)
    @april_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 4).beginning_of_month, Date.new(2019, 4).end_of_month)
    @may_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 5).beginning_of_month, Date.new(2019, 5).end_of_month)
    @june_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 6).beginning_of_month, Date.new(2019, 6).end_of_month)
    @july_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 7).beginning_of_month, Date.new(2019, 7).end_of_month)
    @august_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 8).beginning_of_month, Date.new(2019, 8).end_of_month)
    @september_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 9).beginning_of_month, Date.new(2019, 9).end_of_month)
    @october_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 10).beginning_of_month, Date.new(2019, 10).end_of_month)
    @november_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 11).beginning_of_month, Date.new(2019, 11).end_of_month)
    @december_users19 = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2019, 12).beginning_of_month, Date.new(2019, 12).end_of_month)

    @january_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 1).beginning_of_month, Date.new(2020, 1).end_of_month)
    @february_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 2).beginning_of_month, Date.new(2020, 2).end_of_month)
    @march_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 3).beginning_of_month, Date.new(2020, 3).end_of_month)
    @april_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 4).beginning_of_month, Date.new(2020, 4).end_of_month)
    @may_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 5).beginning_of_month, Date.new(2020, 5).end_of_month)
    @june_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 6).beginning_of_month, Date.new(2020, 6).end_of_month)
    @july_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 7).beginning_of_month, Date.new(2020, 7).end_of_month)
    @august_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 8).beginning_of_month, Date.new(2020, 8).end_of_month)
    @september_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 9).beginning_of_month, Date.new(2020, 9).end_of_month)
    @october_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 10).beginning_of_month, Date.new(2020, 10).end_of_month)
    @november_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 11).beginning_of_month, Date.new(2020, 11).end_of_month)
    @december_users = @verified_users.where('users.created_at > ? AND users.created_at < ?', Date.new(2020, 12).beginning_of_month, Date.new(2020, 12).end_of_month)
  end

  def system_requirements
    @home_pages = HomePage.paginate(per_page: 40, page: params[:page]).all_in_order
  end

  def public_resources
    @faq_sections = FaqSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end
end
