# == Schema Information
#
# Table name: system_defaults
#
#  id                               :integer          not null, primary key
#  individual_student_user_group_id :integer
#  corporate_student_user_group_id  :integer
#  corporate_customer_user_group_id :integer
#  created_at                       :datetime
#  updated_at                       :datetime
#

class SystemDefault < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :individual_student_user_group_id, :corporate_student_user_group_id, :corporate_customer_user_group_id

  # Constants

  # relationships
  # todo belongs_to :individual_student_user_group
  # todo belongs_to :corporate_student_user_group
  # todo belongs_to :corporate_customer_user_group

  # validation
  validates :individual_student_user_group_id, presence: true
  validates :corporate_student_user_group_id, presence: true
  validates :corporate_customer_user_group_id, presence: true

  # callbacks

  # scopes
  scope :all_in_order, -> { order(:individual_student_user_group_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

end
