require 'rails_helper'

describe CorporateGroupGrant do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CorporateGroupGrant.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(CorporateGroupGrant.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:corporate_group) }
  it { should belong_to(:exam_level) }
  it { should belong_to(:exam_section) }

  # validation
  it { should validate_presence_of(:corporate_group_id) }
  it { should validate_numericality_of(:corporate_group_id) }

  it { should validate_numericality_of(:exam_level_id) }

  it { should validate_numericality_of(:exam_section_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CorporateGroupGrant).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
