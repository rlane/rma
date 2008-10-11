class V1
	Op = Struct.new(:name, :opcode, :args, :block)

	@opcodes = []
	@reverse_opcodes = {}
	@next_opcode = 0

	def self.opcodes; @opcodes; end
	def self.reverse_opcodes; @reverse_opcodes; end

	def self.op(name, *args, &b)
		o = Op.new
		o.name = name
		o.args = args
		o.opcode = @next_opcode
		o.block = b
		@opcodes[o.opcode] = o
		@reverse_opcodes[o.name] = o
		@next_opcode += 1
	end

	def self.branch_op(name, *args, &b)
		f = lambda { |*a| @pc = @this_pc + a[-1] if instance_exec(*a[0...-1], &b) }
		op name, *(args + [:offset]), &f
	end

	def decode
		@this_pc = @pc
		opcode = consume
		if opcode.nil?
			raise "attempted to execute past end of memory"
		elsif self.class.opcodes[opcode]
			self.class.opcodes[opcode]
		else
			raise "invalid opcode #{opcode.inspect} at pc #{@this_pc}"
		end
	end

end
