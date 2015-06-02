class Temperature < ActiveRecord::Base
	belongs_to :measurement

	def fahrenheit
	end

	def celsius
		return self.temp
	end
end
