class AddExamNumberAndMembershipNumberToInstitutionUser < ActiveRecord::Migration
  def change
    add_column :institution_users, :exam_number, :string
    add_column :institution_users, :membership_number, :string
  end
end
