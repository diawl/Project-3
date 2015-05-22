class Measurement < ActiveRecord::Base
	belongs_to :wdate
	has_one :condition
	has_one :temperature 
	has_one :rainfall 
	has_one :wind_direction 
	has_one :wind_speed

	#FIXME: rainfall need to change
	def to_hash
		return {"time"=>self.timestamp,"temp"=>self.temperature,"precip"=>self.rainfall.precip,"wind_direction"=>self.wind_direction.direction,"wind_speed"=>self.wind_speed.km_h}
	end
end
