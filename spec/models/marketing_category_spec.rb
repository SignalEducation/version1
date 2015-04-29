# == Schema Information
#
# Table name: marketing_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe MarketingCategory do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  MarketingCategory.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(MarketingCategory.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should have_many(:marketing_tokens) }

  # validation
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(MarketingCategory).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { shoudl respond_to(:editable?)}

end
