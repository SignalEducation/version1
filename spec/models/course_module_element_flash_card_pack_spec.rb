# == Schema Information
#
# Table name: course_module_element_flash_card_packs
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  background_color         :string(255)
#  foreground_color         :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  destroyed_at             :datetime
#

require 'rails_helper'

describe CourseModuleElementFlashCardPack do

  # attr-accessible
  black_list = %w(id created_at updated_at destroyed_at)
  CourseModuleElementFlashCardPack.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(CourseModuleElementFlashCardPack.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:course_module_element) }
  it { should have_many(:flash_card_stacks) }

  # validation
  it { should validate_presence_of(:course_module_element_id).on(:update) }
  xit { should validate_numericality_of(:course_module_element_id) }

  it { should validate_presence_of(:background_color) }

  it { should validate_presence_of(:foreground_color) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CourseModuleElementFlashCardPack).to respond_to(:all_destroyed) }
  it { expect(CourseModuleElementFlashCardPack).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:destroyable_children) }
  it { should respond_to(:spawn_flash_quiz) }

end
