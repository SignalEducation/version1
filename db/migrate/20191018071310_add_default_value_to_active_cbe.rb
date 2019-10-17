class AddDefaultValueToActiveCbe < ActiveRecord::Migration[5.2]
  def change
    Cbe.where(active: nil).each do |cbe|
      cbe.update(active: false)
    end

    change_column_default :cbes, :active, true
    change_column_null :cbes, :active, false
  end
end
