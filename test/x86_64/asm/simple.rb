class X86_64Test

def test_ret
	asm = <<-EOF
		.globl main
		main:
			movq $0x3c, %rax
			movq $42, %rdi
			syscall
	EOF

	run_test asm, 42
end

end
