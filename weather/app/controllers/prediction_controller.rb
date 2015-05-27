class PredictionController < ApplicationController
	def post
		@period = params[:period]
		@post_code = params[:post_code]
	end

	def location
		@period = params[:period]
		@lat = params[:lat]
		@lon = params[:lon]
		@location = Location.find_by(lat: @lat, lon: @lon)
	end
end