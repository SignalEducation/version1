# == Schema Information
#
# Table name: vat_codes
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string(255)
#  label      :string(255)
#  wiki_url   :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe VatCode do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  VatCode.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(VatCode.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  xit { should belong_to(:country) }
  it { should have_many(:vat_rates) }

  # validation
  it { should validate_presence_of(:country_id) }
  it { should validate_numericality_of(:country_id) }

  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:label) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(VatCode).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
