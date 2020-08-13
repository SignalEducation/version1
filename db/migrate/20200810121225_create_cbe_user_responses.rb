class CreateCbeUserResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :cbe_user_responses do |t|
      t.json :content
      t.text :educator_comment
      t.float :score, default: 0
      t.boolean :correct, default: false

      t.timestamps
    end

    add_reference :cbe_user_responses, :cbe_user_log, index: true
    add_reference :cbe_user_responses, :cbe_response_option, index: true
  end
end
