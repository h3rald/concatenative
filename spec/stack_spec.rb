#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative::Stack do

	before(:each) do
		@s = Concatenative::Stack.new
	end

	it "should expose POP and PUSH" do
		lambda { @s.pop }.should raise_error(EmptyStackError)
		@s._push 1
		@s._push 2
		@s._push 3
		@s._pop
		@s.to_a.should == [1,2]
	end

	it "should expose DUP" do
		lambda { @s._dup }.should raise_error(EmptyStackError)
		@s.push 1
		@s.push 2
		@s._dup
		@s.to_a.should == [1,2,2]
	end

	it "should expose TOP" do
		lambda { @s._top }.should raise_error(EmptyStackError)
		@s.from_a [1,2,3]
		@s._top.should == 3
	end

	it "should expose SWAP" do
		lambda { @s._swap }.should raise_error(EmptyStackError)
		@s.from_a [1,2,3]
		@s._swap
		@s.to_a.should == [1,3,2]
	end

	it "should expose CONS, FIRST and REST" do
		[1, [2], :CONS].execute.should == [[1,2]]
		[4, [3], [2, 1], :CONS, :CONS, 5, :SWAP, :CONS].execute.should == [[5,4,[3],2,1]]
		[[1,2,3,4], :REST].execute.should == [[2,3,4]]
		[[1,2,3,4], :FIRST].execute.should == [1]
		lambda { [1,2,3, :CONS].execute}.should raise_error
	end

	it "should expose CAT" do
		[[1,2],[3,4], :CAT].execute.should == [[1,2,3,4]]
	end

	it "should handle method arities" do
		# Fixnum#>: arity = 1
		[2, 20, :>].execute.should == [false]	
		["Test", /T/, 'F', :sub|2].execute.should == ["Fest"]	
		[[1,2,3],:join].execute.should == ["123"]
		[[1,2,3],'|',:join|1].execute.should == ["1|2|3"]
	end

	it "should expose the I combinator" do
		[2, 5, [:*, 6,:+], :I].execute.should == [16]
		# Check other definitions of :I according to http://tunes.org/~iepos/joy.html
		[2, 5, [:*, 6,:+], :DUP, :DIP, :ZAP].execute.should == [16]
		[2, 5, [:*, 6,:+], [[]], :DIP, :DIP, :ZAP].execute.should == [16]
		[2, 5, [:*, 6,:+], [[]], :DIP, :DIP, :DIP].execute.should == [16]
	end

	it "should expose the DIP combinator" do
		[2, 3, 4, [:+], :DIP].execute.should == [5, 4]
	end

	it "should expose the IFTE combinator" do
		t = [1000, :>], [2, :/], [3, :*], :IFTE
		[1200, *t].execute.should == [600]
		[800, *t].execute.should == [2400]
		# Test factorial with explicit recursion
		:FACTORIAL.define [0, :==], [:POP, 1], [:DUP, 1, :- , :FACTORIAL, :*], :IFTE
		[5, :FACTORIAL].execute.should == [120]
	end

	it "should expose the MAP combinator" do
		[[1,2,3,4], [:DUP, :*], :MAP].execute.should == [[1,4,9,16]]
	end

	it "should expose the STEP combinator" do
		[[1,2,3,4], [:DUP, :*], :STEP].execute.should == [1,4,9,16]
	end
end
