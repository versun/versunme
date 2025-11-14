class SessionsController < ApplicationController
  allow_unauthenticated_access

  def new
  end

  def create
    if user = User.find_by_user_name_within_site(params[:user_name], current_site).authenticate(params[:password])
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Signed in successfully."
    else
      redirect_to new_session_path, alert: "Invalid username or password."
    end
  rescue NoMethodError
    redirect_to new_session_path, alert: "Invalid username or password."
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "Signed out successfully."
  end
end
