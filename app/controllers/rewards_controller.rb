class RewardsController < ApplicationController
	before_action :authenticate_admin!, :except => [:index, :show]
	layout 'application'
	def new
		@reward = Reward.new
	end
	
	def create
		@reward = Reward.new(reward_params)
		@reward.admin_id = current_admin.id
		@reward.company = current_admin.insurance_provider
		if @reward.save
			@reward.save
			redirect_to @reward
		else
			render 'new'
		end
	end
	
	def show
		@reward = Reward.find(params[:id])
	end
	
	def index
  		@rewards = Reward.paginate(:page => params[:page], :per_page => 4)
  		@rewards = @rewards.reverse_order
  		@admins = Admin.paginate(:page => params[:page], :per_page => 2)
  		@admins = @admins.reverse_order
	end
	
	def edit
		if current_admin.id == Reward.find(params[:id]).admin_id
			@reward = Reward.find(params[:id])
		else
			flash[:alert] = "Whoops! You can only edit bonuses you created."
		end
	end
	
	def update
		@reward = Reward.find(params[:id])
		
		if @reward.update(reward_params)
			redirect_to @reward
		else
			render 'edit'
		end
	end
	
	def destroy
		if current_admin.id == Reward.find(params[:id]).admin_id
			@reward = Reward.find(params[:id])
			@reward.destroy
			redirect_to rewards_path
		else
			flash[:alert] = "Whoops! You can only delete bonuses you created."
			redirect_to current_admin
		end
	end
		      
	private
		def reward_params
			params.require(:reward).permit(:title, :description, :reward, :target_unit, :goal, :period)
		end
end