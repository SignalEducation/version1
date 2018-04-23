class CreateFaqs < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.string :name, index: true
      t.string :name_url, index: true
      t.boolean :active, index: true, default: true
      t.integer :sorting_order
      t.integer :faq_section_id, index: true
      t.text :question_text, index: true
      t.text :answer_text

      t.timestamps null: false
    end
  end
end
