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

def test_jmp
	bin = assemble {
		global :main
		label :main
		mov 21, rdi
		jmp :out
		mov 13, rdi
		label :out
		mov 0x3c, rax
		syscall
	}

	run_test bin, 21
end

end
