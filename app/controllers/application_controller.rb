class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?

  before_action :authenticate

  private
    def current_user
      return unless session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end

    def logged_in?
      !!session[:user_id] && current_user
    end

    def authenticate
      return if logged_in?
      redirect_to root_path
    end
end
