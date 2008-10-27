module RMA::X86::Assembler::Operands
	class RegisterOperand
		def initialize(name)
			@name = name
		end

		def fmt_operand
			"%#{@name}"
		end

		def self.to_s
			"Reg"
		end
	end

	class MemoryOperand
		def initialize(offset, base, index, scale)
			@offset = offset
			@base = base
			@index = index
			@scale = scale
		end

		def fmt_operand
			if @base and @index
				"#{@offset}(#{@base.fmt_operand}, #{@index.fmt_operand}, #{@scale})"
			elsif @base
				"#{@offset}(#{@base.fmt_operand})"
			elsif @index
				"#{@offset}(, #{@index.fmt_operand}, #{@scale})"
			else
				"#{@offset}"
			end
		end

		def self.to_s
			"Mem"
		end
	end

	class RegisterIndirectOperand
		def initialize(r)
			@r = r
		end

		def fmt_operand
			"*#{@r.fmt_operand}"
		end

		def to_s
			fmt_operand
		end
	end
end
