
module SessionsHelper

  # logs in given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # creates persistent session for given user
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # logs out current_user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # returns current logged-in user (if any)
  def current_user
    @current_user = temporary_session? ? temporary_user : remembered_user
  end

  def current_user?(user)
    user == current_user
  end

  # true/ false user is logged in
  def logged_in?
    !current_user.nil?
  end

  # redirects to stored location or default
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # stores requested url
  def store_requested_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  private

    attr_writer :current_user

    # returns user_id/ or nil
    def temporary_session?
      session[:user_id]
    end

    # returns user based on session[:user_id] if no @curent_user
    def temporary_user
      @current_user ||= User.find_by_id(session[:user_id])
    end

    # returns user based on permanent session cookies
    def remembered_user#(user_id)
      user = User.find_by_id(cookies.signed[:user_id])
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        return user
      end
    end

    # ends persistent session
    def forget(user)
      user.forget
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end
end
