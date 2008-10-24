DefaultMacros = MacroPackage.new do
	macro(:sys) do |n|
		mov n, rax if n != rax
		syscall
	end

	macro(:sys_exit) do |val|
		mov val, rdi if val != rdi
		sys[60]
	end

	macro(:entry) do |lbl|
		global lbl
		label lbl
	end

	macro(:return) do |val|
		mov val, rax if val != rax
		ret
	end

	block_macro(:function) do |b, name|
		entry[name]
		b.call
	end

end
