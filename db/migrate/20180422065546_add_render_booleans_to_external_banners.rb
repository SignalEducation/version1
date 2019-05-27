class AddRenderBooleansToExternalBanners < ActiveRecord::Migration[4.2]
  def change
    add_column :external_banners, :user_sessions, :boolean, index: true, default: false
    add_column :external_banners, :library, :boolean, index: true, default: false
    add_column :external_banners, :subscription_plans, :boolean, index: true, default: false
    add_column :external_banners, :footer_pages, :boolean, index: true, default: false
    add_column :external_banners, :student_sign_ups, :boolean, index: true, default: false
  end
end
