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
	op 'sub', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'cmp', any(Reg, Imm), Reg
	op 'lea', Mem, Reg
	op 'ret'
	op 'syscall'
	op 'jmp', Label
	op 'call', Label
	op 'push', any(Reg, Imm)
	op 'pop', Reg

	%w(jmp je jz jcxz jp jpe jne jnz jecxz jnp jpo 
	   ja jae jb jbe jna jnae jnb jnbe jc jnc jg jge 
		 jl jle jng jnge jnl jnle jo jno js jns).each do |jmpop|
		op jmpop, Label
	end
end
