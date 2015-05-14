class WindDirection < ActiveRecord::Base
	belongs_to :measurement

	def direction
	end
end
