class Bonus < ActiveRecord::Base
	belongs_to :admin
	validates_presence_of :title
	validates_presence_of :target_unit
	validates_presence_of :goal
end
