require 'arch/i386'
require 'tempfile'
require 'test/unit'
require 'test/unit/assertions'
include Test::Unit::Assertions

LD="ld -m elf_i386"
QEMU="qemu-i386"

class RMA::I386::Test < Test::Unit::TestCase

	def assemble(&b)
		RMA::I386::Assembler.new.assemble &b
	end

	def run_test(obj, ref)
		o = Tempfile.new("obj")
		b = Tempfile.new("bin")

		o.write obj
		o.flush

		ret = system("#{LD} -static -e main -o #{b.path} #{o.path}")
		if not (ret and $?.exitstatus == 0)
			path = o.path
			o.unlink
			o2 = File.new(path, "w")
			o2.write obj
			o2.close
			raise RMA::LinkerError.new(path)
		end

		begin
			system("#{QEMU} #{b.path}")
			ret = $?.exitstatus
			assert_equal ref, ret
		rescue
			path = o.path
			o.unlink
			o2 = File.new(path, "w")
			o2.write obj
			o2.close
			$stderr.puts "Emulator failed, output left in #{path}"
			raise
		end

		b.close
	end
end

require 'test/i386/simple'
