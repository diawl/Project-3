class Postcode < ActiveRecord::Base
	has_many :locations
end
