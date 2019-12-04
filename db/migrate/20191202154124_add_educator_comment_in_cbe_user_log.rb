class AddEducatorCommentInCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_user_logs, :educator_comment, :text
  end
end
