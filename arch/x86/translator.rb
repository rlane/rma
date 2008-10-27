module RMA::X86::Assembler::Translator
	def self.translate(ir)
		ir.map { |x| x.fmt.chomp+"\n" }.join('')
	end

	def self.output as, ir
		a = Tempfile.new("asm")
		o = Tempfile.new("obj")

		asm = translate ir
		a.write asm
		a.flush

		ret = system("#{as} -o #{o.path} #{a.path}")
		if not (ret and $?.exitstatus == 0)
			path = a.path
			a.unlink
			a2 = File.new(path, "w")
			a2.write asm
			a2.close
			raise RMA::AssemblerError.new(path)
		end

		obj = o.read

		a.close
		o.close

		obj
	end
end
