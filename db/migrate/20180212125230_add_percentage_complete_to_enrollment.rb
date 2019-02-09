class AddPercentageCompleteToEnrollment < ActiveRecord::Migration[4.2]
  def change
    add_column :enrollments, :percentage_complete, :integer, default: 0
  end
end
