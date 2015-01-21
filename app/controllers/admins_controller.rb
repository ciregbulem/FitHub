class AdminsController < ApplicationController
  before_action :set_admin, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_admin!, :except => [:index, :show]

  def index
  	@admins = Admin.paginate(:page => params[:page], :per_page => 3)
  end

  def show
    @admin = admin.find(params[:id])
	@users = User.where(:admin_id => @admin.id).paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
  end

  def edit
  	@admin = current_admin
  end

  def destroy
	@admin = admin.find(params[:id])
	@admin.destroy
		   
	redirect_to admins_path
  end


  private

  	private
    def set_admin
      @admin = admin.find(params[:id])
    end

    def admin_params
      accessible = [ :fname, :lname, :email, :about, :avatar ] # extend with your own params
      accessible << [ :password, :password_confirmation ] unless params[:admin][:password].blank?
      params.require(:admin).permit(accessible)
    end


end