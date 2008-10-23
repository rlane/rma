class RMA::X86_64::Assembler

	## Instruction metaprogramming

	def self.op(opcode, *arg_types)
		define_method opcode do |*args|
			raise RMA::OperandCountError.new(arg_types.length, args.length) unless args.length == arg_types.length
			arg_types.zip(args) do |t,a|
				raise RMA::OperandTypeError.new(t,a) unless t === a
			end
			inst(opcode, *args)
		end
	end

	## Operand typechecking

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

	# Type aliases
	Label = Symbol
	Imm = Fixnum
	Reg = RegOperand
	Mem = MemOperand

	## Instructions

	def literal(x)
		@out << "#{x}\n"
	end

	def inst(opcode, *args)
		literal "#{opcode} #{args.map{|x|x.fmt_operand}.join(', ')};"
	end

	def label(lbl)
		literal "#{lbl}:"
	end

	def global(lbl)
		literal ".globl #{lbl}"
	end

	op 'mov', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'movq', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'add', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'lea', Mem, Reg
	op 'ret'
	op 'syscall'
	op 'jmp', Label
end
