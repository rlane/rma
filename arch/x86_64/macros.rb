DefaultMacros = RMA::X86_64::Assembler.macropackage do
	macro(:sys) do |n|
		mov n, rax
		syscall
	end

	macro(:exit) do |ret|
		mov ret, rdi
		sys[60]
	end

	macro(:entry) do |lbl|
		global lbl
		label lbl
	end

end
