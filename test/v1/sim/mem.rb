class V1
	def init_mem(mem)
		@mem = "\x00" * MEM_SIZE
		flash 0, mem
	end

	def mem_read(addr)
		@mem[addr...(addr+4)].unpack("N")[0]
	end

	def mem_write(addr, val)
		@mem[addr...(addr+4)] = [val].pack("N")
	end

	def consume_string
		n = consume
		str = ""
		n.times { str << consume }
		str
	end

	def consume_array(types)
		n = consume
		(0...n).map do
			consume_args(types)
		end
	end

	def consume_args(types)
		types.map do |t|
			if t.is_a? Array
				consume_array t
			else
				send "consume_#{t}"
			end
		end
	end

	def flash(start, data)
		len = data.length
		@mem[start...(start+len)] = data
	end

	def consume
		b = @mem.getbyte(@pc)
		@pc += 1
		b
	end

	def consume1; consume; end
	def consume2; (consume<<8) + consume; end
	def consume4; (consume2<<16) + consume2; end

	def consume_reg; consume1; end
	def consume_imm1; se1(consume1); end
	def consume_imm2; se2(consume2); end
	def consume_imm4; se4(consume4); end
	def consume_offset; consume_imm2; end
	def consume_addr; consume_imm2; end
	def consume_port; consume1; end
	def consume_len; consume1; end

	def sign_extend(val,len)
		val >= (1<<(len-1)) ? val - (1<<len) : val
	end

	def se1(v); sign_extend(v,8); end
	def se2(v); sign_extend(v,16); end
	def se4(v); sign_extend(v,32); end

end
