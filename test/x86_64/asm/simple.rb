require 'arch/x86_64'

class RMA::X86_64::Test

def test_ret
	bin = assemble {
		global :main
		label :main
		mov 0x3c, rax
		mov 42, rdi
		syscall
	}

	run_test bin, 42
end

end
