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
		def initialize(offset, base, index, scale)
			@offset = offset
			@base = base
			@index = index
			@scale = scale
		end

		def fmt_operand
			if @base and @index
				"#{@offset}(#{@base.fmt_operand}, #{@index.fmt_operand}, #{@scale})"
			elsif @base
				"#{@offset}(#{@base.fmt_operand})"
			elsif @index
				"#{@offset}(, #{@index.fmt_operand}, #{@scale})"
			else
				"#{@offset}"
			end
		end
	end

	def M(offset=0, base=nil, index=nil, scale=1)
		MemOperand.new(offset, base, index, scale)
	end

	regs = %w(rax rbx rcx rdx rsi rdi rbp rsp r8  r9  r10  r11  r12  r13  r14  r15
						eax ebx ecx edx esi edi ebp esp r8d r9d r10d r11d r12d r13d r14d r15d
						ax  bx  cx  dx  si  di  bp  sp  r8w r9w r10w r11w r12w r13w r14w r15w
						ah  bh  ch  dh
						al  bl  cl  dl  sil dil bpl spl r8b r9b r10b r11b r12b r13b r14b r15b
	         )

	regs.each do |reg|
		r = RegOperand.new reg
		define_method(reg) { r }
	end

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

	op 'mov', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'movq', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'add', any(Reg, Imm, Mem), any(Reg, Mem)
	op 'lea', Mem, Reg
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
