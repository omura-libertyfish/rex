class ExamHistoriesController < ApplicationController
  include AjaxHelper
  include AuthAccess

  before_action :set_exam_history, only: [:edit, :update, :show, :retry]
  before_action :access_own_history, only: [:edit, :update, :show, :retry]
  before_action :stop_cheating, only: [:edit, :show]

  def index
    @exam_histories = current_user.exam_histories.certified.page(params[:page])
  end

  def show
    render layout: "exams_scored"
  end

  def retry
    new_exam_history, new_user_answers = ExamMaster.duplicate(current_user, @exam_history)

    @exam_history_id = new_exam_history.id
    @uuid = new_user_answers.first.url_uuid

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def edit
    render layout: "exams"
  end

  def update
    respond_to do |format|
      if @exam_history.be_scored
        current_user.update_best_score(@exam_history)
        flash[:info] = "今回の点数は、#{@exam_history.score}点だよ！"
        format.html { redirect_to exam_histories_path }
      else
        format.html { render :edit }
      end
    end
  end

  def create
    exam_history, user_answers = ExamMaster.build_answers(current_user, params[:exam_type])
    first_user_answer = user_answers.first

    respond_to do |format|
      format.js {
        render ajax_redirect_to(edit_exam_history_user_answer_path(
          exam_history_id: exam_history.id, uuid: first_user_answer.url_uuid))
      }
    end
  end

  private
    def set_exam_history
      @exam_history = ExamHistory.includes(user_answers: :exam_master).find_by(id: params[:id])
    end
end
