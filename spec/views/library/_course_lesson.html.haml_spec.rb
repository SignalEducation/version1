# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'library/_course_lesson' do

  describe 'locked content' do
    context 'for site_admins' do
      let(:user) { build_stubbed(:admin_user) }
      let(:course_lesson) { build_stubbed(:course_lesson) }

      it 'shows the check icon at course_lesson level' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))
        allow(course_lesson).to receive(:all_content_restricted?).and_return(true)

        render partial: 'library/course_lesson', locals: { course_lesson: course_lesson, counter: 1, count: 1, current_user: user }

        expect(rendered).to match /check/
      end
    end

    context 'for users with a subscription' do
      let(:user) { build_stubbed(:user) }
      let(:course_lesson) { build_stubbed(:course_lesson) }

      it 'shows the lock icon at course_lesson level' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))
        allow(course_lesson).to receive(:all_content_restricted?).and_return(true)
        allow(user).to receive(:valid_subscription_for_exam_body?).and_return(true)

        render partial: 'library/course_lesson', locals: { course_lesson: course_lesson, counter: 1, count: 1, current_user: user }

        expect(rendered).to match /check/
      end
    end

    context 'for users without a relevant subscription' do
      let(:user) { build_stubbed(:user) }
      let(:course_lesson) { build_stubbed(:course_lesson) }

      it 'shows the lock icon at course_lesson level' do
        assign(:group, build_stubbed(:group))
        assign(:course, build_stubbed(:course))
        allow(course_lesson).to receive(:all_content_restricted?).and_return(true)

        render partial: 'library/course_lesson', locals: { course_lesson: course_lesson, counter: 1, count: 1, current_user: user }

        expect(rendered).to match /lock_outline/
      end
    end
  end
end
