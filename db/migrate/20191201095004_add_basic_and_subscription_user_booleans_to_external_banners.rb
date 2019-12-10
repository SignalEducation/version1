class AddBasicAndSubscriptionUserBooleansToExternalBanners < ActiveRecord::Migration[5.2]
  def change
    add_column :external_banners, :basic_students, :boolean, default: false
    add_column :external_banners, :paid_students, :boolean, default: false
  end
end
