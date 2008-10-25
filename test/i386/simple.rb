require 'arch/i386/macros'

class RMA::I386::Test

def test_exit
	bin = assemble {
		m = addmacros DefaultMacros
		m.entry[:main]
		m.sys_exit[42]
	}

	run_test bin, 42
end

def test_function
	bin = assemble {
		m = addmacros DefaultMacros

		m.function(:main) do
			call :foo
			m.sys_exit[eax]
		end

		m.function(:foo) do
			mov 42, eax
			ret
		end
	}

	run_test bin, 42
end

def test_jmp
	bin = assemble {
		m = addmacros DefaultMacros
		global :main
		label :main
		mov 21, ebx
		jmp :out
		mov 13, ebx
		label :out
		m.sys_exit[ebx]
	}

	run_test bin, 21
end

def test_mem
	bin = assemble {
		m = addmacros DefaultMacros
		global :main
		label :main

		mov 0, edi

		movl 1, M(:foo)
		add M(:foo), edi

		mov 4, eax
		movl 2, M(:foo, eax)
		mov 0, ecx
		mov 1, eax
		add M(:foo, ecx, eax, 4), edi

		lea M(:foo), eax
		mov 4, ecx
		movl 4, M(0, eax, ecx, 8)
		lea M(:foo, nil, ecx, 4), eax
		add M(0, eax, ecx, 4), edi

		m.sys_exit[edi]

		section '.data'
		label :foo
		space 128
	}

	run_test bin, 7
end

end
