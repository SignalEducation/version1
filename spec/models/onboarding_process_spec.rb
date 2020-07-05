# == Schema Information
#
# Table name: onboarding_processes
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  course_log_id :integer
#  active        :boolean          default("true"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'rails_helper'

describe OnboardingProcess do
  let(:basic_student)       { create(:basic_student) }
  let(:course_log)       { create(:course_log, user: basic_student) }
  let(:onboarding_process)  { create(:onboarding_process, user: basic_student, course_log: course_log) }

  describe 'Should Respond' do
    it { should respond_to(:user_id) }
    it { should respond_to(:course_log_id) }
    it { should respond_to(:active) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Constants' do
    it { expect(Message.const_defined?(:STATES)).to eq(true) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:course_log) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:course_log_id) }
  end

  describe 'callbacks' do
    it { should callback(:create_workers).after(:create) }
    it { should callback(:update_hubspot).after(:save) }
  end

  describe 'instance methods' do
    it { should respond_to(:content_remaining?) }
    it { should respond_to(:next_step) }
    it { should respond_to(:send_email) }
  end

  describe 'Methods' do
    context '#content_remaining?' do
      it 'should return true' do
        expect(onboarding_process.content_remaining?).to eq(true)
      end
    end

    context '#onboarding_subject' do
      it 'return Continue your ..' do
        expect(onboarding_process.onboarding_subject(1)).to eq("Continue your #{onboarding_process.course_log.course.group.name} study today. See what’s next!")
      end

      it 'return Pass your ..' do
        expect(onboarding_process.onboarding_subject(2)).to eq("Pass your #{onboarding_process.course_log.course.group.name} Exams first time. Get Ahead Now!")
      end

      it 'return .. Exams:' do
        expect(onboarding_process.onboarding_subject(3)).to eq("#{onboarding_process.course_log.course.group.name} Exams: Keep the momentum going & complete a  today!")
      end

      it 'return What’s next ..' do
        expect(onboarding_process.onboarding_subject(4)).to eq("What’s next?  Try this #{onboarding_process.course_log.course.group.name} !")
      end

      it 'return Continue your ..' do
        expect(onboarding_process.onboarding_subject(5)).to eq("#{onboarding_process.course_log.course.group.name} Exams: Here’s what to study today!")
      end

      it 'return Continue your ..' do
        expect(onboarding_process.onboarding_subject(nil)).to eq('Continue your study today. See what’s next!')
      end
    end

    context '#send_email' do
      it 'send message and update onboarding to false' do
        expect { onboarding_process.send_email(6) }.to change { onboarding_process.active }.from(true).to(false)
      end

      it 'send message and update onboarding to false' do
        allow_any_instance_of(OnboardingProcess).to receive(:content_remaining?).and_return(false)
        expect { onboarding_process.send_email(1) }.to change { onboarding_process.active }.from(true).to(false)
      end
    end
  end

end
