class MarathonAnswersController < ApplicationController
  include AuthAccess

  before_action :set_user_answer, only: [:edit, :update]
  before_action :set_exam_history, only: [:edit, :update]
  before_action :access_own_history, only: [:edit, :update]

  def edit
  end

  def update
    respond_to do |format|
      if @user_answer.update(user_answer_params) && @user_answer.correct?
        @exam_history.update(continuous_times: @user_answer.exam_no)

        if @user_answer.next_url_uuid
          format.html { redirect_to edit_marathon_marathon_answer_path(marathon_id: @user_answer.exam_history_id, uuid: @user_answer.next_url_uuid) }
        else
          if current_user.continuous_times < @exam_history.continuous_times
            current_user.update(continuous_times: @exam_history.continuous_times)
          end

          flash[:info] = "全問到達！おめでとうございます！"
          format.html { redirect_to exam_histories_path }
        end
      else
        if current_user.continuous_times < @exam_history.continuous_times
          current_user.update(continuous_times: @exam_history.continuous_times)
        end

        flash[:info] = "今回の到達問題は、#{@exam_history.continuous_times}問だよ！"
        format.html { redirect_to exam_histories_path }
      end
    end
  end

  private
    def set_exam_history
      @exam_history = ExamHistory.find_by(id: params[:marathon_id])
    end

    def set_user_answer
      @user_answer = UserAnswer.find_by(url_uuid: params[:uuid])
    end

    def user_answer_params
      params.require(:user_answer).permit(:answer_1_id, :answer_2_id, :answer_3_id, :answer_4_id)
    end
end
