# == Schema Information
#
# Table name: student_accesses
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  trial_started_date       :datetime
#  trial_ending_at_date     :datetime
#  trial_ended_date         :datetime
#  trial_seconds_limit      :integer
#  trial_days_limit         :integer
#  content_seconds_consumed :integer          default(0)
#  subscription_id          :integer
#  account_type             :string
#  content_access           :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

describe StudentAccess do

  # attr-accessible
  black_list = %w(id created_at updated_at)
  StudentAccess.column_names.each do |column_name|
    if black_list.include?(column_name)
      it { should_not allow_mass_assignment_of(column_name.to_sym) }
    else
      it { should allow_mass_assignment_of(column_name.to_sym) }
    end
  end

  # Constants
  #it { expect(StudentAccess.const_defined?(:CONSTANT_NAME)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should belong_to(:subscription) }

  # validation
  it { should validate_presence_of(:user_id) }
  it { should validate_numericality_of(:user_id) }

  it { should validate_presence_of(:trial_start_date) }

  it { should validate_presence_of(:trial_end_date) }

  it { should validate_presence_of(:trial_seconds_limit) }

  it { should validate_presence_of(:trial_days_limit) }

  it { should validate_presence_of(:content_seconds_consumed) }

  it { should validate_presence_of(:subscription_id) }
  it { should validate_numericality_of(:subscription_id) }

  it { should validate_presence_of(:account_type) }

  # callbacks
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(StudentAccess).to respond_to(:all_in_order) }

  # class methods

  # instance methods
  it { should respond_to(:destroyable?) }

  pending "Please review #{__FILE__}"

end
