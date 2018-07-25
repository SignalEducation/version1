class ChangeAnswerTemplateTypeAttributeName < ActiveRecord::Migration
  def change
    rename_column :scenario_answer_templates, :type, :editor_type
  end
end
