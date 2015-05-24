class DataController < ApplicationController

	def show

    	@measurements = Measurement.all
    	
  	end

  	def index

	    #@locations = Location.find(params[:postcode_id])
		
	    #@wdate = Wdate.find(params[:date])
	  
	    #@measurements = @wdate.measurements

	    @locations = Location.all
	  	@measurements = Measurement.all
  end
end
