include Math

class V1

	op :nop do end

	op :add, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] + r[tgt] end
	op :addi1, :reg, :imm1, :reg do |src,imm,dst| r[dst] = r[src] + imm end
	op :addi2, :reg, :imm2, :reg do |src,imm,dst| r[dst] = r[src] + imm end
	op :addi4, :reg, :imm4, :reg do |src,imm,dst| r[dst] = r[src] + imm end

	op :sub, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] - r[tgt] end
	op :subi1, :reg, :imm1, :reg do |src,imm,dst| r[dst] = r[src] - imm end
	op :subi2, :reg, :imm2, :reg do |src,imm,dst| r[dst] = r[src] - imm end
	op :subi4, :reg, :imm4, :reg do |src,imm,dst| r[dst] = r[src] - imm end

	op :sl, :reg, :imm1, :reg do |src,imm,dst| r[dst] = r[src] << imm end
	op :slr, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] << r[tgt] end
	op :sr, :reg, :imm1, :reg do |src,imm,dst| r[dst] = r[src] >> imm end
	op :srr, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] >> r[tgt] end

	op :and, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] & r[tgt] end
	op :or, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] | r[tgt] end
	op :xor, :reg, :reg, :reg do |src,tgt,dst| r[dst] = r[src] ^ r[tgt] end

	op :j, :offset do |o| @pc = @this_pc + o end
	op :jr, :reg do |src| @pc = r[src] end
	op :jal, :offset, :reg do |o,dst| r[dst] = @pc; @pc = @this_pc + o end
	op :jalr, :reg, :reg do |src,dst| r[dst] = @pc; @pc = r[src] end

	op :l, :reg, :reg do |dst,addr| r[dst] = mem_read(r[addr]) end
	op :s, :reg, :reg do |src,addr| mem_write(r[addr], r[src]) end

	op :li1, :reg, :imm1 do |dst,val| r[dst] = val end
	op :li2, :reg, :imm2 do |dst,val| r[dst] = val end
	op :li4, :reg, :imm4 do |dst,val| r[dst] = val end

	op :la, :addr, :reg do |o,dst| r[dst] = o end

	branch_op :beq, :reg, :reg do |a,b| r[a] == r[b] end
	branch_op :bne, :reg, :reg do |a,b| r[a] != r[b] end
	branch_op :bl,  :reg, :reg do |a,b| r[a] < r[b] end
	branch_op :bg,  :reg, :reg do |a,b| r[a] > r[b] end
	branch_op :bge, :reg, :reg do |a,b| r[a] >= r[b] end
	branch_op :ble, :reg, :reg do |a,b| r[a] <= r[b] end

	branch_op :fbeq, :reg, :reg do |a,b| rf[a] == rf[b] end
	branch_op :fbne, :reg, :reg do |a,b| rf[a] != rf[b] end
	branch_op :fbl,  :reg, :reg do |a,b| rf[a] < rf[b] end
	branch_op :fbg,  :reg, :reg do |a,b| rf[a] > rf[b] end
	branch_op :fbge, :reg, :reg do |a,b| rf[a] >= rf[b] end
	branch_op :fble, :reg, :reg do |a,b| rf[a] <= rf[b] end

	op :in, :port, :reg do |port,dst| r[dst] = @in_ports[port][] end
	op :out, :port, :reg do |port,dst| @out_ports[port][r[dst]] end
	op :outi4, :port, :imm4 do |port,val| @out_ports[port][val] end

	op :fadd, :reg, :reg, :reg do |src,tgt,dst| rf[dst] = rf[src] + rf[tgt] end
	op :fsub, :reg, :reg, :reg do |src,tgt,dst| rf[dst] = rf[src] - rf[tgt] end
	op :fmult, :reg, :reg, :reg do |src,tgt,dst| rf[dst] = rf[src] * rf[tgt] end
	op :fdiv, :reg, :reg, :reg do |src,tgt,dst| rf[dst] = rf[src] / rf[tgt] end

	op :rand, :reg, :reg do |max,dst| r[dst] = rand(r[max]) end
	op :log, :imm1, :reg, :reg do |b,src,dst| 
		begin
			r[dst] = (log2(r[src].abs)/log2(b)).to_i
		rescue Errno::ERANGE, Errno::EDOM
			r[dst] = 0
		end
	end
	op :flog, :imm1, :reg, :reg do |b,src,dst| 
		begin
			rf[dst] = log2(rf[src].abs)/log2(b)
		rescue Errno::ERANGE, Errno::EDOM
			rf[dst] = 0.0
		end
	end

	op :poly, :reg, :imm1, :addr, :reg do |x, d, table, dst|
		result = 0
		while d > 0
			result += m[table]
			result *= x
			d -= 1
			table += 4
		end
		result += m[table] if d == 0
		r[dst] = result
  end

	op :dbg, :string, [:reg] do |str, regs|
		puts "#{@pc} #{str}: #{regs.map { |reg| @regfile.print(reg[0]) }.join(', ')}"
	end

	op :halt do @halted = true end
end
