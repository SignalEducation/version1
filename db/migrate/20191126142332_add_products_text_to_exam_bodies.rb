class AddProductsTextToExamBodies < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :has_products, :boolean, default: false
    add_column :exam_bodies, :products_heading, :string
    add_column :exam_bodies, :products_subheading, :text
    add_column :exam_bodies, :products_seo_title, :string
    add_column :exam_bodies, :products_seo_description, :string
  end
end
