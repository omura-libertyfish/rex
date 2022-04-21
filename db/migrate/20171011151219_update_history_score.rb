class UpdateHistoryScore < ActiveRecord::Migration
  def change
    User.all.each do |user|
      user.best_silver_score = user.exam_histories.where(exam_type: 0).maximum(:score) || 0
      user.best_gold_score = user.exam_histories.where(exam_type: 1).maximum(:score) || 0
      user.save!
    end
  end
end
