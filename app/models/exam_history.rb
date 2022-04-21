class ExamHistory < ApplicationRecord
  has_many :user_answers, -> { order("exam_no ASC") }
  belongs_to :user

  accepts_nested_attributes_for :user_answers

  scope :certified, -> { where(exam_type: [0, 1]).order('created_at desc') }

  enum exam_type: { silver: 0, gold: 1, marathon: 2 }

  paginates_per 6  # 1ページあたり6項目表示

  def review_later_count
    user_answers.review_later.select(:id).count
  end

  def be_scored
    score = 0
    user_answers.each do |user_answer|
      if user_answer.correct?
        user_answer.score = 2
        score += 2
      else
        user_answer.score = 0
      end
    end

    self.pending = false
    self.score   = score

    save!
  end

  def exam_master_uuids
    user_answers.map{|user_answer| user_answer.master_uuid}
  end
end
