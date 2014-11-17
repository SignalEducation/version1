# == Schema Information
#
# Table name: forum_posts
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  content                   :text
#  forum_topic_id            :integer
#  blocked                   :boolean          default(FALSE), not null
#  response_to_forum_post_id :integer
#  created_at                :datetime
#  updated_at                :datetime
#

require 'rails_helper'

describe ForumPost do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ForumPost.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ForumPost.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  xit { should belong_to(:forum_topic) }
  xit { should belong_to(:response_to_forum_post) }
  it { should have_many(:response_posts) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:content) }

  it { should validate_presence_of(:forum_topic_id) }
  it { should validate_numericality_of(:forum_topic_id) }

  it { should validate_numericality_of(:response_to_forum_post_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ForumPost).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:background_colour) }

end
