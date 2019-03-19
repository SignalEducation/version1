class AddExamBodyToSubscriptionPlans < ActiveRecord::Migration[5.2]

  class SubscriptionPlan < ActiveRecord::Base
  end

  class ExamBody < ActiveRecord::Base
  end
  
  def up
    add_reference :subscription_plans, :exam_body, foreign_key: true

    acca = ExamBody.create(name: 'ACCA', url: 'https://www.accaglobal.com/uk/en.html')
    ExamBody.create(name: 'AAT', url: 'https://www.accaglobal.com/uk/en.html')
    ExamBody.create(name: 'CPD', url: 'https://www.accaglobal.com/uk/en.html')

    SubscriptionPlan.find_each do |plan|
      plan.exam_body_id = acca.id
      plan.save
    end
  end

  def down
    remove_reference :subscription_plans, :exam_body, foreign_key: true
  end
end
