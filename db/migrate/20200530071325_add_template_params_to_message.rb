class AddTemplateParamsToMessage < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'hstore'

    add_column :messages, :template_params, :hstore, default: {}
    remove_column :messages, :url, :string
  end
end
