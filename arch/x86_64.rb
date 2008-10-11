require 'lib/libs'

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
		out = @out
		clear
		out
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
