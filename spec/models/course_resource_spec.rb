# frozen_string_literal: true
# == Schema Information
#
# Table name: course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  course_id                :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#  external_url             :string
#  active                   :boolean          default("false")
#  sorting_order            :integer
#  available_on_trial       :boolean          default("false")
#  download_available       :boolean          default("false")
#

require 'rails_helper'

describe CourseResource do
  let(:user)              { create(:user) }
  let(:course)            { create(:course) }
  let(:course_resource_1) { create(:course_resource, course: course) }
  let(:course_resource_2) { create(:course_resource, course: course, external_url: '', available_on_trial: true) }

  # relationships
  it { should belong_to(:course) }
  it { should belong_to(:course_step) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:course) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseResource).to respond_to(:all_in_order) }
  it { expect(CourseResource).to respond_to(:all_active) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  describe 'Methods' do
    describe '#available_to_user' do
      context 'non verified user' do
        before { allow_any_instance_of(User).to receive(:non_verified_user?).and_return(true) }

        it { expect(course_resource_1.available_to_user(user, nil)).to eq({ view: false, reason: 'verification-required' }) }
      end

      context 'complimentary_user user' do
        before { allow_any_instance_of(User).to receive(:non_verified_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:complimentary_user?).and_return(true) }

        it { expect(course_resource_1.available_to_user(user, nil)).to eq({ view: true, reason: nil }) }
      end

      context 'non_student_user user' do
        before { allow_any_instance_of(User).to receive(:non_verified_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:non_student_user?).and_return(true) }

        it { expect(course_resource_1.available_to_user(user, nil)).to eq({ view: true, reason: nil }) }
      end

      context 'standard_student_user user' do
        before { allow_any_instance_of(User).to receive(:non_verified_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:non_student_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:complimentary_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:standard_student_user?).and_return(true) }

        it { expect(course_resource_1.available_to_user(user, true)).to eq({ view: true, reason: nil }) }
        it { expect(course_resource_1.available_to_user(user, false)).to eq({ view: false, reason: 'invalid-subscription' }) }
        it { expect(course_resource_2.available_to_user(user, false)).to eq({ view: true, reason: nil }) }
      end

      context 'default condition' do
        before { allow_any_instance_of(User).to receive(:non_verified_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:non_student_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:complimentary_user?).and_return(false) }
        before { allow_any_instance_of(User).to receive(:standard_student_user?).and_return(false) }

        it { expect(course_resource_1.available_to_user(user, true)).to eq({ view: false, reason: nil }) }
      end
    end

    describe '#destroyable?' do
      context 'always return true' do
        it { expect(course_resource_1).to be_destroyable }
        it { expect(course_resource_2).to be_destroyable }
      end
    end

    describe '#type' do
      context 'external link' do
        it { expect(course_resource_1.type).to eq('Link') }
      end

      context 'internal file' do
        it { expect(course_resource_2.type).to eq('File') }
      end
    end

    describe '#check_dependencies' do
      it 'stub destroyable to true to cover method' do
        allow_any_instance_of(CourseResource).to receive(:destroyable?).and_return(false)
        course_resource_1.destroy

        expect(course_resource_1.errors).not_to be_empty
      end
    end
  end
end
