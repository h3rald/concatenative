#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative::System do

	it "should expose POP " do
		lambda { concatenate :POP }.should raise_error(EmptyStackError)
		concatenate(1,2,3,4,:POP, :POP, :POP).should == 1
	end

	it "should expose DUP" do
		lambda { concatenate :DUP }.should raise_error(EmptyStackError)
		concatenate(1,2,:DUP).should == [1,2,2]
	end

	it "should expose SWAP" do
		lambda { concatenate :SWAP }.should raise_error(EmptyStackError)
		[1,3,2, :SWAP].execute.should == [1,2,3]
	end

	it "should expose CONS, FIRST and REST" do
		[1, [2], :CONS].execute.should == [1,2]
		[4, [3], [2, 1], :CONS, :CONS, 5, :SWAP, :CONS].execute.should == [5,4,[3],2,1]
		[[1,2,3,4], :REST].execute.should == [2,3,4]
		[[1,2,3,4], :FIRST].execute.should == 1
		lambda { [1,2,3, :CONS].execute}.should raise_error
	end

	it "should expose CAT" do
		[[1,2],[3,4], :CAT].execute.should == [1,2,3,4]
	end

	it "should handle method arities" do
		# Fixnum#>: arity = 1
		[2, 20, :>].execute.should == false	
		["Test", /T/, 'F', :sub|2].execute.should == "Fest"	
		[[1,2,3],:join].execute.should == "123"
		[[1,2,3],'|',:join|1].execute.should == "1|2|3"
	end

	it "should expose I" do
		[2, 5, [:*, 6,:+], :I].execute.should == 16
		# Check other definitions of :I according to http://tunes.org/~iepos/joy.html
		[2, 5, [:*, 6,:+], :DUP, :DIP, :ZAP].execute.should == 16
		[2, 5, [:*, 6,:+], [[]], :DIP, :DIP, :ZAP].execute.should == 16
		[2, 5, [:*, 6,:+], [[]], :DIP, :DIP, :DIP].execute.should == 16
	end

	it "should expose DIP" do
		[2, 3, 4, [:+], :DIP].execute.should == [5, 4]
	end

	it "should expose UNIT" do
		[2, 3, :UNIT].execute.should == [2, [3]]
	end

	it "should expose IFTE" do
		t = [1000, :>], [2, :/], [3, :*], :IFTE
		[1200, *t].execute.should == 600
		[800, *t].execute.should == 2400
		# Test factorial with explicit recursion
		:FACTORIAL.define [0, :==], [:POP, 1], [:DUP, 1, :- , :FACTORIAL, :*], :IFTE
		[5, :FACTORIAL].execute.should == 120
	end

	it "should expose MAP" do
		[[1,2,3,4], [:DUP, :*], :MAP, 1].execute.should == [[1,4,9,16], 1]
	end

	it "should expose STEP" do
		[[1,2,3,4], [:DUP, :*], :STEP, 1].execute.should == [1,4,9,16, 1]
	end

	it "should expose LINREC" do
		# factorial
		[5, [0, :==], [1, :+], [:DUP, 1, :-], [:*], :LINREC].execute.should == 120
	end

	it "should expose PRIMREC" do
		# factorial
		[5, [1], [:*], :PRIMREC].execute.should == 120
	end

	it "should expose TIMES" do
		[4, [5, 2, :*], :TIMES].execute.should == [10, 10, 10, 10]	
		# factorial
		[5, 1, 1, :ROLLDOWN, [:DUP, [:*], :DIP, :succ], :TIMES, :POP].execute.should == 120
		x1,x2 = 0, 1 
		res = []
		0.upto(50){ res << x1; x1+=x2; x1,x2= x2,x1} 
		# Fibonacci number
		[50, 0, 1, :ROLLDOWN, [:DUP, [:+], :DIP, :SWAP], :TIMES, :POP].execute.should == res[res.length-1]
	end

end
