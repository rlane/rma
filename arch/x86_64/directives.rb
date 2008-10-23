class RMA::X86_64::Assembler
	def self.directive(name, *arg_types)
		define_method name do |*args|
			typecheck(arg_types, args)
			literal ".#{name} #{args.join(', ')};"
		end
	end

	directive 'global', Label
	directive 'section', String
	directive 'space', Fixnum
end
