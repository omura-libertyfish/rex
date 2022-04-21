class UserAnswer < ApplicationRecord
  self.primary_key = :url_uuid

  belongs_to :exam_master
  belongs_to :exam_history

  delegate :question, :description, :option_masters, :master_uuid, to: :exam_master

  has_order :answer_ids, columns: [:answer_1_id, :answer_2_id, :answer_3_id, :answer_4_id]

  scope :review_later, -> {
    where(review_later: true)
  }

  def self.import(exam_history, exam_masters)
    masters, uuids = exam_masters.transpose
    uuids = [nil, *uuids, nil]

    [].tap {|records|
      ActiveRecord::Base.transaction do
        uuids.each_cons(3).with_index(0) do |(prev_url_uuid, current_url_uuid, next_url_uuid), exam_no|
          records << self.create(
            exam_no: exam_no + 1, url_uuid: current_url_uuid, exam_master: masters[exam_no], exam_history: exam_history,
            prev_url_uuid: prev_url_uuid, next_url_uuid: next_url_uuid
          )
        end
      end
    }
  end

  def answer_id_indexes
    [*1..4].select{|index| __send__("answer_#{index}_id").present?}
  end

  def correct?
    answer_ids == exam_master.answer_ids
  end

  def answered?
    (answer_1_id || answer_2_id || answer_3_id || answer_4_id) == nil
  end
end
