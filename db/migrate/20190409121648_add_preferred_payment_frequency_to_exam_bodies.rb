class AddPreferredPaymentFrequencyToExamBodies < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :preferred_payment_frequency, :integer
  end
end
