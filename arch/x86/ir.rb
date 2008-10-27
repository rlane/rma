IR = RMA::X86::Assembler::IR

class IR::Instruction
	attr_accessor :opcode, :args

	def initialize(_opcode, _args)
		@opcode = _opcode
		@args = _args
	end

	def to_s
		fmt
	end

	def fmt
		"#{@opcode} #{@args.map{|x|x.fmt_operand}.join(', ')}"
	end
end

class IR::Label
	attr_accessor :name

	def initialize(_name)
		@name = _name
	end

	def to_s
		fmt
	end

	def fmt
		@name.to_s+':'
	end
end

class IR::Literal
	attr_accessor :str

	def initialize(_str)
		@str = _str
	end

	def to_s
		fmt
	end

	def fmt
		@str
	end
end
