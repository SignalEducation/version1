class AddShowStandardFooterToStaticPages < ActiveRecord::Migration
  def change
    add_column :static_pages, :show_standard_footer, :boolean, default: true
  end
end
