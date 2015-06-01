class Rainfall < ActiveRecord::Base
	belongs_to :measurement

	def precip_mm
		self.precip.to_s + 'mm'
	end

	def precip_inch
	end
end
