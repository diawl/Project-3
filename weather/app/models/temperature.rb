class Temperature < ActiveRecord::Base
	belongs_to :measurement

	def fahrenheit
	end

	def celsius
	end
end
