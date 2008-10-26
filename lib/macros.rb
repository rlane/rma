class MacroPackage < BlankSlate.new(:instance_eval, :send, :methods)
	def initialize(assembler)
		@assembler = assembler
	end

	def method_missing(id, *args, &b)
		@assembler.send id, *args, &b
	end
end
