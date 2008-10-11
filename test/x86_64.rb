require 'tempfile'
require 'test/unit'
require 'test/unit/assertions'
include Test::Unit::Assertions

AS="as --64"
LD="ld -m elf_x86_64"
QEMU="qemu-x86_64"

class X86_64Test < Test::Unit::TestCase
	def run_test(asm, ref)
		a = Tempfile.new("asm")
		o = Tempfile.new("obj")
		b = Tempfile.new("bin")

		a.write asm
		a.flush

		system("#{AS} -o #{o.path} #{a.path}") or raise 'AS not found'
		raise 'AS failed' unless $?.exitstatus == 0
		system("#{LD} -static -e main -o #{b.path} #{o.path}") or raise 'LD not found'
		raise 'LD failed' unless $?.exitstatus == 0
		system("#{QEMU} #{b.path}")

		ret = $?.exitstatus
		assert_equal ref, ret

		a.close
		o.close
		b.close
	end
end

require 'test/x86_64/asm/simple'
