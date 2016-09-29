
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  protected
    # before filters

    # confirms user is logged-in
    def logged_in_user
      unless logged_in?
        store_requested_location
        flash[:danger] = "Please log in"
        redirect_to login_url
      end
    end

    # confirms current_user authorized
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless  current_user?(@user)
    end

    # confirms admin user
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
