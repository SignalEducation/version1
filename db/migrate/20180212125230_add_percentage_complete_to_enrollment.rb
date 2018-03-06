class AddPercentageCompleteToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :percentage_complete, :integer, default: 0
  end
end
