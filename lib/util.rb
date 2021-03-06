require 'test/unit/assertions'
include Test::Unit::Assertions

$meta_blocks = {}

class Object # http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  def meta_def name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk }
  end

	def meta_block_def name, &blk
		i = blk.object_id
		$meta_blocks[i] = blk
		(class << self; self; end).module_eval <<-EOS
			def #{name}(*args, &b)
				$meta_blocks[#{i}].call(b, *args)
			end
		EOS
	end
end

module Math
	def log2 val
		(log val) / (log 2)
	end
end

def silently(&block)
	warn_level = $VERBOSE
	$VERBOSE = nil
	result = block.call
	$VERBOSE = warn_level
	result
end

class Object
	def chill
		frozen? ? self : dup.freeze
	end
end

class String
	if not String.new.respond_to? :getbyte
		def getbyte(n)
			self[n]
		end
	end
end

def i2f(v)
	assert(v.is_a?(Integer))
	[v].pack("N").unpack("g")[0]
end

def f2i(v)
	assert(v.is_a?(Float))
	[v].pack("g").unpack("N")[0]
end

module BlankSlate
	def self.new(*save)
		Class.new do
			(Kernel.methods - 
			 Object.methods + 
			 instance_methods
			).each { |m| undef_method m unless m =~ /^__/ or save.member? m.intern }
		end
	end
end

