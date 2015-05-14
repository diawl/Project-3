class Condition < ActiveRecord::Base
	belongs_to :measurement

	def to_int
	end

	def to_s
		return self.icon
	end
end
