require 'rails_helper'

describe StaticPage do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  StaticPage.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(StaticPage.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships

  # validation
  it { should validate_presence_of(:name) }

  it { should validate_presence_of(:publish_from) }

  it { should validate_presence_of(:publish_to) }

  it { should validate_presence_of(:public_url) }

  it { should validate_presence_of(:head_content) }

  it { should validate_presence_of(:body_content) }

  it { should validate_presence_of(:created_by) }

  it { should validate_presence_of(:updated_by) }

  it { should validate_presence_of(:menu_label) }

  it { should validate_presence_of(:tooltip_text) }

  it { should validate_presence_of(:language) }

  it { should validate_presence_of(:seo_title) }

  it { should validate_presence_of(:seo_description) }

  it { should validate_presence_of(:approved_country_ids) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StaticPage).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
