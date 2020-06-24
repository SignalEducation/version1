# frozen_string_literal: true

class ManagementConsolesController < ApplicationController
  before_action :logged_in_required
  before_action except: :system_requirements do
    ensure_user_has_access_rights(%w[non_student_user])
  end
  before_action :graph_date, only: :index
  before_action only: :system_requirements do
    ensure_user_has_access_rights(%w[marketing_resources_access system_requirements_access])
  end
  before_action :management_layout

  def index; end

  def system_requirements
    @home_pages = HomePage.paginate(per_page: 40, page: params[:page]).all_in_order
  end

  def public_resources
    @faq_sections = FaqSection.paginate(per_page: 50, page: params[:page]).all_in_order
  end

  private

  def graph_date
    @onboarding_messages  = Message.where(kind: :onboarding)
    @last_weeks_messages  = @onboarding_messages.sent_last_week
    @this_weeks_messages  = @onboarding_messages.sent_this_week
    @this_months_messages = @onboarding_messages.sent_this_month

    @tw_day1 = @this_weeks_messages.day_1
    @tw_day1_opens = @tw_day1.all.sum(:opens)
    @tw_day1_clicks = @tw_day1.all.sum(:clicks)

    @tw_day2 = @this_weeks_messages.day_2
    @tw_day2_opens = @tw_day2.all.sum(:opens)
    @tw_day2_clicks = @tw_day2.all.sum(:clicks)

    @tw_day3 = @this_weeks_messages.day_3
    @tw_day3_opens = @tw_day3.all.sum(:opens)
    @tw_day3_clicks = @tw_day3.all.sum(:clicks)

    @tw_day4 = @this_weeks_messages.day_4
    @tw_day4_opens = @tw_day4.all.sum(:opens)
    @tw_day4_clicks = @tw_day4.all.sum(:clicks)

    @tw_day5 = @this_weeks_messages.day_5
    @tw_day5_opens = @tw_day5.all.sum(:opens)
    @tw_day5_clicks = @tw_day5.all.sum(:clicks)

    @tw_complete = @this_weeks_messages.where(template: 'send_onboarding_complete_email')
    @tw_complete_opens = @tw_complete.all.sum(:opens)
    @tw_complete_clicks = @tw_complete.all.sum(:clicks)

    @tw_expired = @this_weeks_messages.where(template: 'send_onboarding_expired_email')
    @tw_expired_opens = @tw_expired.all.sum(:opens)
    @tw_expired_clicks = @tw_expired.all.sum(:clicks)

    @lw_day1 = @last_weeks_messages.day_1
    @lw_day1_opens = @lw_day1.all.sum(:opens)
    @lw_day1_clicks = @lw_day1.all.sum(:clicks)

    @lw_day2 = @last_weeks_messages.day_2
    @lw_day2_opens = @lw_day2.all.sum(:opens)
    @lw_day2_clicks = @lw_day2.all.sum(:clicks)

    @lw_day3 = @last_weeks_messages.day_3
    @lw_day3_opens = @lw_day3.all.sum(:opens)
    @lw_day3_clicks = @lw_day3.all.sum(:clicks)

    @lw_day4 = @last_weeks_messages.day_4
    @lw_day4_opens = @lw_day4.all.sum(:opens)
    @lw_day4_clicks = @lw_day4.all.sum(:clicks)

    @lw_day5 = @last_weeks_messages.day_5
    @lw_day5_opens = @lw_day5.all.sum(:opens)
    @lw_day5_clicks = @lw_day5.all.sum(:clicks)

    @lw_complete = @last_weeks_messages.where(template: 'send_onboarding_complete_email')
    @lw_complete_opens = @lw_complete.all.sum(:opens)
    @lw_complete_clicks = @lw_complete.all.sum(:clicks)

    @lw_expired = @last_weeks_messages.where(template: 'send_onboarding_expired_email')
    @lw_expired_opens = @lw_expired.all.sum(:opens)
    @lw_expired_clicks = @lw_expired.all.sum(:clicks)

    @tm_day1 = @this_months_messages.day_1
    @tm_day1_opens = @tm_day1.all.sum(:opens)
    @tm_day1_clicks = @tm_day1.all.sum(:clicks)

    @tm_day2 = @this_months_messages.day_2
    @tm_day2_opens = @tm_day2.all.sum(:opens)
    @tm_day2_clicks = @tm_day2.all.sum(:clicks)

    @tm_day3 = @this_months_messages.day_3
    @tm_day3_opens = @tm_day3.all.sum(:opens)
    @tm_day3_clicks = @tm_day3.all.sum(:clicks)

    @tm_day4 = @this_months_messages.day_4
    @tm_day4_opens = @tm_day4.all.sum(:opens)
    @tm_day4_clicks = @tm_day4.all.sum(:clicks)

    @tm_day5 = @this_months_messages.day_5
    @tm_day5_opens = @tm_day5.all.sum(:opens)
    @tm_day5_clicks = @tm_day5.all.sum(:clicks)

    @tm_complete = @this_months_messages.where(template: 'send_onboarding_complete_email')
    @tm_complete_opens = @tm_complete.all.sum(:opens)
    @tm_complete_clicks = @tm_complete.all.sum(:clicks)

    @tm_expired = @this_months_messages.where(template: 'send_onboarding_expired_email')
    @tm_expired_opens = @tm_expired.all.sum(:opens)
    @tm_expired_clicks = @tm_expired.all.sum(:clicks)

  end
end
