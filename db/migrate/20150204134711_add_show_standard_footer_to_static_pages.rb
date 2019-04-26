class AddShowStandardFooterToStaticPages < ActiveRecord::Migration[4.2]
  def change
    add_column :static_pages, :show_standard_footer, :boolean, default: true
  end
end
