class LocationController < ApplicationController
	def index
	end
	def locations
		@locations = Location.where(active: true)
	end
end
