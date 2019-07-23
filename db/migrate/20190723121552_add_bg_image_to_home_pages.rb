class AddBgImageToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :background_image, :string
  end
end
