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
		puts '///////////////'
		# puts @postcode.locations.where(active: true).wdates.to_json
		# puts @locations.to_json
		# puts @postcode.locations.first.wdates.first.measurements.to_json
		puts @locations.first.wdates.first.measurements.to_json
		# @wdate = Wdate.where(location_id: @locations.id, date: @date)
		# @wdate = Wdate.find(location_id: @locations, date: @date)
		# @measurements = Measurement.where(wdate_id: @wdate)
		# puts '//------measurements'
		# puts @wdates.to_json
		# puts @measurements.temperatures.to_json

		# @locations.each do |obj|
		# 	if @object.wdates.measurements.nil?
		# 		date: date1,
		# 				locations: obj.map { |o| LocationPresenter.new(o)}
		# 	else
    #
		# 	end
		# end

		respond_to do |format|
			format.html
			format.json { render json: JSON.pretty_generate(LocationsMeasurements.new(@locations).as_json(@date)) }
			# format.json { render json: @locations.where(active: true).first.wdates.to_json }
		end
	end

end
