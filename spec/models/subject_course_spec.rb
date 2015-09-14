# == Schema Information
#
# Table name: subject_courses
#
#  id                :integer          not null, primary key
#  name              :string
#  name_url          :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE), not null
#  live              :boolean          default(FALSE), not null
#  wistia_guid       :string
#  tutor_id          :integer
#  cme_count         :integer
#  video_count       :integer
#  quiz_count        :integer
#  question_count    :integer
#  description       :text
#  short_description :string
#  mailchimp_guid    :string
#  forum_url         :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe SubjectCourse do

  # attr-accessible
  black_list = %w(id created_at updated_at video_count quiz_count question_count)
  SubjectCourse.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(SubjectCourse.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:tutor) }

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:wistia_guid) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:cme_count) }

  it { should validate_presence_of(:video_count) }

  it { should validate_presence_of(:quiz_count) }

  it { should validate_presence_of(:question_count) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:short_description) }

  it { should validate_presence_of(:mailchimp_guid) }

  it { should validate_presence_of(:forum_url) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubjectCourse).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
