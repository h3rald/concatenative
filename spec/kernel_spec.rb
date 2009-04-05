#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative do

	it "should expose CLEAR" do
		concatenate(1,2,3,4,5, :CLEAR).should == [] 
	end

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
		concatenate(1,3,2, :SWAP).should == [1,2,3]
	end

	it "should expose CONS, FIRST and REST" do
		concatenate(1, [2], :CONS).should == [1,2]
		concatenate(4, [3], [2, 1], :CONS, :CONS, 5, :SWAP, :CONS).should == [5,4,[3],2,1]
		concatenate([1,2,3,4], :REST).should == [2,3,4]
		concatenate([1,2,3,4], :FIRST).should == 1
		lambda { concatenate(1,2,3, :CONS)}.should raise_error
	end

	it "should expose UNCONS and UNSWONS" do
		concatenate([1,2,3,4], :UNCONS).should == [1, [2,3,4]]
		concatenate([1,2,3,4], :UNSWONS).should == [[2,3,4], 1]
	end

	it "should expose CAT" do
		concatenate([1,2],[3,4], :CAT).should == [1,2,3,4]
	end

	it "should expose I" do
		concatenate(2, 5, [:*, 6,:+], :I).should == 16
		# Check other definitions of :I according to http://tunes.org/~iepos/joy.html
		concatenate(2, 5, [:*, 6,:+], :DUP, :DIP, :ZAP).should == 16
		concatenate(2, 5, [:*, 6,:+], [[]], :DIP, :DIP, :ZAP).should == 16
		concatenate(2, 5, [:*, 6,:+], [[]], :DIP, :DIP, :DIP).should == 16
	end

	it "should expose DIP" do
		concatenate(2, 3, 4, [:+], :DIP).should == [5, 4]
	end
	
	it "should expose TWODIP" do
		concatenate(2, 3, 9, 4, [:+], :TWODIP).should == [5, 9, 4]
	end
	
	it "should expose THREEDIP" do
		concatenate(2, 3, 10, 8, 4, [:+], :TREEDIP).should == [5, 10, 8, 4]
	end

	it "should expose SWONS" do
		concatenate([2], 1, :SWAP, :CONS).should == [1,2]
		concatenate([2],1, :SWONS).should == concatenate([2],1, :SWAP, :CONS)
		concatenate([2],1, :SWONS).should ==  [1,2]
	end

	it "should expose POPD" do
		concatenate(1,2,3, :POPD).should == [1,3]
	end

	it "should expose DUPD" do
		concatenate(1,2,3, :DUPD).should == [1,2,2,3]
	end

	it "should expose SWAPD" do
		concatenate(1,2,3, :SWAPD).should == [2,1,3]
	end
	
	it "should expose ROLLUP, ROLLDOWN and ROTATE" do
		a = [3,2,1]
		concatenate(3,2,1,:ROLLUP).should == [1,3,2]
		concatenate(3,2,1,:ROLLDOWN).should == [2,1,3]
		concatenate(3,2,1,:ROTATE).should == [1,2,3]
	end


	it "should expose UNIT" do
		concatenate(2, 3, :UNIT).should == [2, [3]]
	end

	it "should expose IFTE" do
		t = [1000, :>], [2, :/], [3, :*], :IFTE
		concatenate(1200, *t).should == 600
		concatenate(800, *t).should == 2400
		# Test factorial with explicit recursion
		:FACTORIAL <= [[0, :==], [:POP, 1], [:DUP, 1, :- , :FACTORIAL, :*], :IFTE]
		concatenate(5, :FACTORIAL).should == 120
	end

	it "should expose MAP" do
		concatenate([1,2,3,4], [:DUP, :*], :MAP, 1).should == [[1,4,9,16], 1]
	end

	it "should expose STEP" do
		concatenate([1,2,3,4], [:DUP, :*], :STEP, 1).should == [1,4,9,16, 1]
	end

	it "should expose LINREC" do
		# factorial
		concatenate(5, [0, :==], [1, :+], [:DUP, 1, :-], [:*], :LINREC).should == 120
	end

	it "should expose PRIMREC" do
		# factorial
		concatenate(5, [1], [:*], :PRIMREC).should == 120
	end

	it "should expose TIMES" do
		concatenate(4, [5, 2, :*], :TIMES).should == [10, 10, 10, 10]	
		# factorial
		concatenate(5, 1, 1, :ROLLDOWN, [:DUP, [:*], :DIP, :succ], :TIMES, :POP).should == 120
		x1,x2 = 0, 1 
		res = []
		0.upto(50){ res << x1; x1+=x2; x1,x2= x2,x1} 
		# Fibonacci number
		concatenate(50, 0, 1, :ROLLDOWN, [:DUP, [:+], :DIP, :SWAP], :TIMES, :POP).should == res[res.length-1]
	end

	it "should expose WHILE" do
		# gcd
		concatenate(40, 25, [0, :>], [:DUP, :ROLLUP, :remainder|1], :WHILE, :POP).should == 5
	end

	it "should expose SPLIT" do
		concatenate(4, [1,2,3,4,5,6], [:>], :SPLIT).should == [4, [1,2,3], [4,5,6]]
	end

	it "should expose BINREC" do
		# quicksort
		concatenate([6,4,2,8,1,7,9], 
		 [:length, 2, :<], [], [:UNCONS, [:>], :SPLIT], [[:SWAP], :DIP, :CONS, :CONCAT],	
		 :BINREC).should == [1,2,4,6,7,8,9]
	end

end
