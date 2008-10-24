require 'arch/x86_64'
require 'arch/x86_64/macros'

class RMA::X86_64::Test

def test_call
	bin = assemble {
		m = addmacros DefaultMacros

		m.entry[:main]
		call :foo
		m.sys_exit[rax]

		m.entry[:foo]
		m.return[5]
	}

	run_test bin, 5
end

end
