# == Schema Information
#
# Table name: content_pages
#
#  id              :integer          not null, primary key
#  name            :string
#  public_url      :string
#  seo_title       :string
#  seo_description :text
#  text_content    :text
#  h1_text         :string
#  h1_subtext      :string
#  nav_type        :string
#  footer_link     :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  active          :boolean          default(FALSE)
#

require 'rails_helper'

describe ContentPage do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ContentPage.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ContentPage.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:public_url) }

  it { should validate_presence_of(:seo_title) }

  it { should validate_presence_of(:seo_description) }

  it { should validate_presence_of(:text_content) }

  it { should validate_presence_of(:h1_text) }

  it { should validate_presence_of(:h1_subtext) }

  it { should validate_presence_of(:nav_type) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ContentPage).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
