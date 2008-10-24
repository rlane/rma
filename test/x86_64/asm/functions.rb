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
				jne :fail
				m.sys_exit[0]
				label :fail
				m.sys_exit[1]
			end

			# function fib(x)
			m.function(:fib) do
				cmp 1, arg1
				jg :greater_than_one
				# x <= 1
				m.return[arg1]
				# x > 1
				label :greater_than_one
				push tmp # callee save
				push arg1
				# tmp <= fib(x-1)
				sub 1, arg1
				call :fib
				mov rval, tmp
				# rval <= fib(x-2)
				pop arg1
				sub 2, arg1
				call :fib
				# return rval + tmp
				add tmp, rval
				pop tmp # callee restore
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

end
