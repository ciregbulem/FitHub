class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_filter :authenticate_user!, :except => [:index, :show, :update]
  layout 'user'

  def index
  	@users = User.paginate(:page => params[:page], :per_page => 3).order('created_at DESC')
  end

  def show
    @user = User.find(params[:id])
	  def linked?
      @user.oauth_token.present? && @user.oauth_secret.present?
    end

    #raise "Account is not linked with a Fitbit account" unless linked?
    flash[:alert] = 'Account is not linked to Fitbit' unless linked?
    @client = Fitgem::Client.new(
            :consumer_key => ENV["fitbit_app_key"],
            :consumer_secret => ENV["fitbit_app_secret"],
            :token => @user.oauth_token,
            :secret => @user.oauth_secret,
            :user_id => @user.fitbit_id
          )

    @client.reconnect(@user.oauth_token, @user.oauth_secret)

    #if @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1d') == nil
    #	flash[:alert] = 'Could not connect to Fitbit. Please try again in a while.'
    #else
    if linked?

	    # Percentage of Daily Goals
	    
	    # Calories
      @user.todays_cals = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-calories"][0]['value']
	    @daily_goal_cals_float = @user.daily_cals_goal.to_f # Daily Goal for Calories
	    @todays_cals_float = @user.todays_cals.to_f # Calories burned Today
	    @percentOfTodaysCals = ((@todays_cals_float/@daily_goal_cals_float) * 100).round(0).to_s + "%" # Percentage of Calories burned Goal

	    # Steps
      @user.todays_steps = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-steps"][0]['value']
	    @daily_goal_steps_float = @user.daily_steps_goal.to_f # Daily Goal for Steps
	    @todays_steps_float = @user.todays_steps.to_f # Steps taken Today
	    @percentOfTodaysSteps = ((@todays_steps_float/@daily_goal_steps_float) * 100).round(0).to_s + "%" # Percentage of Steps taken Goal

	    # Miles
      @user.todays_dist = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-distance"][0]['value']
	    @daily_goal_dist_float = @user.daily_dist_goal.to_f # Daily Goal for Distance
	    @todays_dist_float = @user.todays_dist.to_f # Distance traveled Today
	    @percentOfTodaysDist = ((@todays_dist_float/@daily_goal_dist_float) * 100).round(0).to_s + "%" # Percentage of Distance traveled Goal

	    # Sleep
      @todays_sleep = @client.data_by_time_range('/sleep/efficiency', :base_date => @client.format_date('today'), :period => '1d')['sleep-efficiency'][0]['value']
	    @percentOfTodaysSleep = @user.todays_sleep.to_s + "%"

	    
      # Percentage of Weekly Goals

      # Calories
      #@weekly_goal_cals_float = (@user.daily_cals_goal.to_f * 7.0).to_f # Daily Goal for Calories
      #@weeks_cals_float = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date(Date.current().find_beginning_of_week!(:monday)), :period => '1w')["activities-tracker-calories"][0]['value'].to_f # Calories burned this week
      #@percentOfWeeksCals = ((@weeks_cals_float/@weekly_goal_cals_float) * 100).round(0).to_s + "%" # Percentage of Calories burned Goal

      # Steps
      #@weekly_goal_steps_float = (@user.daily_steps_goal.to_f * 7.0).to_f # Daily Goal for Steps
      #@weeks_steps_float = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date(Date.find_beginning_of_week!(:monday)), :period => '1w')["activities-tracker-steps"][0]['value'].to_f # Steps taken this week
      #@percentOfWeeksSteps = ((@weeks_steps_float/@weekly_goal_steps_float) * 100).round(0).to_s + "%" # Percentage of Steps taken Goal

      # Miles
      #@weekly_goal_dist_float = (@user.daily_dist_goal.to_f * 30.0).to_f # Daily Goal for Distance
      #@weeks_dist_float = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date(Date.find_beginning_of_week!(:monday)), :period => '1w')["activities-tracker-distance"][0]['value'].to_f # Distance traveled Today
      #@percentOfWeeksDist = ((@weeks_dist_float/@weekly_goal_dist_float) * 100).round(0).to_s + "%" # Percentage of Distance traveled Goal

      # Sleep
      #@percentOfWeeksSleep = @client.data_by_time_range('/sleep/efficiency', :base_date => @client.format_date(Date.find_beginning_of_week!(:monday)), :period => '1w')['sleep-efficiency'][0]['value'].to_s + "%"



	    # Percentage of Monthly Goals

      # Calories
	    @monthly_goal_cals_float = (@user.daily_cals_goal.to_f * 30.0) # Monthly Goal for Calories
	    @months_cals_float = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date(DateTime.current.change(day: 1)), :end_date => @client.format_date(DateTime.current()))["activities-tracker-calories"][0]['value'].to_f # Calories burned this Month
	    @percentOfMonthsCals = ((@months_cals_float/@monthly_goal_cals_float) * 100).round(0).to_s + "%" # Percentage of Calories burned Goal

	    # Steps
	    @monthly_goal_steps_float = (@user.daily_steps_goal.to_f * 30.0) # Monthly Goal for Steps
	    @months_steps_float = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date(DateTime.current.change(day: 1)), :end_date => @client.format_date(DateTime.current()))["activities-tracker-steps"][0]['value'].to_f # Steps taken Today
	    @percentOfMonthsSteps = ((@months_steps_float/@monthly_goal_steps_float) * 100).round(0).to_s + "%" # Percentage of Steps taken Goal

	    # Miles
	    @monthly_goal_dist_float = (@user.daily_dist_goal.to_f * 30.0) # Monthly Goal for Distance
	    @months_dist_float = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date(DateTime.current.change(day: 1)), :end_date => @client.format_date(DateTime.current()))["activities-tracker-distance"][0]['value'].to_f # Distance traveled Today
	    @percentOfMonthsDist = ((@months_dist_float/@monthly_goal_dist_float) * 100).round(0).to_s + "%" # Percentage of Distance traveled Goal

	    # Sleep
	    @percentOfMonthsSleep = @client.data_by_time_range('/sleep/efficiency', :base_date => @client.format_date(DateTime.current.change(day: 1)), :end_date => @client.format_date(DateTime.current()))['sleep-efficiency'][0]['value'].to_s + "%"
	    #@percentOfMonthsSleep = 60.to_s + "%"
    end
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
        if user_signed_in? && admin_signed_in? == false
          sign_in(@user == current_user ? @user : current_user, :bypass => true)
          format.html { redirect_to @user, notice: 'Your profile was successfully updated.' }
          format.json { head :no_content }
        end
        if admin_signed_in?
          @user.admin_id = current_admin.id
          @user.save
          redirect_to @user, notice: "Client has been successfully added to your roster."
        end
        format.html {}
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

  def refresh
    @user = User.find(params[:id])
    @client = Fitgem::Client.new(
        :consumer_key => ENV["fitbit_app_key"],
        :consumer_secret => ENV["fitbit_app_secret"],
        :token => @user.oauth_token,
        :secret => @user.oauth_secret,
        :user_id => @user.fitbit_id
      )
    @client.reconnect(@user.oauth_token, @user.oauth_secret)
    @user.todays_cals = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-calories"][0]['value']
    @user.todays_steps = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-steps"][0]['value']
    @user.todays_dist = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-distance"][0]['value']
    @user.todays_sleep = @client.data_by_time_range('/sleep/efficiency', :base_date => @client.format_date('today'), :period => '1d')['sleep-efficiency'][0]['value']
    @user.save
  end

  def add_user_to_roster
    @user = User.find(params[:id])
    @user.admin_id = curren_admin.id
    @user.save!

    respond_to do |format|
      format.json {render :json => @user.to_json}
    end
  end

  private

  	private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      accessible = [ :fname, :lname, :email, :about, :avatar, :info ] # extend with your own params
      accessible << [ :password, :password_confirmation ] unless params[:user][:password].blank?
      params.require(:user).permit(accessible)
    end


end