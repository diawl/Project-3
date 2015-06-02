class Wdate < ActiveRecord::Base
	belongs_to :location
	has_many :measurements
end
