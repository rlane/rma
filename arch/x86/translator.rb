module RMA::X86::Assembler::Translator
	def self.output as, asm
		a = Tempfile.new("asm")
		o = Tempfile.new("obj")

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
