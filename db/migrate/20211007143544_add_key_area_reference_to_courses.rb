class AddKeyAreaReferenceToCourses < ActiveRecord::Migration[5.2]
  def change
    add_reference :courses, :key_area, index: true
  end
end
