#!/usr/bin/env ruby

require 'benchmark'
dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 
require dir+"concatenative"

n = 3_000

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
	x.report("Concatenative (times):") { concatenate(n, 1, 1, :rolldown, [:dup, [:*], :dip, :succ], :times, :pop) }
  x.report("Concatenative (linrec):") { concatenate(n, [0, :==], [1, :+], [:dup, 1, :-], [:*], :linrec) }
  x.report("Concatenative (primrec):") { concatenate(n, [1], [:*], :primrec) }
end
puts
puts
puts "======================================================================"
puts "=====> Fibonacci number for #{n}"
puts "======================================================================"
Benchmark.bmbm(20) do |x|
  x.report("Standard Ruby Code:") { fibonacci n }
	x.report("Concatenative (times):") { concatenate(n, 0, 1, :rolldown, [:dup, [:+], :dip, :swap], :times, :pop) }
end

