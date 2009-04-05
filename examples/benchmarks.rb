#!/usr/bin/env ruby

require 'benchmark'
dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 
require dir+"concatenative"

n = 1000

def factorial(n)
	(n == 0) ? 1 : factorial(n-1)
end

def fibonacci(n)
	x1,x2 = 0, 1 
	res = []
	0.upto(n){ res << x1; x1+=x2; x1,x2= x2,x1}
	res[res.length-1]
end

puts "======================================================================"
puts "=====> Factorial of #{n}"
puts "======================================================================"
Benchmark.bmbm(20) do |x|
  x.report("Standard Ruby Code:") { factorial n }
	x.report("Concatenative (times):") { concatenate(n, 1, 1, :ROLLDOWN, [:DUP, [:*], :DIP, :succ], :TIMES, :POP) }
  x.report("Concatenative (linrec):") { concatenate(n, [0, :==], [1, :+], [:DUP, 1, :-], [:*], :LINREC) }
  x.report("Concatenative (primrec):") { concatenate(n, [1], [:*], :PRIMREC) }
end
puts
puts
puts "======================================================================"
puts "=====> Fibonacci number for #{n}"
puts "======================================================================"
Benchmark.bmbm(20) do |x|
  x.report("Standard Ruby Code:") { fibonacci n }
	x.report("Concatenative (times):") { concatenate(n, 0, 1, :ROLLDOWN, [:DUP, [:+], :DIP, :SWAP], :TIMES, :POP) }
end

