# == Schema Information
#
# Table name: video_resources
#
#  id             :integer          not null, primary key
#  course_step_id :integer
#  question       :text
#  answer         :text
#  notes          :text
#  destroyed_at   :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transcript     :text
#

require 'rails_helper'
require 'concerns/archivable_spec.rb'

describe VideoResource do
  let(:video) { build(:video_resource) }
  # relationships
  it { should belong_to :course_step }

  # validation
  it { should validate_presence_of(:course_step_id).on(:update) }

  it { should_not validate_presence_of(:question) }

  it { should_not validate_presence_of(:answer) }

  it { should_not validate_presence_of(:notes) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(VideoResource).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  describe 'Methods' do
    context '#destroyable?' do
      it 'always return true' do
        expect(video).to be_destroyable
      end
    end
  end

  describe 'Concern' do
    it_behaves_like 'archivable'
  end
end
