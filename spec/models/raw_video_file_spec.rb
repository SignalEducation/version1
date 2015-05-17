# == Schema Information
#
# Table name: raw_video_files
#
#  id                     :integer          not null, primary key
#  file_name              :string
#  created_at             :datetime
#  updated_at             :datetime
#  transcode_requested_at :datetime
#  transcode_request_guid :string
#  transcode_result       :string
#  transcode_completed_at :datetime
#  raw_file_modified_at   :datetime
#  aws_etag               :string
#  duration_in_seconds    :integer          default(0)
#  guid_prefix            :string
#

require 'rails_helper'

describe RawVideoFile do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  RawVideoFile.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  it { expect(RawVideoFile.const_defined?(:BASE_URL)).to eq(true) }
  it { expect(RawVideoFile.const_defined?(:INBOX_BUCKET)).to eq(true) }
  it { expect(RawVideoFile.const_defined?(:OUTBOX_BUCKET)).to eq(true) }

  # relationships
  it { should have_many(:course_module_element_videos) }

  # validation
  it { should validate_presence_of(:file_name) }
  it { should validate_length_of(:file_name).is_at_most(255) }

  # callbacks
  it { should callback(:production_set_guid_prefix).before(:create) }
  it { should callback(:production_requests_transcode).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(RawVideoFile).to respond_to(:all_in_order) }
  it { expect(RawVideoFile).to respond_to(:not_yet_assigned) }

  # class methods
  it { expect(RawVideoFile).to respond_to(:get_new_videos) }
  it { expect(RawVideoFile).to respond_to(:check_for_sqs_updates) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:status) }
  it { should respond_to(:url) }

end
