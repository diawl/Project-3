class WindSpeed < ActiveRecord::Base
	belongs_to :measurement

	def km_h
	end

	def mile_h
	end
end
