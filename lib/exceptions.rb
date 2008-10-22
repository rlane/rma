class RMA::IntermediateError < Exception
	attr_reader :srcs

	def initialize(tool, srcs)
		@tool = tool
		@srcs = srcs
	end

	def src
		@srcs[0]
	end

	def to_s
		"#{@tool} failed, input left in #{@srcs.join(', ')}"
	end
end

class RMA::AssemblerError < RMA::IntermediateError
	def initialize(src)
		super('Assembler', [src])
	end
end

class RMA::LinkerError < RMA::IntermediateError
	def initialize(src)
		super('Linker', [src])
	end
end