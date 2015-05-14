class Measurement < ActiveRecord::Base
	belongs_to :wdate
	has_one :condition, :temperature, :rainfall, :wind_direction, :wind_speed

	#FIXME: rainfall need to change
	def to_hash
		return {"time"=>self.timestamp,"temp"=>,"precip"=>self.rainfall.precip,"wind_direction"=>self.wind_direction.direction,"wind_speed"=>self.wind_speed.km_h}
	end
end
