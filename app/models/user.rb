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
  has_attached_file :avatar, :styles => { :medium => "356x356#", :thumb => "32x32#" }, :default_url => "/images/:style/missing.png", :url => ":s3_domain_url", :path => "/:class/:attachment/:id_partition/:style/:filename"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  # For Papercrop
  crop_attached_file :avatar

  def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    user = signed_in_resource ? signed_in_resource : identity.user
    
    if user.nil? && auth.provider == 'fitbit'
        email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
        email = auth.info.email if email_is_verified
        user = User.find_by email: auth.info.email

      if user.nil?
        user = User.new(
          fname: auth.info.first_name,
          lname: auth.info.last_name,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20],
          # Would need to add 'uid' column to User table
          fitbit_id: auth.uid,
          oauth_token: auth['credentials']['token'],
          oauth_secret: auth['credentials']['secret'],
          oauth_expires_at: auth.credentials.expires_at
        )
        user.skip_confirmation! if user.respond_to?(:skip_confirmation)
        user.save!

      else


      end

      def has_fitbit_data?
        !@client.nil?
      end

      def unit_measurement_mappings
        @unit_mappings = {
          :distance => @client.label_for_measurement(:distance),
          :duration => @client.label_for_measurement(:duration),
          :elevation => @client.label_for_measurement(:elevation),
          :height => @client.label_for_measurement(:height),
          :weight => @client.label_for_measurement(:weight),
          :measurements => @client.label_for_measurement(:measurements),
          :liquids => @client.label_for_measurement(:liquids),
          :blood_glucose => @client.label_for_measurement(:blood_glucose)
        }
      end
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
  validates :email, presence: true
end
