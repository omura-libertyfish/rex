module AuthAccess
  private
    def access_own_history
      unless current_user.history_owner?(@exam_history)
        flash[:error] = "許可されない操作です"
        redirect_to exam_histories_path
      end
    end

    def stop_cheating
      if action_name == 'edit'
        unless @exam_history.pending?
          flash[:error] = "許可されない操作です"
          redirect_to exam_histories_path
        end
      elsif action_name == 'show'
        if @exam_history.pending?
          flash[:error] = "許可されない操作です"
          redirect_to exam_histories_path
        end
      end
    end
end
