class ChangeAnswerTemplateTypeAttributeName < ActiveRecord::Migration[4.2]
  def change
    rename_column :scenario_answer_templates, :type, :editor_type
  end
end
