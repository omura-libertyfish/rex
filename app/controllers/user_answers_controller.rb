class UserAnswersController < ApplicationController
  include AuthAccess

  before_action :set_user_answer, only: [:show, :edit, :update]
  before_action :set_exam_history, only: [:show, :edit, :update]
  before_action :access_own_history, only: [:show, :edit, :update]
  before_action :stop_cheating, only: [:edit, :show]

  def show
    render layout: "user_answers_scored"
  end

  def edit
  end

  def update
    respond_to do |format|
      before_review_later = @user_answer.review_later

      if @user_answer.update(user_answer_params)
        if before_review_later != @user_answer.review_later
          @exam_history.update(review_later_count: @exam_history.review_later_count)
        end

        if @user_answer.next_url_uuid
          format.html { redirect_to edit_exam_history_user_answer_path(exam_history_id: @user_answer.exam_history_id, uuid: @user_answer.next_url_uuid) }
        else
          format.html { redirect_to edit_exam_history_path(@exam_history) }
        end
      else
        format.html { render :edit }
      end
    end
  end

  private
    def set_exam_history
      @exam_history = ExamHistory.find_by(id: params[:exam_history_id])
    end

    def set_user_answer
      @user_answer = UserAnswer.find_by(url_uuid: params[:uuid])
    end

    def user_answer_params
      params.require(:user_answer).permit(:answer_1_id, :answer_2_id, :answer_3_id, :answer_4_id, :review_later)
    end
end
