class RMA::X86_64::Assembler
	def self.op(opcode, *arg_types)
		define_method opcode do |*args|
			typecheck(arg_types, args)
			inst(opcode, *args)
		end
	end

	def literal(x)
		@out << "#{x}\n"
	end

	def inst(opcode, *args)
		literal "#{opcode} #{args.map{|x|x.fmt_operand}.join(', ')};"
	end

	def label(lbl)
		literal "#{lbl}:"
	end

	op 'mov', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'movq', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'add', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'lea', Mem, Reg
	op 'ret'
	op 'syscall'
	op 'jmp', Label
	op 'call', Label
end
