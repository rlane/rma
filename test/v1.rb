require 'test/v1/sim'
require 'arch/v1'
require 'test/unit'
require 'test/unit/assertions'
include Test::Unit::Assertions

class V1Test < Test::Unit::TestCase
	def run_test(mem, regs, in_ports={}, out_ports={})
		cpu = V1.new(mem, in_ports, out_ports)
		cpu.cycle while not cpu.halted?
		regs.each do |n,v|
			if v.class == Fixnum
				assert_equal v, cpu.r[n], "r#{n} integer contents don't match"
			elsif v.class == Float
				assert_equal v, cpu.rf[n], "r#{n} float contents don't match"
			else
				fail "unsupported value class #{v.class}"
			end
		end
	end
end

require 'test/v1/asm/simple'
