# == Schema Information
#
# Table name: faq_sections
#
#  id            :integer          not null, primary key
#  name          :string
#  name_url      :string
#  description   :text
#  active        :boolean          default(TRUE)
#  sorting_order :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

describe FaqSection do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  FaqSection.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  subject { FactoryBot.build(:faq_section) }

  # Constants

  # relationships

  # validation
  it { should_not validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_length_of(:name).is_at_most(255) }

  it { should validate_presence_of(:name_url) }
  it { should validate_uniqueness_of(:name_url) }
  it { should validate_length_of(:name_url).is_at_most(255) }

  it { should validate_presence_of(:sorting_order) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(FaqSection).to respond_to(:all_active) }
  it { expect(FaqSection).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }


end
