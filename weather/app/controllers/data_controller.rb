class DataController < ApplicationController

	def show
    	@measurements = Measurement.all    	
  	end

	def show_by_location_id

			@location_id = params[:location_id]

			@location = Location.find_by(loc_id: @location_id)

			puts @location_id
			
			@date = params[:date]
		  
	end

	def show_by_postcode_id

		    #@postcode_id = params[:postcode_id]

			#@locations = Location.find_by(postcode_id: @postcode_id)

			@locations = Location.take(10)

			@date = params[:date]

			@postcode = params[:postcode_id]
			
			puts @date
		    
	end
 
end
