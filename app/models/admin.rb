class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

 # For Paperclip
  has_attached_file :avatar, :styles => { :medium => "356x356#", :thumb => "32x32#" }, :default_url => "/images/:style/missing.jpg", :url => ":s3_domain_url", :path => "/:class/:attachment/:id_partition/:style/:filename"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

 has_many :users, dependent: :destroy
 has_many :rewards, dependent: :destroy
end
