class DefaultMacros < MacroPackage
	def sys(n)
		mov n, eax if n != eax
		int 0x80
	end

	def self.make_syscall(name, num, arity)
		define_method(name) do |*args|
			arg_regs = [ebx, ecx, edx, esi, edi, ebp]
			(0...arity).each do |arg_num|
				mov args[arg_num], arg_regs[arg_num] if args[arg_num] != arg_regs[arg_num]
			end
			sys num
		end
	end

	make_syscall :sys_exit, 1, 1

	def entry(lbl)
		global lbl
		label lbl
	end

	def return(val)
		mov val, eax if val != eax
		ret
	end

	def function(name, &b)
		entry name
		b.call
	end

	def if(cond, &b)
		l = makelabel
		l2 = makelabel
		send("j#{cond}", l)
		jmp l2
		label l
		b.call
		label l2
	end

	def ifnot(cond, &b)
		l = makelabel
		send("j#{cond}", l)
		b.call
		label l
	end

	def save(*regs, &b)
		regs.each { |reg| push reg }
		b.call
		regs.reverse.each { |reg| pop reg }
	end

	def loop(&b)
		l = makelabel
		label l
		b.call
		jmp l
	end

	def while(cond, &b)
		l2 = makelabel
		self.loop do
			cond.call(l2)
			b.call
		end
		label l2
	end

	def zero(*regs)
		regs.each do |reg|
			xor reg, reg
		end
	end

	def frame(&b)
		push ebp
		mov esp, ebp
		b.call
		leave
	end

	def arg_s(n)
		M(4 + n*4, esp)
	end

	def arg_b(n)
		M(8 + n*4, ebp)
	end
end
