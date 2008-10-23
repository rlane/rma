class RMA::X86_64::Assembler
	def typecheck(arg_types, args)
		raise RMA::OperandCountError.new(arg_types.length, args.length) unless args.length == arg_types.length
		arg_types.zip(args) do |t,a|
			raise RMA::OperandTypeError.new(t,a) unless t === a
		end
	end

	class UnionType
		def initialize(*types)
			@types = types
		end
		def ===(o)
			@types.any? { |t| t === o }
		end
	end

	def self.any(*types)
		UnionType.new(*types)
	end

	Label = Symbol
	Imm = Fixnum
	Reg = RegOperand
	Mem = MemOperand
end
