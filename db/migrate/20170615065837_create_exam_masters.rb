class CreateExamMasters < ActiveRecord::Migration
  def change
    create_table :exam_masters do |t|
      t.string :master_uuid
      t.text :question
      t.text :description
      t.integer :exam_type
      t.integer :answer_1_id
      t.integer :answer_2_id
      t.integer :answer_3_id
      t.integer :answer_4_id

      t.timestamps null: false
    end
  end
end
