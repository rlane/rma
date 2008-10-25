DefaultMacros = MacroPackage.new do
	macro(:sys) do |n|
		mov n, rax if n != rax
		syscall
	end

	sys1 = lambda do |num|
		lambda do |arg1|
			mov arg1, rdi if arg1 != rdi
			sys[num]
		end
	end

	macro(:sys_exit, &sys1[60])

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

	block_macro(:if) do |b, cond|
		l = makelabel
		l2 = makelabel
		send("j#{cond}", l)
		jmp l2
		label l
		b.call
		label l2
	end

	block_macro(:ifnot) do |b, cond|
		l = makelabel
		send("j#{cond}", l)
		b.call
		label l
	end

	block_macro(:save) do |b, *regs|
		regs.each { |reg| push reg }
		b.call
		regs.reverse.each { |reg| pop reg }
	end

	block_macro(:loop) do |b|
		l = makelabel
		label l
		b.call
		jmp l
	end

	block_macro(:while) do |b, cond|
		l2 = makelabel
		self.loop do
			cond.call(l2)
			b.call
		end
		label l2
	end

	macro(:zero) do |*regs|
		regs.each do |reg|
			xor reg, reg
		end
	end
end
