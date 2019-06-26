class AddExamBodyToSubscriptionPlans < ActiveRecord::Migration[5.2]

  class SubscriptionPlan < ActiveRecord::Base
  end

  class ExamBody < ActiveRecord::Base
  end

  def up
    add_reference :subscription_plans, :exam_body, foreign_key: true
  end

  def down
    remove_reference :subscription_plans, :exam_body, foreign_key: true
  end
end
