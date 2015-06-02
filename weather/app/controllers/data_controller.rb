class DataController < ApplicationController
	require 'json'
	def location
		@date = params[:date]
		@location = Location.find_by(loc_id: params[:location_id])
		@wdate = Wdate.find_by(location_id: @location.id, date: @date)
		@measurements = Measurement.where(wdate_id: @wdate.id)
		# TODO get current temperature and condition to send json representer
		@curtemp = 'current temp missing'
		@curcord = 'current condition missing'
		respond_to do |format|
			format.html
			format.json { render json: JSON.pretty_generate(LocationMeasurements.new(@measurements).as_json(@date, @curtemp, @curcord)) }
		end
	end

	respond_to :json, :html
	def postcode
		@date = params[:date]
		@postcode = Postcode.find_by(postcode: params[:post_code].to_i)
		@locations = @postcode.locations.where(active: true)
		respond_to do |format|
			format.html
			format.json { render json: JSON.pretty_generate(LocationsMeasurements.new(@locations).as_json(@date)) }
		end
	end

end
