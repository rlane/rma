require 'arch/x86_64/macros'

class RMA::X86_64::Test

def test_regs
	len = 0
	bin = assemble {
		movq 0, M(:acc)
		regs.each do |reg|
			len += 1
			r = send(reg.to_sym)
			mov 1, r
			add r, M(:acc)
		end
		movq M(:acc), rdi
		mov 0x3c, rax
		syscall
		section '.data'
		label :acc
		space 8
	}

	run_test bin, len
end

end
