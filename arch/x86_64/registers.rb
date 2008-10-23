class RMA::X86_64::Assembler
	regs = %w(rax rbx rcx rdx rsi rdi rbp rsp r8  r9  r10  r11  r12  r13  r14  r15
						eax ebx ecx edx esi edi ebp esp r8d r9d r10d r11d r12d r13d r14d r15d
						ax  bx  cx  dx  si  di  bp  sp  r8w r9w r10w r11w r12w r13w r14w r15w
						ah  bh  ch  dh
						al  bl  cl  dl  sil dil bpl spl r8b r9b r10b r11b r12b r13b r14b r15b
	         )

	regs.each do |reg|
		r = RegOperand.new reg
		define_method(reg) { r }
	end
end
