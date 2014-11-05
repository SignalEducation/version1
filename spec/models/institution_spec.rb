# == Schema Information
#
# Table name: institutions
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  short_name      :string(255)
#  name_url        :string(255)
#  description     :text
#  feedback_url    :string(255)
#  help_desk_url   :string(255)
#  subject_area_id :integer
#  sorting_order   :integer
#  active          :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

describe Institution do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  Institution.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { Institution.const_defined?(:CONSTANT_NAME) }

  # relationships
  it { should have_many(:course_modules) }
  it { should have_many(:institution_users) }
  xit { should have_many(:qualifications) }
  it { should belong_to(:subject_area) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should validate_presence_of(:short_name) }
  it { should validate_uniqueness_of(:short_name) }

  it { should validate_presence_of(:name_url) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:feedback_url) }

  it { should validate_presence_of(:help_desk_url) }

  it { should validate_presence_of(:subject_area_id) }
  it { should validate_numericality_of(:subject_area_id) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Institution).to respond_to(:all_in_order) }

  # class methods
  it { expect(Institution).to respond_to(:get_by_name_url) }

  # instance methods
  it { should respond_to(:destroyable?) }

end
