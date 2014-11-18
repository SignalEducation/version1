# == Schema Information
#
# Table name: forum_topic_users
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  forum_topic_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

describe ForumTopicUser do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  ForumTopicUser.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(ForumTopicUser.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:forum_topic) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:forum_topic_id) }
  it { should validate_numericality_of(:forum_topic_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(ForumTopicUser).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
