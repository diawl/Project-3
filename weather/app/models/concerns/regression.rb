class Regression
	def initialize(samples)
		@samples = samples.reverse
		@types = ["linear","exponential","logarithmic","polynomial"]
		@x_array = []
		@y_array = []
		@temp = []
		@rain = []
		@speed = []
		@direction = []
		@time = []
		@samples.each do |measurement|
			@temp << measurement.temperature.temp
			@rain << measurement.rainfall.precip
			@speed = measurement.wind_direction.bearing
			@direction = measurement.wind_speed.speed
			@time << measurement.timestamp
		end
		@y_array << @temp
		@y_array << @rain
		@y_array << @speed
		@y_array << @direction
		@zero = @time[0]
		@time.each{|time| @x_array << 1+(time - @zero)/60/10 }
	end

	def getRegression
		coefficients = []
		@y_array.each do |y_array|
			vars = []
			coes = []
			types = []
			@types.each do |type|
				ret = regression(type, @x_array, y_array)
				if ret != nil
					vars << ret["var"]
					coes << ret["coe"]
					types << ret["type"]
				end
			end
			index = vars.index(vars.min)
			coefficients << {"coe"=>coes[index],"var"=>vars[index],"type"=>types[index]}
		end
		return coefficients
	end

	def regression(type, x, y)
		x_array = x
		y_array = y
		coefficients = Array.new
		variance=0.0

		case type 
		when "linear"
			variance=0.0
			fit_y=Array.new(x_array.size, 0.0)
			square=0.0
			coefficients = linear(x_array, y_array)
			x_array.each_with_index{|x,index| fit_y[index] += coefficients[0]*x + coefficients[1]}
			y_array.each_with_index{|y,index| square += (y-fit_y[index])**2}
			variance = square
			return {"coe"=>coefficients,"var"=>variance,"type"=>"linear"}
		when "exponential"
			variance=0.0
			fit_y=Array.new(x_array.size, 0.0)
			square=0.0
			coefficients = exponential(x_array, y_array)
			if coefficients[2]
				puts 'Cannot perform exponential regression on this data'
			else
				x_array.each_with_index{|x,index| fit_y[index] += coefficients[0]*(Math::E ** coefficients[1])}
				y_array.each_with_index{|y,index| square += (y-fit_y[index])**2}
				variance = square
				return {"coe"=>coefficients,"var"=>variance,"type"=>"exponential"}
			end
		when "logarithmic"
			variance=0.0
			fit_y=Array.new(x_array.size, 0.0)
			square=0.0
			coefficients = logarithmic(x_array, y_array)
			if coefficients[2]
				return nil
			else
				coefficients[3].each{|index| square = (y_array[index] - (coefficients[0]*Math.log(x_array[index]) + coefficients[1]))**2}
				variance = square
				return {"coe"=>coefficients,"var"=>variance,"type"=>"logarithmic"}
			end
		when "polynomial"
			variance=Array.new
			(2..10).each {|degree|coefficients << polynomial(x_array, y_array, degree)}
			coefficients.each do |arr| 
				fit_y=Array.new(x_array.size, 0.0)
				square = 0.0
				arr.each_with_index{|coe, pow| x_array.each_with_index{|x, i| fit_y[i] += coe*(x**pow)}}
				y_array.each_with_index{|y,index| square += (y-fit_y[index])**2}
				variance << square
			end
			return {"coe"=>coefficients[variance.index(variance.min)],"var"=>variance.index(variance.min),"type"=>"polynomial"}
		end
	end

	def public_loop(size)
		i=0
		until i >= size do 
			yield(i)
			i+=1
		end
	end

	def linear(x_array, y_array)
		n=0
		coefficients = Array.new
		sum_x=0.0
		sum_y=0.0
		sum_xx=0.0
		sum_xy=0.0
		i=0
		public_loop(x_array.size) do |i|
			sum_x+=x_array[i]
			sum_y+=y_array[i]
			sum_xx+=x_array[i]**2
			sum_xy+=x_array[i]*y_array[i]
			n+=1
		end
		coefficients << ((n*sum_xy-sum_x*sum_y)/(n*sum_xx-sum_x**2)).round(2)
		coefficients << ((sum_y*sum_xx-sum_xy*sum_x)/(n*sum_xx-sum_x**2)).round(2)
		return coefficients
	end

	def exponential(x_array, y_array)
		n=0
		coefficients = Array.new
		sum_x=0.0
		sum_xx=0.0
		sum_lny=0.0
		sum_xlny=0.0
		domain_error = false
		public_loop(x_array.size) do |i|
			begin
				sum_x += x_array[i]
				sum_xx += x_array[i]**2
				sum_lny += Math.log(y_array[i])
				sum_xlny += x_array[i]*Math.log(y_array[i])
				n+=1
			rescue Math::DomainError
				domain_error = true
			end
		end
		coefficients << (Math::E ** ((sum_lny * sum_xx - sum_x * sum_xlny )/(n * sum_xx - sum_x ** 2))).round(2)
		coefficients << ((n * sum_xlny - sum_x * sum_lny)/(n * sum_xx - sum_x ** 2)).round(2)
		coefficients << domain_error
		return coefficients
	end

	def logarithmic(x_array, y_array)
		n=0
		coefficients = Array.new
		sum_y=0.0
		sum_lnx=0.0
		sum_lnxlnx=0.0
		sum_ylnx=0.0
		domain_error = false
		valid=Array.new
		public_loop(x_array.size) do |i|
			begin
				sum_y += y_array[i]
				sum_lnx += Math.log(x_array[i])
				sum_lnxlnx += Math.log(x_array[i])**2
				sum_ylnx += y_array[i]*Math.log(x_array[i])
				valid << n
				n+=1
			rescue Math::DomainError
				domain_error = true
			end
		end
		coefficients << ((n*sum_ylnx-sum_y*sum_lnx)/(n*sum_lnxlnx-sum_lnx**2)).round(2)
		coefficients << ((sum_y-((n*sum_ylnx-sum_y*sum_lnx)/(n*sum_lnxlnx-sum_lnx**2))*sum_lnx)/n).round(2)
		coefficients << domain_error
		coefficients << valid
		return coefficients
	end 

	def polynomial(x_array, y_array, degree)
		coefficients = Array.new
		x_data = x_array.map { |x_i| (0..degree).map { |pow| x_i.to_f**pow } }
		mx = Matrix[*x_data]
		my = Matrix.column_vector(y_array)
		coefficients = Array.new
		((mx.t * mx).inv * mx.t * my).transpose.to_a[0].each{|x| x=x.round(2); coefficients << x}
		return coefficients
	end
end