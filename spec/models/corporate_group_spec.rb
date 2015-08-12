require 'rails_helper'

describe CorporateGroup do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CorporateGroup.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants

  # relationships
  it { should belong_to(:corporate_customer) }
  it { should have_and_belong_to_many(:users) }
  it { should have_many(:corporate_group_grants) }

  # validation
  it { should validate_presence_of(:corporate_customer_id) }
  it { should validate_numericality_of(:corporate_customer_id) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:corporate_customer_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CorporateGroup).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:exam_level_restricted?) }
  it { should respond_to(:exam_level_compulsory?) }
  it { should respond_to(:exam_section_restricted?) }
  it { should respond_to(:exam_section_compulsory?) }
end
