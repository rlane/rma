require 'arch/i386'

class RMA::X86_64::Assembler < RMA::I386::Assembler
	def initialize
		super
		@AS = 'as --64'
	end

	make_regs %w(
		rax rbx rcx rdx rsi rdi rbp rsp 
		r8  r9  r10  r11  r12  r13  r14  r15
		r8d r9d r10d r11d r12d r13d r14d r15d
		r8w r9w r10w r11w r12w r13w r14w r15w
		r8b r9b r10b r11b r12b r13b r14b r15b
	)

	op 'syscall'
end
