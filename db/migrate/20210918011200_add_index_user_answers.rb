class AddIndexUserAnswers < ActiveRecord::Migration
  def change
    add_index :user_answers, :url_uuid
    add_index :user_answers, :exam_history_id
  end
end
