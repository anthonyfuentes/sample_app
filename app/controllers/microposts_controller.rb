
class MicropostsController < ApplicationController
  before_action :logged_in_user,  only: [:create, :destroy]
  before_action :correct_user,  only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    micropost.save ? notify_success : handle_failure
  end

  def destroy
    micropost.destroy
    flash[:success] = "Micropost removed"
    redirect_back(fallback_location: root_url)
  end

  private
    attr_reader :micropost

    def micropost_params
      params.require(:micropost).permit(:content)
      # uncomment to enable image upload
      #params.require(:micropost).permit(:content, :picture)
    end

    def notify_success
      flash[:success] = "Micropost created"
      redirect_to root_url
    end

    def handle_failure
      @feed_items = []
      render("static_pages/home")
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if micropost.nil?
    end
end
