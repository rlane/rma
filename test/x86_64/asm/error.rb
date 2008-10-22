require 'arch/x86_64'

class RMA::X86_64::Test

def test_as_err
	e = assert_raise(RMA::AssemblerError) do
		run_test(assemble { literal 'foo' }, 0)
	end
	a = File.open(e.src, "r")
	File.unlink(a.path)
	a.close
end

def test_ld_err
	e = assert_raise(RMA::LinkerError) do
		run_test(assemble { jmp :foo }, 0)
	end
	p e.src
	o = File.open(e.src, "r")
	File.unlink(o.path)
	o.close
end

end
