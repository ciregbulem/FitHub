class User < ActiveRecord::Base

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  # For Devise
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :fitbit]

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update
  #validates :fname, presence: true
  #validates :lname, presence: true
  store_accessor :info, :location, :bio, :about, :gender, :birthday, :name, :link

  # For Paperclip
  has_attached_file :avatar, :styles => { :medium => "356x356#", :thumb => "32x32#" }, :default_url => "/images/:style/missing.jpg", :url => ":s3_domain_url", :path => "/:class/:attachment/:id_partition/:style/:filename"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user
      @client = Fitgem::Client.new(
      :consumer_key => ENV["fitbit_app_key"],
      :consumer_secret => ENV["fitbit_app_secret"],
      :token => auth['credentials']['token'],
      :secret => auth['credentials']['secret'],
      :user_id => auth.uid
    )
    
    # If user attempts to sign in or sign up with Fitbit credentials
    if user.nil? && auth.provider == 'fitbit'
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified
        user = User.find_by email: auth.info.email

      if user.nil?
        # Creates new user if Fitbit identity is not found in identity table
        user = User.new(
          fname: auth.info.first_name,
          lname: auth.info.last_name,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20],
          # Would need to add 'uid' column to User table
          fitbit_id: auth.uid,
          oauth_token: auth['credentials']['token'],
          oauth_secret: auth['credentials']['secret'],
          oauth_expires_at: auth.credentials.expires_at,
          fitbit_image: auth.info.image
        )

        user.skip_confirmation! if user.respond_to?(:skip_confirmation)
        user.save!

          # Creates Fitgem client for new user
          @client = Fitgem::Client.new(
          :consumer_key => ENV["fitbit_app_key"],
          :consumer_secret => ENV["fitbit_app_secret"],
          :token => user.oauth_token,
          :secret => user.oauth_secret,
          :user_id => user.fitbit_id
        )

        user.fitbit_image = @client.user_info['user']['avatar150']
        user.daily_cals_goal = @client.daily_goals['goals']['caloriesOut']
        user.daily_steps_goal = @client.daily_goals['goals']['steps']
        user.daily_dist_goal = @client.daily_goals['goals']['distance']
        user.todays_cals = @client.data_by_time_range('/activities/tracker/calories', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-calories"][0]['value']
        user.todays_steps = @client.data_by_time_range('/activities/tracker/steps', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-steps"][0]['value']
        user.todays_dist = @client.data_by_time_range('/activities/tracker/distance', :base_date => @client.format_date('today'), :period => '1d')["activities-tracker-distance"][0]['value']
        user.todays_sleep = @client.data_by_time_range('/sleep/efficiency', :base_date => @client.format_date('today'), :period => '1d')['sleep-efficiency'][0]['value']
        user.save
      else
          # Creates Fitgem client for existing user
          @client = Fitgem::Client.new(
          :consumer_key => ENV["fitbit_app_key"],
          :consumer_secret => ENV["fitbit_app_secret"],
          :token => user.oauth_token,
          :secret => user.oauth_secret,
        )

        user.fitbit_id = auth.uid
        user.fitbit_image = @client.user_info['user']['avatar150']
        user.oauth_token = auth['credentials']['token']
        user.oauth_secret = auth['credentials']['secret']

        user.daily_cals_goal = @client.daily_goals['goals']['caloriesOut']
        user.daily_steps_goal = @client.daily_goals['goals']['steps']
        user.daily_dist_goal = @client.daily_goals['goals']['distance']
        user.save!
      end

      def has_fitbit_data?
        !@client.nil?
      end

    elsif user.nil? == false && auth.provider == 'fitbit'
          # Creates Fitgem client for existing user
          @client = Fitgem::Client.new(
          :consumer_key => ENV["fitbit_app_key"],
          :consumer_secret => ENV["fitbit_app_secret"],
          :token => user.oauth_token,
          :secret => user.oauth_secret,
        )

        user.fitbit_id = auth.uid
        user.oauth_token = auth['credentials']['token']
        user.oauth_secret = auth['credentials']['secret']

        user.daily_cals_goal = 2500
        user.daily_steps_goal = 10000
        user.daily_dist_goal = 5
        user.save!
      
    else
      # Create the user if needed
      if user.nil?

        # Get the existing user by email if the provider gives us a verified email.
        # If no verified email was provided we assign a temporary email and ask the
        # user to verify it on the next step via UsersController.finish_signup
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified
        user = User.find_by email: auth.info.email

        # Create the user if it's a new registration
        if user.nil? && auth.provider == 'facebook'
          user = User.new(
            fname: auth.info.first_name,
            lname: auth.info.last_name,
            #username: auth.info.nickname || auth.uid,
            email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
            temp_email: auth.info.email,
            info: auth.info,
            fb_link: auth.extra.raw_info.link,
            #about: auth.info.bio,
            image: auth.info.image,
            password: Devise.friendly_token[0,20], 
          )
          user.skip_confirmation! if user.respond_to?(:skip_confirmation)
          user.save!
        end
      end
    end
    if auth.provider == 'facebook'
      user.fb_link = auth.extra.raw_info.link
    end
    user.save

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end
    
  belongs_to :admin
  has_many :identities, dependent: :destroy
  validates :email, presence: true
end
