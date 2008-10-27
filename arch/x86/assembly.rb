require 'forwardable'

class RMA::X86::Assembler::Assembly
	extend Forwardable
	def_delegators :@__assembler__, :makelabel, :literal

	def self.add_method(name, &b)
		define_method name, &b
	end

	def initialize(assembler)
		@__assembler__ = assembler
	end

	## Methods called by assembler

	def __assemble__(__src__=nil, &__b__)
		if __src__
			instance_eval __src__, ARGF.filename
		else
			instance_eval &__b__
		end
	end

	## Methods called by source code

	def addmacros(m)
		m.new(self)
	end

	def inst(opcode, *args)
		literal "#{opcode} #{args.map{|x|x.fmt_operand}.join(', ')};"
	end

	def label(lbl)
		literal "#{lbl}:"
	end

	def M(offset=0, base=nil, index=nil, scale=1)
		RMA::X86::Assembler::Mem.new(offset, base, index, scale)
	end

	def RI(r)
		RMA::X86::Assembler::RegIndirect.new(r)
	end
end
