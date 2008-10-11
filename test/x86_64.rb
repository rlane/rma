require 'lib/libs'
require 'tempfile'
require 'test/unit'
require 'test/unit/assertions'
include Test::Unit::Assertions

LD="ld -m elf_x86_64"
QEMU="qemu-x86_64"

class RMA::X86_64::Test < Test::Unit::TestCase

	def assemble(&b)
		RMA::X86_64::Assembler.new.assemble &b
	end

	def run_test(obj, ref)
		o = Tempfile.new("obj")
		b = Tempfile.new("bin")

		o.write obj
		o.flush

		system("#{LD} -static -e main -o #{b.path} #{o.path}") or raise 'LD not found'
		raise 'LD failed' unless $?.exitstatus == 0

		system("#{QEMU} #{b.path}")

		ret = $?.exitstatus
		assert_equal ref, ret

		b.close
	end
end

require 'test/x86_64/asm/simple'
