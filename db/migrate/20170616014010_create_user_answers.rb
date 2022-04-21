class CreateUserAnswers < ActiveRecord::Migration
  def change
    create_table :user_answers do |t|
      t.string     :url_uuid
      t.integer    :exam_no
      t.string     :type
      t.references :exam_history
      t.references :exam_master
      t.integer :answer_1_id
      t.integer :answer_2_id
      t.integer :answer_3_id
      t.integer :answer_4_id
      t.integer :score
      t.boolean :review_later, default: false
      t.string  :prev_url_uuid
      t.string  :next_url_uuid

      t.timestamps null: false
    end
  end
end
