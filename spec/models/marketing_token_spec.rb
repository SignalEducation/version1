# == Schema Information
#
# Table name: marketing_tokens
#
#  id                    :integer          not null, primary key
#  code                  :string(255)
#  marketing_category_id :integer
#  is_hard               :boolean          default(FALSE), not null
#  is_direct             :boolean          default(FALSE), not null
#  is_seo                :boolean          default(FALSE), not null
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rails_helper'

describe MarketingToken do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  MarketingToken.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(MarketingToken.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:marketing_category) }

  # validation
  it { should validate_presence_of(:code) }

  it { should validate_presence_of(:marketing_category_id) }
  it { should validate_numericality_of(:marketing_category_id) }

  # callbacks

  # scopes
  it { expect(MarketingToken).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
