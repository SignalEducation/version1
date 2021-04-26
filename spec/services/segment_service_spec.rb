# frozen_string_literal: true

require 'rails_helper'
require 'segment/analytics'

describe SegmentService, type: :service do

  let(:user) { create(:student_user) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:group) { FactoryBot.create(:group, exam_body: exam_body) }
  let!(:course)  { FactoryBot.create(:active_course, group: group, exam_body: exam_body) }
  let!(:scul) { FactoryBot.create(:course_log, user: user, course: course, percentage_complete: 10) }
  let(:enrollment) { create(:enrollment, user: user, course: course, course_log: scul, exam_body: exam_body) }
  let(:exercise) { create(:exercise, user: user) }

  context 'users' do
    describe '#identify_user' do
      it 'creates the user on Segment' do
        SegmentService.new.identify_user(user)

        subject.identify_user(user)
      end
    end

    describe '#track_verification_event' do
      it 'creates the user on Segment' do
        SegmentService.new.track_verification_event(user)

        subject.track_verification_event(user)
      end
    end
  end

  context 'enrollments' do
    describe '#track_course_enrolment_event' do
      it 'creates the user on Segment' do
        SegmentService.new.track_course_enrolment_event(enrollment, true, false)

        subject.track_course_enrolment_event(enrollment, true, false)
      end
    end

    describe '#track_enrolment_expiration_event' do
      it 'creates the user on Segment' do
        SegmentService.new.track_enrolment_expiration_event(enrollment)

        subject.track_enrolment_expiration_event(enrollment)
      end
    end
  end

  context 'exercises' do
    describe '#track_correction_returned_event' do
      it 'creates the user on Segment' do
        SegmentService.new.track_correction_returned_event(exercise)

        subject.track_correction_returned_event(exercise)
      end
    end
  end

end
