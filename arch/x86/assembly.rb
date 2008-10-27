require 'forwardable'

class RMA::X86::Assembler::Assembly
	extend Forwardable

	A = RMA::X86::Assembler
	IR = A::IR

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
	def_delegators :@__assembler__, :makelabel, :inst, :label, :literal

	def addmacros(m)
		m.new(self)
	end

	def M(offset=0, base=nil, index=nil, scale=1)
		A::Mem.new(offset, base, index, scale)
	end

	def RI(r)
		A::RegIndirect.new(r)
	end
end
