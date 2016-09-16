
class SessionsController < ApplicationController
  def new
  end

  def create
    authentic_user? ? successful_login : unsuccessful_login
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

    attr_reader :user

    def user
      @user ||= User.find_by(email: params[:session][:email].downcase)
    end

    def authentic_user?
      user && user.authenticate(params[:session][:password])
    end

    def successful_login
      log_in user
      remember user if params[:session][:remember_me] == "1"
      redirect_to user
    end

    def unsuccessful_login
      flash.now[:danger] = 'Log in information not quite right'
      render 'new'
    end
end
