class RMA::X86_64::Test

def remove_tmpfile(path)
	a = File.open(path, "r")
	File.unlink(path)
	a.close
end

def test_as_err
	e = assert_raise(RMA::AssemblerError) do
		run_test(assemble { literal 'foo' }, 0)
	end
	remove_tmpfile e.src
end

def test_ld_err
	e = assert_raise(RMA::LinkerError) do
		run_test(assemble { jmp :foo }, 0)
	end
	remove_tmpfile e.src
end

def test_operand_count_err
	e = assert_raise(RMA::OperandCountError) do
		run_test(assemble { mov 1 }, 0)
	end
end

def test_operand_type_err
	e = assert_raise(RMA::OperandTypeError) do
		run_test(assemble { mov rax, 1 }, 0)
	end
end

end
