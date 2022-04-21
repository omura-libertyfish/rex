class ExamMaster < ApplicationRecord
  has_many :option_masters
  has_many :user_answers

  enum exam_type: { silver: 0, gold: 1 }
  enum category: {
    execution_environment: 0,
    grammar: 1,
    object_orientation: 2,
    built_in_library: 3,
    standard_attached_library: 4,
    difficult_question: 5
    }, _prefix: true

  has_order :answer_ids, columns: [:answer_1_id, :answer_2_id, :answer_3_id, :answer_4_id]

  accepts_nested_attributes_for :option_masters

  # カテゴリー毎の出題数
  SILVER_CATEGORIES = { grammar: 12, object_orientation: 5, built_in_library: 33 }
  GOLD_CATEGORIES = {
    execution_environment: 2,
    grammar: 14,
    object_orientation: 21,
    built_in_library: 8,
    standard_attached_library: 4,
    difficult_question: 1
  }

  def self.randm_select_by(exam_type, times: 50)
    questions =[]
    categories = if exam_type == 'silver'
      SILVER_CATEGORIES
    elsif exam_type == 'gold'
      GOLD_CATEGORIES
    end
    categories.each do |category, questions_number|
      questions << find(where(exam_type: exam_type, category: category).pluck(:id).shuffle[0...questions_number])
    end
    questions.flatten!.shuffle!.zip(Array.new(times){ SecureRandom.uuid })
  end

  def self.randm_select(times: 50)
    where(id: [*1..count].sample(times)).zip(Array.new(times){ SecureRandom.uuid })
  end

  def self.select_by(master_uuids)
    where(master_uuid: master_uuids).zip(Array.new(master_uuids.count){ SecureRandom.uuid })
  end

  def self.build_answers(current_user, exam_type)
    exam_history = ExamHistory.create(user: current_user, exam_type: exam_type)

    user_answers =
      case exam_type
      when "silver", "gold"
        exam_masters = ExamMaster.randm_select_by(exam_type)
        UserAnswer.import(exam_history, exam_masters)
      when "marathon"
        exam_masters = ExamMaster.randm_select(times: 100)
        MarathonExamAnswer.import(exam_history, exam_masters)
      end

    [exam_history, user_answers]
  end

  def self.duplicate(current_user, exam_history)
    new_exam_history = ExamHistory.create(user: current_user, exam_type: exam_history.exam_type)
    new_user_answers = UserAnswer.import(new_exam_history, ExamMaster.select_by(exam_history.exam_master_uuids))

    [new_exam_history, new_user_answers]
  end
end
