class ChangeOrganisationToExamBody < ActiveRecord::Migration[5.2]
  def change
    remove_reference :subscription_plans, :organisation, index: true, foreign_key: true
  end
end
