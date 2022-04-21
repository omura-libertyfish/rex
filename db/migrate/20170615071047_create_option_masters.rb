class CreateOptionMasters < ActiveRecord::Migration
  def change
    create_table :option_masters do |t|
      t.text :sentence
      t.references :exam_master

      t.timestamps null: false
    end
  end
end
