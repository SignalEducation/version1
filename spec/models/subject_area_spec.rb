# == Schema Information
#
# Table name: subject_areas
#
#  id              :integer          not null, primary key
#  name            :string
#  name_url        :string
#  sorting_order   :integer
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  seo_description :string
#  seo_no_index    :boolean          default(FALSE)
#

require 'rails_helper'

describe SubjectArea do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  SubjectArea.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()SubjectArea.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:institutions) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }
  it { should validate_numericality_of(:sorting_order) }

  it { should validate_presence_of(:seo_description) }
  it { should validate_length_of(:seo_description).is_at_most(255) }

  # callbacks
  it { should callback(:set_sorting_order).before(:create) }
  it { should callback(:sanitize_name_url).before(:save) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(SubjectArea).to respond_to(:all_in_order) }
  it { expect(SubjectArea).to respond_to(:all_active) }
  it { expect(SubjectArea).to respond_to(:all_inactive) }

  # class methods

  # instance methods
  it { should respond_to(:active_children) }
  it { should respond_to(:children) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:parent) }

end
