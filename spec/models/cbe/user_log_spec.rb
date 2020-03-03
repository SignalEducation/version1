# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cbe::UserLog, type: :model do
  let(:cbe)           { build(:cbe) }
  let(:cbe_user_log)  { build(:cbe_user_log, :with_questions, cbe: cbe, score: 0) }
  let(:exercise)      { build(:exercise, cbe_user_log: cbe_user_log) }

  describe 'Should Respond' do
    it { should respond_to(:status) }
    it { should respond_to(:score) }
    it { should respond_to(:cbe_id) }
    it { should respond_to(:user_id) }
    it { should respond_to(:exercise_id) }
    it { should respond_to(:educator_comment) }
    it { should respond_to(:created_at) }
    it { should respond_to(:updated_at) }
  end

  describe 'Associations' do
    it { should belong_to(:cbe) }
    it { should belong_to(:user) }
    it { should belong_to(:exercise) }
    it { should have_many(:questions) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:cbe_id) }
  end

  describe 'Enums' do
    it do
      should define_enum_for(:status).
               with(started: 0, paused: 1, finished: 3, corrected: 4)
    end
  end

  describe 'Methods' do
    let(:private_cbe)          { create(:cbe) }
    let(:private_cbe_user_log) { create(:cbe_user_log, :with_questions, cbe: private_cbe, score: 0) }
    let(:private_exercise)     { create(:exercise, cbe_user_log: cbe_user_log) }

    before do
      allow_any_instance_of(SlackService).to receive(:notify_channel).and_return(false)
      allow_any_instance_of(Exercise).to receive(:correction_returned_email).and_return(false)
    end

    it '.update_score' do
      expect { cbe_user_log.update_score }.to change { cbe_user_log.score }.from(0).to(cbe_user_log.questions.map(&:score).sum)
    end

    it '.default_status' do
      expect { cbe_user_log.default_status }.to change { cbe_user_log.status }.from(nil).to('started')
    end

    it 'update_exercise_status' do
      private_cbe_user_log.questions.map { |q| q.cbe_question.update(kind: 'multiple_choice') }
      private_cbe_user_log.update(status: 'finished')

      expect(private_exercise.state).to eq('pending')
    end
  end
end
