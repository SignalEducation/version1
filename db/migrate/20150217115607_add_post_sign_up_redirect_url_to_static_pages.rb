class AddPostSignUpRedirectUrlToStaticPages < ActiveRecord::Migration
  def change
    add_column :static_pages, :post_sign_up_redirect_url, :string
  end
end
