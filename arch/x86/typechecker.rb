module RMA::X86::Assembler::Typechecker
	def self.typecheck(arg_types, args)
		raise RMA::OperandCountError.new(arg_types.length, args.length) unless args.length == arg_types.length
		arg_types.zip(args).each_with_index do |x,i|
			t,a = x
			a = a.intern if !(t === a) and a.respond_to? :intern and t === a.intern
			raise RMA::OperandTypeError.new(t,a,i) unless t === a
		end
	end

	class UnionType
		def initialize(*types)
			@types = types
		end

		def ===(o)
			@types.any? { |t| t === o }
		end

		def to_s
			"any(#{@types.join(', ')})"
		end
	end
end
