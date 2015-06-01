class PredictionController < ApplicationController
	require 'json'

	def post
		@period = params[:period]
		@post_code = params[:post_code]
		@postcode = Postcode.find_by(postcode: params[:post_code].to_i)
		@locations = @postcode.locations.where(active: true)
		# TODO here comes the hashmap with correct information
		@temp = {}
		@temp[:location_id] = 'MELB'
		pred1 = {:time => '13:23', :rain => {:value => '0mm', :probability => '1' }, :temp => {:value => '23', :probability => '1'}}
		pred2 = {:time => '13:23', :rain => {:value => '0mm', :probability => '1' }, :temp => {:value => '23', :probability => '1'}}
		pred = {'0' => pred1, '10' => pred2}
		@temp[:predictions] = pred
		respond_to do |format|
			format.html
			# format.json { render json: JSON.pretty_generate(PostcodePredictionPresenter.new(@locations).as_json) }
			format.json { render json: JSON.pretty_generate(temp.as_json) }
		end
	end

	def location
		@period = params[:period]
		@lat = params[:lat]
		@lon = params[:lon]
		# @location = Location.find_by(lat: @lat, lon: @lon)

		# TODO here comes the hashmap with correct information
		@temp = {}
		@temp[:latitude] = '39.12'
		@temp[:longitude] = '38.49'
		pred1 = {:time => '13:23', :rain => {:value => '0mm', :probability => '1' }, :temp => {:value => '23', :probability => '1'}}
		pred2 = {:time => '13:23', :rain => {:value => '0mm', :probability => '1' }, :temp => {:value => '23', :probability => '1'}}
		pred = {'0' => pred1, '10' => pred2}
		@temp[:predictions] = pred

		respond_to do |format|
			format.html
			format.json { render json: JSON.pretty_generate(temp.as_json) }
		end
	end
end