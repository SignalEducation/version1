# == Schema Information
#
# Table name: user_notifications
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  subject_line   :string(255)
#  content        :text
#  email_required :boolean          default(FALSE), not null
#  email_sent_at  :datetime
#  unread         :boolean          default(TRUE), not null
#  destroyed_at   :datetime
#  message_type   :string(255)
#  forum_topic_id :integer
#  forum_post_id  :integer
#  tutor_id       :integer
#  falling_behind :boolean          not null
#  blog_post_id   :integer
#  created_at     :datetime
#  updated_at     :datetime
#

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
  it { expect(UserNotification.const_defined?(:MESSAGE_TYPES)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  xit { should belong_to(:forum_topic) }
  xit { should belong_to(:forum_post) }
  it { should belong_to(:tutor) }
  xit { should belong_to(:blog_post) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:subject_line) }

  it { should validate_presence_of(:content) }

  it { should validate_inclusion_of(:message_type).in_array(UserNotification::MESSAGE_TYPES) }

  it { should validate_numericality_of(:forum_topic_id) }

  it { should validate_numericality_of(:forum_post_id) }

  it { should validate_numericality_of(:tutor_id) }

  it { should validate_numericality_of(:blog_post_id) }

  # callbacks
  it { should callback(:send_email_if_needed).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(UserNotification).to respond_to(:all_in_order) }
  it { expect(UserNotification).to respond_to(:unread) }
  it { expect(UserNotification).to respond_to(:read) }
  it { expect(UserNotification).to respond_to(:deleted) }
  it { expect(UserNotification).to respond_to(:visible) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:send_email_if_needed) }
  it { should respond_to(:mark_as_read) }

end
