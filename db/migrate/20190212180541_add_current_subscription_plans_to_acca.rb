class AddCurrentSubscriptionPlansToAcca < ActiveRecord::Migration[5.2]
  class SubscriptionPlan < ActiveRecord::Base
  end

  class Organisation < ActiveRecord::Base
  end

  def up
    acca = Organisation.create(name: "ACCA")
    Organisation.create(name: "AAT")
    Organisation.create(name: "CPD")

    SubscriptionPlan.find_each do |plan|
      plan.organisation_id = acca.id
      plan.save
    end
  end

  def down    
  end
end