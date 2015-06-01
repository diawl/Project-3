class LocationController < ApplicationController
	require 'json'
	def index
	end
	def locations
		@locations = Location.where(active: true)
		respond_to do |format|
			format.html
			format.json { render json: JSON.pretty_generate(LocationsPresenter.new(@locations).as_json) }
		end
	end
end
