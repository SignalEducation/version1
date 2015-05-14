# == Schema Information
#
# Table name: static_page_uploads
#
#  id                  :integer          not null, primary key
#  description         :string(255)
#  static_page_id      :integer
#  created_at          :datetime
#  updated_at          :datetime
#  upload_file_name    :string(255)
#  upload_content_type :string(255)
#  upload_file_size    :integer
#  upload_updated_at   :datetime
#

require 'rails_helper'

describe StaticPageUpload do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  StaticPageUpload.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(StaticPageUpload.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:static_page) }

  # validation
  it { should validate_presence_of(:description) }
  it { should validate_length_of(:description).is_at_most(255) }

  it { should_not validate_presence_of(:static_page_id) }
  it { should validate_numericality_of(:static_page_id) }

  it { should validate_length_of(:upload_file_name).is_at_most(255) }
  it { should validate_length_of(:upload_content_type).is_at_most(255) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StaticPageUpload).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
