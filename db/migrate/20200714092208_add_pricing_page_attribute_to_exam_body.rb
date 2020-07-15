class AddPricingPageAttributeToExamBody < ActiveRecord::Migration[5.2]
  def change
    add_column :exam_bodies, :pricing_heading, :string
    add_column :exam_bodies, :pricing_subheading, :string
    add_column :exam_bodies, :pricing_seo_title, :string
    add_column :exam_bodies, :pricing_seo_description, :string
  end
end
