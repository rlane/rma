require 'lib/libs'
require 'tempfile'
require 'arch/x86/typechecker'
require 'arch/x86/translator'
require 'arch/x86/operands'

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

class String
	def fmt_operand
		to_s
	end
end

class RMA::X86::Assembler
	Label = Symbol
	Imm = Fixnum
	Reg = Operands::RegisterOperand
	Mem = Operands::MemoryOperand
	RegIndirect = Operands::RegisterIndirectOperand

	attr_accessor :out, :next_label, :as

	def initialize
		clear
	end

	def clear
		@out = String.new
		@next_label = 0
	end

	def assemble(__src=nil, &__b)
		if __src
			instance_eval(__src, ARGF.filename)
		else
			instance_eval(&__b)
		end
		Translator.output @AS, @out
	end

	def M(offset=0, base=nil, index=nil, scale=1)
		Mem.new(offset, base, index, scale)
	end

	def RI(r)
		RegIndirect.new(r)
	end

	def addmacros(m)
		m.new(self)
	end

	def makelabel
		l = "__l#{@next_label}"
		@next_label += 1
		l.intern
	end

	def literal(x)
		@out << "#{x}\n"
	end

	def inst(opcode, *args)
		literal "#{opcode} #{args.map{|x|x.fmt_operand}.join(', ')};"
	end

	def label(lbl)
		literal "#{lbl}:"
	end

	def self.make_regs(rs)
		rs.each do |r|
			define_method(r) { Reg.new r }
		end
	end

	def self.op(opcode, *arg_types)
		define_method opcode do |*args|
			begin
				Typechecker.typecheck(arg_types, args)
			rescue RMA::OperandTypeError, RMA::OperandCountError => e
				raise e, nil, caller
			end
			inst(opcode, *args)
		end
	end

	def self.directive(name, *arg_types)
		define_method name do |*args|
			begin
				Typechecker.typecheck(arg_types, args)
			rescue RMA::OperandTypeError, RMA::OperandCountError => e
				raise e, nil, caller
			end
			literal ".#{name} #{args.join(', ')};"
		end
	end

	def self.prefix(name)
		self.module_eval <<-EOS
			def #{name}(&b)
				inst :#{name}
				yield if b
			end
		EOS
	end

	def self.any(*types)
		Typechecker::UnionType.new(*types)
	end

	directive 'global', Label
	directive 'section', String
	directive 'space', Fixnum
end
