class AddColumnCategoryExamMasters < ActiveRecord::Migration[5.0]
  def change
    add_column :exam_masters, :category, :integer
  end
end
