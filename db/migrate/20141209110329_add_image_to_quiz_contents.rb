class AddImageToQuizContents < ActiveRecord::Migration
  def up
    add_attachment :quiz_contents, :image
  end

  def down
    remove_attachment :quiz_contents, :image
  end
end
