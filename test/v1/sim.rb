require 'lib/util'
require 'test/v1/sim/regfile'
require 'test/v1/sim/mem'
require 'test/v1/sim/decode'
require 'test/v1/sim/opcodes'

class V1
	MEM_SIZE = 4096
	NUM_REGS = 256

	def initialize(mem, in_ports, out_ports)
		init_regfile
		init_mem(mem)
		@pc = 0
		@halted = false
		@in_ports = in_ports
		@out_ports = out_ports
	end

	def halted?; @halted; end

	def cycle
		op = decode
		args = consume_args op.args
		self.instance_exec(*args, &op.block)
	end
end
