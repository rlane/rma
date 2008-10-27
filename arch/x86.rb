require 'lib/libs'
require 'tempfile'
require 'arch/x86/typechecker'
require 'arch/x86/translator'
require 'arch/x86/operands'
require 'arch/x86/assembly'
require 'arch/x86/ir'

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
		@assembly = Assembly.new(self)
		clear
	end

	def clear
		@next_label = 0
		@out = []
	end

	def assemble(src=nil, &b)
		@assembly.__assemble__(src, &b)
		Translator.output @AS, @out
	end

	def <<(x)
		@out << x
	end

	def literal(x)
		self << IR::Literal.new(x)
	end

	def inst(opcode, *args)
		self << IR::Instruction.new(opcode, args)
	end

	def label(lbl)
		self << IR::Label.new(lbl)
	end

	def makelabel
		l = "__l#{@next_label}"
		@next_label += 1
		l.intern
	end

	def self.make_regs(rs)
		rs.each do |r|
			Assembly.add_method(r) { Reg.new r }
		end
	end

	def self.op(opcode, *arg_types)
		Assembly.add_method opcode do |*args|
			begin
				Typechecker.typecheck(arg_types, args)
			rescue RMA::OperandTypeError, RMA::OperandCountError => e
				raise e, nil, caller
			end
			inst(opcode, *args)
		end
	end

	def self.directive(name, *arg_types)
		Assembly.add_method name do |*args|
			begin
				Typechecker.typecheck(arg_types, args)
			rescue RMA::OperandTypeError, RMA::OperandCountError => e
				raise e, nil, caller
			end
			literal ".#{name} #{args.join(', ')};"
		end
	end

	def self.prefix(name)
		Assembly.send :module_eval, <<-EOS
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
