# == Schema Information
#
# Table name: blog_posts
#
#  id                 :integer          not null, primary key
#  home_page_id       :integer
#  sorting_order      :integer
#  title              :string
#  description        :text
#  url                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#

require 'rails_helper'

describe BlogPost do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  BlogPost.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(BlogPost.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:home_page) }

  # validation
  it { should validate_presence_of(:home_page_id) }
  it { should validate_numericality_of(:home_page_id) }

  it { should validate_presence_of(:sorting_order) }

  it { should validate_presence_of(:title) }

  it { should validate_presence_of(:description) }

  it { should validate_presence_of(:url) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(BlogPost).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
