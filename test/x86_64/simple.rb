require 'arch/x86_64/macros'

class RMA::X86_64::Test

def test_ret
	bin = assemble {
		m = addmacros DefaultMacros
		m.entry(:main)
		m.sys_exit(42)
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

def test_mem
	bin = assemble {
		global :main
		label :main

		mov 0, rdi

		movq 1, M(:foo)
		add M(:foo), rdi

		mov 4, rax
		movq 2, M(:foo, rax)
		mov 0, rcx
		mov 1, rax
		add M(:foo, rcx, rax, 4), rdi

		lea M(:foo), rax
		mov 4, rcx
		movq 4, M(0, rax, rcx, 8)
		lea M(:foo, nil, rcx, 4), rax
		add M(0, rax, rcx, 4), rdi

		mov 0x3c, rax
		syscall

		section '.data'
		label :foo
		space 128
	}

	run_test bin, 7
end

end
