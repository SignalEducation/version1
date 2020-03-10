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
#  content_seconds_consumed :integer          default("0")
#  subscription_id          :integer
#  account_type             :string
#  content_access           :boolean          default("false")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'rails_helper'

describe StudentAccess do


end
