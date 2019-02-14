class AddPostSignUpRedirectUrlToStaticPages < ActiveRecord::Migration[4.2]
  def change
    add_column :static_pages, :post_sign_up_redirect_url, :string
  end
end
