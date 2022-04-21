class User < ApplicationRecord
  has_many :exam_histories

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['nickname']
      user.oauth_token = auth['credentials']['token']
      user.image = auth['info']['image']
      user.best_gold_score = 0
      user.best_silver_score = 0
      user.continuous_times = 0
    end
  end

  def history_owner?(exam_history)
    self.id == exam_history.user_id
  end

  def update_best_score(exam_history)
    if exam_history.gold?
      return if exam_history.score < best_gold_score
      update(best_gold_score: exam_history.score)
    elsif exam_history.silver?
      return if exam_history.score < best_silver_score
      update(best_silver_score: exam_history.score)
    end
  end
end
