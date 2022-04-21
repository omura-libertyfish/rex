class MarathonExamAnswer < UserAnswer

  def self.import(exam_history, exam_masters)
    masters, uuids = exam_masters.transpose
    uuids = [*uuids, nil]

    [].tap {|records|
      ActiveRecord::Base.transaction do
        uuids.each_cons(2).with_index(0) do |(current_url_uuid, next_url_uuid), exam_no|
          records << self.create(
            exam_no: exam_no + 1, url_uuid: current_url_uuid, exam_master: masters[exam_no], exam_history: exam_history, next_url_uuid: next_url_uuid
          )
        end
      end
    }
  end
end
