class Rainfall < ActiveRecord::Base
	belongs_to :measurement

	def precip_mm
	end

	def precip_inch
	end
end
