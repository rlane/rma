class V1
	def init_regfile
		@regfile = RegFile.new(NUM_REGS)
		@regshimi = IntRegShim.new(@regfile)
		@regshimf = FloatRegShim.new(@regfile)
	end

	def r; @regshimi; end
	def rf; @regshimf; end
	def m; @mem; end

	class IntRegShim
		def initialize(regfile)
			@regfile = regfile
		end

		def [](r)
			v = @regfile.read_i r
			#puts "ri[#{r}] <- #{v}"
			v
		end

		def []=(r,v)
			#puts "ri[#{r}] == #{v}"
			@regfile.write_i r, v
		end
	end

	class FloatRegShim
		def initialize(regfile)
			@regfile = regfile
		end

		def [](r)
			v = @regfile.read_f r
			#puts "rf[#{r}] == #{v}"
			raise "read NaN at #{r}" if v.nan?
			v
		end

		def []=(r,v)
			#puts "rf[#{r}] <- #{v}"
			raise "wrote NaN at #{r}" if v.nan?
			@regfile.write_f r, v
		end
	end

	class RegFile
		def initialize(n)
			@n = n
			@ri = [0]*n
			@rf = [0.0]*n
		end

		def write_i(r,v)
			assert v.is_a?(Integer)
			return if r == 0
			@ri[r] = v
			@rf[r] = nil
		end

		def write_f(r,v)
			assert v.is_a?(Float)
			return if r == 0
			@ri[r] = nil
			@rf[r] = v
		end

		def read_i(r)
			return @ri[r] if @ri[r]
			@ri[r] = f2i(@rf[r])
		end

		def read_f(r)
			return @rf[r] if @rf[r]
			@rf[r] = i2f(@ri[r])
		end

		def print(reg)
			if @ri[reg] && @rf[reg]
				"r#{reg}=#{@ri[reg]};f#{reg}=#{@rf[reg]}" 
			elsif @ri[reg]
				"r#{reg}=#{@ri[reg]}" if @ri[reg]
			elsif @rf[reg]
				"f#{reg}=#{@rf[reg]}" if @rf[reg]
			end
		end
	end
end
