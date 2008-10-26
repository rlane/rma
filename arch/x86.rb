require 'lib/libs'
require 'tempfile'

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
	def initialize
		clear
	end

	def assemble(__src=nil, &__b)
		if __src
			instance_eval(__src, ARGF.filename)
		else
			instance_eval(&__b)
		end
		output
	end

	def output
		asm = @out
		clear

		a = Tempfile.new("asm")
		o = Tempfile.new("obj")

		a.write asm
		a.flush

		ret = system("#{@AS} -o #{o.path} #{a.path}")
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

	def clear
		@out = String.new
		@next_label = 0
	end

	class RegOperand
		def initialize(name)
			@name = name
		end

		def fmt_operand
			"%#{@name}"
		end

		def self.to_s
			"Reg"
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

		def self.to_s
			"Mem"
		end
	end

	def M(offset=0, base=nil, index=nil, scale=1)
		MemOperand.new(offset, base, index, scale)
	end

	class RegIndirectOperand
		def initialize(r)
			@r = r
		end

		def fmt_operand
			"*#{@r.fmt_operand}"
		end

		def to_s
			fmt_operand
		end
	end

	def RI(r)
		RegIndirectOperand.new(r)
	end

	def addmacros(m)
		m.new(self)
	end

	def makelabel
		l = "__l#{@next_label}"
		@next_label += 1
		l.intern
	end

	@@regs = []
	define_method('regs') { @@regs }
	public :regs

	def self.make_regs(rs)
		@@regs += rs
		rs.each do |r|
			define_method(r) { RegOperand.new r }
		end
	end

	def self.make_special_regs(rs)
		rs.each do |r|
			define_method(r) { RegOperand.new r }
		end
	end

	def self.op(opcode, *arg_types)
		define_method opcode do |*args|
			begin
				typecheck(arg_types, args)
			rescue RMA::OperandTypeError, RMA::OperandCountError => e
				raise e, nil, caller
			end
			inst(opcode, *args)
		end
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

	def typecheck(arg_types, args)
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

	def self.any(*types)
		UnionType.new(*types)
	end

	Label = Symbol
	Imm = Fixnum
	Reg = RegOperand
	Mem = MemOperand
	RegIndirect = RegIndirectOperand

	def self.directive(name, *arg_types)
		define_method name do |*args|
			begin
				typecheck(arg_types, args)
			rescue RMA::OperandTypeError, RMA::OperandCountError => e
				raise e, nil, caller
			end
			literal ".#{name} #{args.join(', ')};"
		end
	end

	directive 'global', Label
	directive 'section', String
	directive 'space', Fixnum

	def self.prefix(name)
		self.module_eval <<-EOS
			def #{name}(&b)
				inst :#{name}
				yield if b
			end
		EOS
	end
end
