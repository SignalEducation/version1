# == Schema Information
#
# Table name: completion_certificates
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  subject_course_user_log_id :integer
#  guid                       :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

require 'rails_helper'

describe CompletionCertificate do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  CompletionCertificate.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:subject_course_user_log) }

  # validation
  it { should validate_presence_of(:user_id) }

  it { should validate_presence_of(:subject_course_user_log_id) }

  it { should validate_presence_of(:guid) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(CompletionCertificate).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

end
