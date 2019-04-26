class AddMailchimpGuidToHomePages < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :mailchimp_list_guid, :string
    add_column :home_pages, :mailchimp_section_heading, :string
    add_column :home_pages, :mailchimp_section_subheading, :string
    add_column :home_pages, :mailchimp_subscribe_section, :boolean, default: false
  end
end
