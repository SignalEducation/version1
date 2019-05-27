class RemoveHomePageAttributes < ActiveRecord::Migration[5.2]
  def change
    remove_column :home_pages, :header_heading, :string
    remove_column :home_pages, :header_paragraph, :text
    remove_column :home_pages, :header_button_text, :string
    remove_column :home_pages, :header_button_link, :string
    remove_column :home_pages, :header_button_subtext, :string
    remove_column :home_pages, :mailchimp_section_heading, :string
    remove_column :home_pages, :mailchimp_section_subheading, :string
    remove_column :home_pages, :mailchimp_subscribe_section, :boolean, default: false
    rename_column :home_pages, :background_image, :logo_image
  end
end
