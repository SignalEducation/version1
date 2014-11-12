require 'rails_helper'

describe UserNotification do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  UserNotification.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(UserNotification.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:forum_topic) }
  it { should belong_to(:forum_post) }
  it { should belong_to(:tutor) }
  it { should belong_to(:blog_post) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:subject_line) }

  it { should validate_presence_of(:content) }

  it { should validate_presence_of(:email_sent_at) }

  it { should validate_presence_of(:destroyed_at) }

  it { should validate_presence_of(:message_type) }

  it { should validate_presence_of(:forum_topic_id) }
  it { should validate_numericality_of(:forum_topic_id) }

  it { should validate_presence_of(:forum_post_id) }
  it { should validate_numericality_of(:forum_post_id) }

  it { should validate_presence_of(:tutor_id) }
  it { should validate_numericality_of(:tutor_id) }

  it { should validate_presence_of(:blog_post_id) }
  it { should validate_numericality_of(:blog_post_id) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserNotification).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
