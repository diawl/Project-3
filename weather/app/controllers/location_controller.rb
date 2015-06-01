class LocationController < ApplicationController
	def index
	end
	def locations
		@locations = Location.where(active: true)
		# @locations = Location.all
	end
end
