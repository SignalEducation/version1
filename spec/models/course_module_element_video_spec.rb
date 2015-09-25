# == Schema Information
#
# Table name: course_module_element_videos
#
#  id                           :integer          not null, primary key
#  course_module_element_id     :integer
#  raw_video_file_id            :integer
#  tags                         :string
#  difficulty_level             :string
#  estimated_study_time_seconds :integer
#  transcript                   :text
#  created_at                   :datetime
#  updated_at                   :datetime
#  destroyed_at                 :datetime
#  video_id                     :string
#  duration                     :float
#  thumbnail                    :text
#

require 'rails_helper'

describe CourseModuleElementVideo do

  # attr-accessible
  black_list = %w(id created_at updated_at estimated_study_time_seconds destroyed_at)
  CourseModuleElementVideo.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(CourseModuleElementVideo.const_defined?(:BASE_URL)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should belong_to(:raw_video_file) }

  # validation
  it { should validate_presence_of(:course_module_element_id).on(:update) }
  xit { should validate_numericality_of(:course_module_element_id) }

  it { should_not validate_presence_of(:raw_video_file_id) }
  it { should validate_numericality_of(:raw_video_file_id) }
  #it { should validate_uniqueness_of(:raw_video_file_id) }

  it { should validate_presence_of(:tags) }
  it { should validate_length_of(:tags).is_at_most(255) }

  it { should validate_presence_of(:video_id) }
  it { should validate_length_of(:video_id).is_at_most(255) }

  it { should validate_inclusion_of(:difficulty_level).in_array(ApplicationController::DIFFICULTY_LEVEL_NAMES) }
  it { should validate_length_of(:difficulty_level).is_at_most(255) }

  it { should validate_presence_of(:transcript) }

  # callbacks
  it { should callback(:set_estimated_study_time).before(:update) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementVideo).to respond_to(:all_in_order) }
  it { expect(CourseModuleElementVideo).to respond_to(:all_destroyed) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:set_estimated_study_time) }

end
