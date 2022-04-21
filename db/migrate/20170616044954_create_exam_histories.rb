class CreateExamHistories < ActiveRecord::Migration
  def change
    create_table :exam_histories do |t|
      t.references :user
      t.integer :exam_type
      t.integer :score, default: 0
      t.integer :review_later_count, default: 0
      t.integer :continuous_times, default: 0
      t.boolean :pending, default: true

      t.timestamps null: false
    end
  end
end
