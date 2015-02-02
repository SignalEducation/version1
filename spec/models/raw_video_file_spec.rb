# == Schema Information
#
# Table name: raw_video_files
#
#  id                     :integer          not null, primary key
#  file_name              :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  transcode_requested_at :datetime
#  transcode_request_guid :string(255)
#  transcode_result       :string(255)
#  transcode_completed_at :datetime
#  raw_file_modified_at   :datetime
#  aws_etag               :string(255)
#  duration_in_seconds    :integer          default(0)
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

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(RawVideoFile).to respond_to(:all_in_order) }

  # class methods
  xit { expect(RawVideoFile).to respond_to(:get_new_videos) }

  # instance methods
  it { should respond_to(:destroyable?) }
  it { should respond_to(:full_name) }
  it { should respond_to(:status) }
  it { should respond_to(:url) }

end
