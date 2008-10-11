class V1Test

def test_loop
	mem = assemble do
		li r2, 1000
		while_l r1, r2 do
			addi r1, 1, r1
		end
		halt
	end

	regs = { 0 => 0, 1 => 1000, 2 => 1000 }

	run_test mem, regs
end

def test_integer
	mem = assemble do
		li r1, 1
		addi r1, r1, r2
		subi r1, r2, r3
		sl r2, 1, r4
		sr r4, 2, r5
		sl r3, 8, r6
		slr r1, r4, r7
		srr r6, r2, r8
		li r9, 0xf00d
		li r10, 0xf6
		and_ r9, r10, r11
		or_ r9, r10, r12
		xor r9, r10, r13 

		halt
	end

	regs = {
		1 => 1, 2 => 2, 3 => -1, 
		4 => 4, 5 => 1, 6 => -256,
		7 => 16, 8 => -64,
		9 => 0xf00d, 10 => 0xf6, 11 => 0x4, 12 => 0xf0ff, 13 => 0xf0fb,
	}

	run_test mem, regs
end

def test_jump
	mem = assemble do
		j :l1
		halt
		label :l1
		addi r1, 1, r1
		la :l2, r2
		jr r2
		halt
		label :l2
		addi r1, 2, r1
		jal :l3, r100
		jalr r3, r100
		halt
		label :l3
		addi r1, 4, r1
		la :l4, r3
		jr r100
		halt
		label :l4
		addi r1, 8, r1
		halt
	end

	regs = { 1 => 0xf }

	run_test mem, regs
end

def test_float
	mem = assemble do
		li r1, 1.0
		li r2, 2.0
		fadd r1, r2, r3
		fmult r2, r2, r4
		fsub r3, r4, r5
		fdiv r3, r4, r6
		halt
	end

	regs = {
		0 => 0.0, 1 => 1.0, 2 => 2.0,
		3 => 3.0, 4 => 4.0, 5 => -1.0,
		6 => 0.75
	}

	run_test mem, regs
end

end
