class MacroPackage
	def initialize(&b)
		@b = b
	end

	def instantiate(assembler)
		MacroInstance.new(assembler, &@b)
	end
end

class MacroInstance
	undef syscall, exit

	def initialize(assembler, &b)
		@assembler = assembler
		instance_eval &b
	end

	def method_missing(id, *args)
		@assembler.send id, *args
	end

	def macro(name, &b)
		meta_def(name) { b }
	end

	def block_macro(name, &b)
		meta_block_def name, &b
	end
end

