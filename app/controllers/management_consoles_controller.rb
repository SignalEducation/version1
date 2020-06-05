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
    @onboarding_messages = Message.where(kind: 1)
    @content = @onboarding_messages.where(template: 'send_onboarding_content_email')
    @day1 = @content.where(template_params: { day: 1 })
    @day1_opens = @day1.all.sum(:opens)
    @day1_clicks = @day1.all.sum(:clicks)

    @day2 = @content.where(template_params: { day: 2 })
    @day2_opens = @day2.all.sum(:opens)
    @day2_clicks = @day2.all.sum(:clicks)

    @day3 = @content.where(template_params: { day: 3 })
    @day3_opens = @day3.all.sum(:opens)
    @day3_clicks = @day3.all.sum(:clicks)

    @day4 = @content.where(template_params: { day: 4 })
    @day4_opens = @day4.all.sum(:opens)
    @day4_clicks = @day4.all.sum(:clicks)

    @day5 = @content.where(template_params: { day: 5 })
    @day5_opens = @day5.all.sum(:opens)
    @day5_clicks = @day5.all.sum(:clicks)

    @complete = @onboarding_messages.where(template: 'send_onboarding_complete_email')
    @complete_opens = @complete.all.sum(:opens)
    @complete_clicks = @complete.all.sum(:clicks)

    @expired = @onboarding_messages.where(template: 'send_onboarding_expired_email')
    @expired_opens = @expired.all.sum(:opens)
    @expired_clicks = @expired.all.sum(:clicks)
  end
end
