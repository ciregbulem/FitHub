class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:index, :show]
  layout 'user'

  def index
  	@users = User.paginate(:page => params[:page], :per_page => 3)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
  	@user = current_user
  end

  def destroy
	@user = User.find(params[:id])
	@user.destroy
		   
	redirect_to users_path
  end

  def update

  	# authorize! :update, @user
    respond_to do |format|
      if @user.update(user_params)
        sign_in(@user == current_user ? @user : current_user, :bypass => true)
        format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  end

  # GET/PATCH /users/:id/finish_signup
  def finish_signup
    current_user.email = current_user.temp_email
    # authorize! :update, @user 
    if request.patch? && params[:user] #&& params[:user][:email]
      if current_user.update(user_params)
        @user.skip_reconfirmation! if @user.respond_to?(:skip_confirmation)
        sign_in(current_user, :bypass => true)
        redirect_to current_user, notice: 'Your profile was successfully updated.'
      else
        @show_errors = true
      end
    end
  end

  private

  	private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      accessible = [ :fname, :lname, :email, :about, :avatar ] # extend with your own params
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      params.require(:user).permit(accessible)
    end


end