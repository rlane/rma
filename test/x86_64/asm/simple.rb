require 'arch/x86_64'

class RMA::X86_64::Test

def test_ret
	asm = <<-EOF
		.globl main
		main:
			movq $0x3c, %rax
			movq $42, %rdi
			syscall
	EOF

	bin = assemble {
		literal asm
	}

	run_test bin, 42
end

end
