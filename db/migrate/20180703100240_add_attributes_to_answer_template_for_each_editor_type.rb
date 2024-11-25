class AddAttributesToAnswerTemplateForEachEditorType < ActiveRecord::Migration[4.2]
  def change
    add_column :scenario_answer_templates, :text_editor_content, :text
    add_column :scenario_answer_templates, :spreadsheet_editor_content, :text
    remove_column :scenario_answer_templates, :text_content, :text
  end
end
