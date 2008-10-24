require 'arch/x86_64'
require 'arch/x86_64/macros'

class RMA::X86_64::Test

def test_call
	bin = assemble {
		m = addmacros DefaultMacros

		m.entry[:main]
		call :foo
		m.sys_exit[rax]

		m.entry[:foo]
		m.return[5]
	}

	run_test bin, 5
end

# http://en.wikibooks.org/wiki/Fibonacci_number_program#Arithmetic_version_2
def fib(n)
  ((((1+Math.sqrt(5))/2)**n)/Math.sqrt(5)+0.5).floor
end

def test_fib
	testargs = [0,1,2,10]

	testargs.each do |arg|
		expected = fib(arg)

		bin = assemble {
			m = addmacros DefaultMacros
			arg1 = rdi
			rval = rax
			tmp = rbx

			m.function(:main) do
				mov arg, arg1
				call :fib
				cmp expected, rval
				m.ifnot(:z) do
					m.sys_exit[1]
				end
				m.sys_exit[0]
			end

			m.function(:fib) do
				mov arg1, rval
				cmp 1, rval

				m.ifnot(:le) do
					m.save(tmp) do
						m.save(arg1) do
							sub 1, arg1
							call :fib
							mov rval, tmp
						end
						sub 2, arg1
						call :fib
						add tmp, rval
					end
				end

				m.return[rval]
			end
		}

		begin
			run_test bin, 0
		rescue
			puts "arg: #{arg}"
			raise
		end
	end

end

def test_fastfib
	testargs = [0,1,2,10,30]

	testargs.each do |arg|
		expected = fib(arg)

		bin = assemble {
			m = addmacros DefaultMacros
			arg1 = rdi
			rval = rax

			m.function(:main) do
				mov arg, arg1
				call :fib
				cmp expected, rval
				m.ifnot(:z) do
					m.sys_exit[1]
				end
				m.sys_exit[0]
			end

			m.function(:fib) do
				i = r10
				j = r13
				k = r14
				t = r15
				mov 1, i
				mov 0, j
				mov 0, k

				cond = lambda { |out| add 1, k; cmp arg, k; jg out }
				m.while(cond) do
					mov i, t
					add j, t
					mov j, i
					mov t, j
				end
				label :out

				m.return[j]
			end
		}

		begin
			run_test bin, 0
		rescue
			puts "arg: #{arg}"
			raise
		end
	end

end
end
