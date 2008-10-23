require 'lib/libs'
require 'tempfile'

AS="as --64"

class Fixnum
	def fmt_operand
		"$#{to_s}"
	end
end

class Symbol
	def fmt_operand
		to_s
	end
end

class RMA::X86_64::Assembler
	def initialize
		clear
	end

	def assemble(src=nil, &b)
		if src
			instance_eval { eval src }
		else
			instance_eval(&b)
		end
		asm = @out
		clear

		a = Tempfile.new("asm")
		o = Tempfile.new("obj")

		a.write asm
		a.flush

		ret = system("#{AS} -o #{o.path} #{a.path}")
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

	private

	def clear
		@out = String.new
	end

	class RegOperand
		def initialize(name)
			@name = name
		end

		def fmt_operand
			"%#{@name}"
		end
	end

	class MemOperand
		def initialize(offset, base, index, scale)
			@offset = offset
			@base = base
			@index = index
			@scale = scale
		end

		def fmt_operand
			if @base and @index
				"#{@offset}(#{@base.fmt_operand}, #{@index.fmt_operand}, #{@scale})"
			elsif @base
				"#{@offset}(#{@base.fmt_operand})"
			elsif @index
				"#{@offset}(, #{@index.fmt_operand}, #{@scale})"
			else
				"#{@offset}"
			end
		end
	end

	def M(offset=0, base=nil, index=nil, scale=1)
		MemOperand.new(offset, base, index, scale)
	end

end

require 'arch/x86_64/registers'
require 'arch/x86_64/instructions'
