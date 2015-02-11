class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:index, :show]
  layout 'user'

  def index
  	@users = User.paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
  end

  def show
    @user = User.find(params[:id])
	def linked?
      @user.oauth_token.present? && @user.oauth_secret.present?
    end

    raise "Account is not linked with a Fitbit account" unless linked?
    @client ||= Fitgem::Client.new(
            :consumer_key => ENV["fitbit_app_key"],
            :consumer_secret => ENV["fitbit_app_secret"],
            :token => @user.oauth_token,
            :secret => @user.oauth_secret,
            :user_id => @user.fitbit_id
          )
    #if @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1d') == nil
    #	flash[:alert] = 'Could not connect to Fitbit. Please try again in a while.'
    #else

	    ## Fitbit Data Breakdown (today, month, year) ## 
	    # Today's Calories
	    @todays_cals = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1d')
	    # Today's Steps
	    @todays_steps = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date('today'), :period => '1d')
	    # Today's Distance
	    @todays_dist = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date('today'), :period => '1d')
	    @todays_sleep = @client.data_by_time_range('/sleep/efficiency', :base_date => @client.format_date('today'), :period => '1d')
	    
	    # Percentage of Daily Goal
	    
	    # Calories
	    @daily_goal_cals_float = @user.daily_cals_goal.to_f # Daily Goal for Calories
	    @todays_cals_float = @todays_cals['activities-tracker-calories'][0]['value'].to_f # Calories burned Today
	    @percentOfCals = ((@todays_cals_float/@daily_goal_cals_float) * 100).round(0).to_s + "%" # Percentage of Calories burned Goal

	    # Steps
	    @daily_goal_steps_float = @user.daily_steps_goal.to_f # Daily Goal for Steps
	    @todays_steps_float = @todays_steps['activities-tracker-steps'][0]['value'].to_f # Steps taken Today
	    @percentOfSteps = ((@todays_steps_float/@daily_goal_steps_float) * 100).round(0).to_s + "%" # Percentage of Steps taken Goal

	    # Miles
	    @daily_goal_dist_float = @user.daily_dist_goal.to_f # Daily Goal for Distance
	    @todays_dist_float = @todays_dist['activities-tracker-distance'][0]['value'].to_f # Distance traveled Today
	    @percentOfDist = ((@todays_dist_float/@daily_goal_dist_float) * 100).round(0).to_s + "%" # Percentage of Distance traveled Goal

	    # Sleep
	    @percentOfSleep = @todays_sleep['sleep-efficiency'][0]['value'].to_s + "%"

	    # Past Month's Calories
	    @months_cals = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1m')
	    # Past Month's Steps
	    @months_steps = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date('today'), :period => '1m')
	    # Past Month's Distance
	    @months_dist = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date('today'), :period => '1m')

	#end
  end # Show END

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