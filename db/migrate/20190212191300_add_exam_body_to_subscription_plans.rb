class AddExamBodyToSubscriptionPlans < ActiveRecord::Migration[5.2]

  class SubscriptionPlan < ApplicationRecord
  end

  class ExamBody < ApplicationRecord
  end

  def up
    add_reference :subscription_plans, :exam_body, foreign_key: true
  end

  def down
    remove_reference :subscription_plans, :exam_body, foreign_key: true
  end
end
