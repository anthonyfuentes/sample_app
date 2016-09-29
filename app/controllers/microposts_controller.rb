
class MicropostsController < ApplicationController
  before_action :logged_in_user,  only: [:create, :destroy]

  def create
    micropost.save ? notify_success : render('static_pages/home')
  end

  def destroy
    # allow destruction by author or admin
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def micropost
      @micropost ||= current_user.microposts.build(micropost_params)
    end

    def notify_success
      flash[:success] = "Micropost created"
      redirect_to root_url
    end

end
