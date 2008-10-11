require 'arch/x86_64'

class X86_64Test

def test_ret
	asm = <<-EOF
		.globl main
		main:
			movq $0x3c, %rax
			movq $42, %rdi
			syscall
	EOF

	asm2 = Assembler.new.assemble {
		literal asm
	}

	run_test asm, 42
	run_test asm2, 42
end

end
