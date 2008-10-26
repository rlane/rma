require 'arch/x86'

class RMA::I386::Assembler < RMA::X86::Assembler
	def initialize
		super
		@AS="as --32"
	end

	make_regs %w(
		   eax ebx ecx edx esi edi ebp esp
		   ax  bx  cx  dx  si  di  bp  sp
		   ah  bh  ch  dh
		   al  bl  cl  dl  sil dil bpl spl
		  )

	make_special_regs %w(gs fs es ds)

	no_arg = lambda { |name| op name }
	%w(nop ret iret cpuid leave hlt).each &no_arg
	%w(cbw cwd cwde).each &no_arg
	%w(pushf popf pusha popa).each &no_arg
	%w(stc clc cmc std cld sti cli).each &no_arg
	%w(mul imul div idiv inc dec).each { |x| op x, any(Reg, Mem) }
	%w(sal sar shl shr rcl rcr rol ror).each { |x| op x, Imm, Reg }
	%w(and or xor).each { |x| op x, Reg, Reg }

	%w(xchg mov movb movw movl movq add adc sub sbb cmp).each do |x|
		op x, any(Reg, Imm, Mem), any(Reg, Mem)
	end

	%w(jmp call).each do |jmpop|
		op jmpop, any(Label, Mem, RegIndirect)
	end

	%w(je jz jcxz jp jpe jne jnz jecxz jnp jpo 
	   ja jae jb jbe jna jnae jnb jnbe jc jnc jg jge 
		 jl jle jng jnge jnl jnle jo jno js jns).each do |jmpop|
		op jmpop, Label
	end

	op 'lea', Mem, Reg
	op 'push', Reg
	op 'pushl', any(Imm, Reg, Mem)
	op 'pop', Reg
	op 'int', Imm

	op 'incl', any(Reg, Mem)
	op 'decl', any(Reg, Mem)
	op 'xadd', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'cmpxchg', any(Reg, Mem), any(Reg, Mem)
	op 'invlpg', Mem

	prefix 'lock'
end

