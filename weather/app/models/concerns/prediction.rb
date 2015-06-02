class Prediction
	def initialize(location, period)
		@location=location
		@period=period
	end

	def genPrediction
		samples = getSamples(location, period)
		coe = getRegression(samples)
		coe.each do |c|
			stat = genStatistics(c)
		end
	end

	def getSamples(location, period)
		samples=[]
		if Location.measurements.count >= 100
			return Location.measurements.order(timestamp: :desc)take(100)
		else
			return Location.measurements.order(timestamp: :desc)
		end
	end

	def genStatistics(regression)
		stat = []
		coefficients = regression["coe"]
		case regression["type"]
		when "linear"
			stat << coefficients[0]*x + coefficients[1]
		when "exponential"
			stat << oefficients[0]*(Math::E ** (coefficients[1]*x) ) 
		when "logarithmic"
			stat << coefficients[0]*Math.log(x) + coefficients[1]
		when "polynomial"
			res = 0
			coefficients.each_with_index do |coe,index|
				res += coe * x ** index
			end
			stat << res
		else
			return nil
		end
		return stat
	end

	def getRegression(samples)
		r = Regression.new(samples)
		return .getRegression
	end
end