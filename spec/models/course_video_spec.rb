# == Schema Information
#
# Table name: course_videos
#
#  id             :integer          not null, primary key
#  course_step_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#  destroyed_at   :datetime
#  video_id       :string
#  duration       :float
#  vimeo_guid     :string
#  dacast_id      :string
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe CourseVideo do
  let(:cme) { build_stubbed(:course_video) }

  describe 'relationships' do
    it { should belong_to(:course_step) }
  end

  describe 'validations' do
    it { should validate_presence_of(:course_step_id).on(:update) }
    it { should validate_presence_of(:vimeo_guid) }
    it { should validate_length_of(:vimeo_guid).is_at_most(255) }
    it { should validate_presence_of(:duration) }
  end

  describe 'callbacks' do
    it { should callback(:check_dependencies).before(:destroy) }
  end

  describe 'scopes' do
    it { expect(CourseVideo).to respond_to(:all_in_order) }
    it { expect(CourseVideo).to respond_to(:all_destroyed) }
  end

  describe 'instance methods' do
    it { should respond_to(:parent) }
    it { should respond_to(:destroyable?) }
    it { should respond_to(:duplicate) }
  end

  describe 'Methods' do
    context '#destroyable?' do
      it 'always return true' do
        expect(cme).to be_destroyable
      end
    end

    context '#parent' do
      it 'return course_step association' do
        expect(cme.parent).to eq(cme.course_step)
      end
    end
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
