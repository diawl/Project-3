class DataController < ApplicationController

	def location
		@date = params[:date]
		@location = Location.find_by(loc_id: params[:location_id])
	end

	def postcode
		@date = params[:date]
		@postcode = Postcode.find_by(postcode: params[:post_code].to_i)
		@locations = @postcode.locations.where(active: true)
	end
end
