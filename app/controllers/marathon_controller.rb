class MarathonController < ApplicationController
  include AjaxHelper

  def create
    exam_history, user_answers = ExamMaster.build_answers(current_user, params[:exam_type])
    first_user_answer = user_answers.first

    respond_to do |format|
      format.js {
        render ajax_redirect_to(edit_marathon_marathon_answer_path(
          marathon_id: exam_history.id, uuid: first_user_answer.url_uuid))
      }
    end
  end
end
