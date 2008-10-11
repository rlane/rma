#!/usr/bin/env ruby

# The simulator conveniently provides the argument list for each opcode
require 'test/v1/sim'

class Assembler
	def initialize
		clear
	end

	def assemble(src=nil, &b)
		if src
			instance_eval { eval src }
		else
			instance_eval(&b)
		end
		relocate
		bin = @bin
		clear
		#puts bin.bytes.map { |x| x.to_s(16).rjust(2,'0') }.join(' ')
		bin
	end

	private

	def clear
		@bin = String.new
		@labels = {}
		@relocs = []
		@next_reg = 1
		@this_pc = 0
	end

	def produce(b)
		@bin << b
	end

	def produce_reg(reg); produce reg.b1; end
	def produce_imm4(v); produce v.b4; end
	def produce_imm2(v); produce v.b2; end
	def produce_imm1(v); produce v.b1; end
	def produce_opcode(opcode); produce opcode.b1; end
	def produce_port(port); produce port.b1; end
	def produce_len(v); produce v.b1; end

	def create_offset(label, pc)
		@relocs << [label, @bin.length, pc]
	end

	def produce_offset(label)
		create_offset(label, @this_pc) 
		produce_imm2 0
	end

	def produce_addr(label)
		create_offset(label, 0)
		produce_imm2 0
	end

	def produce_string(str)
		produce_len str.length
		str.each_byte { |b| produce b.b1 }
	end

	def produce_array(types,values)
		produce_len values.length
		values.each { |v| produce_args types, [v] }
	end

	def produce_args(types,values)
		types.zip(values) do |t,v|
			if t.is_a? Array
				produce_array t, v
			else
				send "produce_#{t}", v
			end
		end
	end

	def relocate
		@relocs.each do |r|
			label,start,from = *r
			addr = @labels[label]
			raise "undefined label #{label}" unless addr
			@bin[start...(start+2)] = [addr-from].pack("n")
		end
	end

	def label(name)
		raise "duplicate label #{name}" if @labels.member? name
		@labels[name] = @bin.length
	end

	## Opcodes

	MANUAL_INSTS = []
	V1.opcodes.reject { |op| MANUAL_INSTS.member? op.name }.each do |op|
		define_method op.name do |*args|
			@this_pc = @bin.length
			produce_opcode op.opcode
			produce_args op.args, args
		end
	end

	alias outi outi4
	alias li li4
	alias inb in
	alias jmp j
	alias addi addi4
	alias subi subi4
	alias and_ and
	alias or_ or

	## Macros

	def data1(val)
		produce val.b1
	end

	def data2(val)
		produce val.b2
	end

	def data4(val)
		produce val.b4
	end

	def if_ge(reg1,reg2,&b)
		l1 = Object.new
		bl reg1, reg2, l1
		b.call
		label l1
	end

	def if_l(reg1,reg2,&b)
		l1 = Object.new
		bge reg1, reg2, l1
		b.call
		label l1
	end

	def if_fge(reg1,reg2,&b)
		l1 = Object.new
		fbl reg1, reg2, l1
		b.call
		label l1
	end

	def if_fl(reg1,reg2,&b)
		l1 = Object.new
		fbge reg1, reg2, l1
		b.call
		label l1
	end

	def while_g(reg1,reg2,&b)
		l1 = Object.new
		l2 = Object.new
		label l1
		ble reg1, reg2, l2
		b.call
		jmp l1
		label l2
	end

	def while_l(reg1,reg2,&b)
		l1 = Object.new
		l2 = Object.new
		label l1
		bge reg1, reg2, l2
		b.call
		jmp l1
		label l2
	end

	def forever(&b)
		l1 = Object.new
		label l1
		b.call
		jmp l1
	end

	def const(val)
		r = @next_reg
		li r, val
		@next_reg += 1
		r
	end

	def var(val=0)
		r = @next_reg
		li r, val
		@next_reg += 1
		r
	end

	def randi(abs, reg)
		li reg, abs
		rand reg, reg
	end

	def randi2(abs, reg)
		randi abs*2, reg
		subi reg, abs, reg
	end

	def mov(src,dst)
		add src, r0, dst
	end

	def push(src)
		addi r99, 1, r99
		s r99, src
	end

	def pop(dst)
		l r99, dst
		subi r99, 1, r99
	end

	def call(label, *args)
		arg_base = r101
		args.each do |arg|
			push arg_base
			mov arg, arg_base
			arg_base += 1
		end
		jal label, r100
	end

	def method_missing(name, *args)
		if name.to_s =~ /r(\d+)/
			$1.to_i
		else
			raise "no such method #{name.inspect}"
		end
	end
end

def assemble(&b)
	a = Assembler.new
	a.assemble(&b)
end

class Integer
	def b4; [self].pack("N"); end
	def b2; [self].pack("n"); end
	def b1; [self].pack("c"); end
end

class Float
	def b4; [self].pack("g"); end
end
