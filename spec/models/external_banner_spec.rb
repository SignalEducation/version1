# == Schema Information
#
# Table name: external_banners
#
#  id                :integer          not null, primary key
#  name              :string
#  sorting_order     :integer
#  active            :boolean          default(FALSE)
#  background_colour :string
#  text_content      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

describe ExternalBanner do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ExternalBanner.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ExternalBanner.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:background_colour) }

  it { should validate_presence_of(:text_content) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ExternalBanner).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
