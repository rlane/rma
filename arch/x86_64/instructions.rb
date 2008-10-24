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

	no_arg = lambda { |name| op name }
	%w(nop ret syscall).each &no_arg
	%w(cbw cwd cwde).each &no_arg
	%w(pushf popf pusha popa).each &no_arg
	%w(stc clc cmc std cld sti cli).each &no_arg
	%w(mul imul div idiv inc dec).each { |x| op x, any(Reg, Mem) }
	%w(sal sar shl shr rcl rcr rol ror).each { |x| op x, Imm, Reg }
	%w(and or xor).each { |x| op x, Reg, Reg }

	%w(xchg mov movb movw movl movq add adc sub sbb cmp).each do |x|
		op x, any(Reg, Imm, Mem), any(Reg, Mem)
	end

	%w(jmp call je jz jcxz jp jpe jne jnz jecxz jnp jpo 
	   ja jae jb jbe jna jnae jnb jnbe jc jnc jg jge 
		 jl jle jng jnge jnl jnle jo jno js jns).each do |jmpop|
		op jmpop, Label
	end

	op 'lea', Mem, Reg
	op 'push', Reg
	op 'pop', Reg
end
