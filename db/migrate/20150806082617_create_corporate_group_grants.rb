class CreateCorporateGroupGrants < ActiveRecord::Migration
  def change
    create_table :corporate_group_grants do |t|
      t.references :corporate_group, index: true
      t.references :exam_level, index: true
      t.references :exam_section, index: true
      t.boolean :compulsory
      t.boolean :restricted

      t.timestamps null: false
    end
  end
end
