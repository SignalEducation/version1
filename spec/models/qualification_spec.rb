# == Schema Information
#
# Table name: qualifications
#
#  id                          :integer          not null, primary key
#  institution_id              :integer
#  name                        :string(255)
#  name_url                    :string(255)
#  sorting_order               :integer
#  active                      :boolean          default(FALSE), not null
#  cpd_hours_required_per_year :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#

require 'rails_helper'

describe Qualification do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Qualification.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect()Qualification.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:course_modules) }
  it { should have_many(:exam_levels) }
  it { should belong_to(:institution) }

  # validation
  it { should validate_presence_of(:institution_id) }
  it { should validate_numericality_of(:institution_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:cpd_hours_required_per_year) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Qualification).to respond_to(:all_in_order) }

  # class methods
  it { expect(Qualification).to respond_to(:get_by_name_url) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }

end
