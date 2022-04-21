class SessionsController < ApplicationController
  skip_before_action :authenticate

  def callback
    auth = request.env['omniauth.auth']
    user = User.find_by(provider: auth['provider'], uid: auth['uid']) || User.create_with_omniauth(auth)
    session[:user_id] = user.id
    user.save
    redirect_to exam_histories_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
