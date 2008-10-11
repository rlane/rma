require 'lib/libs'
require 'tempfile'

AS="as --64"

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

		system("#{AS} -o #{o.path} #{a.path}") or raise 'AS not found'
		raise 'AS failed' unless $?.exitstatus == 0

		obj = o.read

		a.close
		o.close

		obj
	end

	private

	def clear
		@out = String.new
		@next_reg = 1
	end

	def literal(x)
		@out << "#{x}\n"
	end

end
