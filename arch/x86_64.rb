require 'lib/libs'
require 'tempfile'

AS="as --64"

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
		asm = @out
		clear

		a = Tempfile.new("asm")
		o = Tempfile.new("obj")

		a.write asm
		a.flush

		ret = system("#{AS} -o #{o.path} #{a.path}")
		if not (ret and $?.exitstatus == 0)
			path = a.path
			a.unlink
			a2 = File.new(path, "w")
			a2.write asm
			a2.close
			raise RMA::AssemblerError.new(path)
		end

		obj = o.read

		a.close
		o.close

		obj
	end

	private

	class RegOperand
		def initialize(name)
			@name = name
		end

		def fmt_operand
			"%#{@name}"
		end
	end

	class MemOperand
		def initialize(base, offset, index, length)
			@base = base
			@offset = offset
			@index = index
			@length = length
		end
	end

	def rax; RegOperand.new 'rax'; end
	def rdi; RegOperand.new 'rdi'; end

	def clear
		@out = String.new
		@next_reg = 1
	end

	def literal(x)
		@out << "#{x}\n"
	end

	def inst(opcode, *args)
		literal "#{opcode} #{args.map{|x|x.fmt_operand}.join(', ')};"
	end

	def self.op(opcode, *arg_types)
		define_method opcode do |*args|
			raise RMA::OperandCountError.new(arg_types.length, args.length) unless args.length == arg_types.length
			arg_types.zip(args) do |t,a|
				raise RMA::OperandTypeError.new(t,a) unless t === a
			end
			inst(opcode, *args)
		end
	end

	Label = Symbol
	Imm = Fixnum
	Reg = RegOperand
	Mem = MemOperand

	class UnionType
		def initialize(*types)
			@types = types
		end
		def ===(o)
			@types.any? { |t| t === o }
		end
	end

	def self.any(*types)
		UnionType.new(*types)
	end

	op 'mov', any(Reg, Imm), Reg
	op 'add', any(Reg, Imm), Reg
	op 'ret'
	op 'syscall'
	op 'jmp', Label

	def label(lbl)
		literal "#{lbl}:"
	end

	def global(lbl)
		literal ".globl #{lbl}"
	end
end
