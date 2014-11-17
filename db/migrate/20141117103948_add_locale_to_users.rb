class AddLocaleToUsers < ActiveRecord::Migration
  def up
    add_column :users, :locale, :string
    User.all.update_all(locale: 'en')
  end
  def down
    remove_column :users, :locale
  end
end
