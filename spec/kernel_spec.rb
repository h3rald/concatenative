#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative::Kernel do

	it "should expose CLEAR" do
		[1,2,3,4,5, :clear].execute.should == [] 
	end

	it "should expose POP " do
		lambda { concatenate :pop }.should raise_error(EmptyStackError)
		concatenate(1,2,3,4,:pop, :pop, :pop).should == 1
	end

	it "should expose DUP" do
		lambda { concatenate :dup }.should raise_error(EmptyStackError)
		concatenate(1,2,:dup).should == [1,2,2]
	end

	it "should expose SWAP" do
		lambda { concatenate :swap }.should raise_error(EmptyStackError)
		[1,3,2, :swap].execute.should == [1,2,3]
	end

	it "should expose CONS, FIRST and REST" do
		[1, [2], :cons].execute.should == [1,2]
		[4, [3], [2, 1], :cons, :cons, 5, :swap, :cons].execute.should == [5,4,[3],2,1]
		[[1,2,3,4], :rest].execute.should == [2,3,4]
		[[1,2,3,4], :first].execute.should == 1
		lambda { [1,2,3, :cons].execute}.should raise_error
	end

	it "should expose UNCONS and UNSWONS" do
		[[1,2,3,4], :uncons].execute.should == [1, [2,3,4]]
		[[1,2,3,4], :unswons].execute.should == [[2,3,4], 1]
	end

	it "should expose CAT" do
		[[1,2],[3,4], :cat].execute.should == [1,2,3,4]
	end

	it "should expose I" do
		[2, 5, [:*, 6,:+], :i].execute.should == 16
		# Check other definitions of :I according to http://tunes.org/~iepos/joy.html
		[2, 5, [:*, 6,:+], :dup, :dip, :zap].execute.should == 16
		[2, 5, [:*, 6,:+], [[]], :dip, :dip, :zap].execute.should == 16
		[2, 5, [:*, 6,:+], [[]], :dip, :dip, :dip].execute.should == 16
	end

	it "should expose DIP" do
		[2, 3, 4, [:+], :dip].execute.should == [5, 4]
	end
	
	it "should expose TWODIP" do
		[2, 3, 9, 4, [:+], :twodip].execute.should == [5, 9, 4]
	end
	
	it "should expose THREEDIP" do
		[2, 3, 10, 8, 4, [:+], :threedip].execute.should == [5, 10, 8, 4]
	end

	it "should expose SWONS" do
		[[2], 1, :swap, :cons].execute.should == [1,2]
		[[2],1, :swons].execute.should == [[2],1, :swap, :cons].execute
		[[2],1, :swons].execute.should ==  [1,2]
	end

	it "should expose POPD" do
		[1,2,3, :popd].execute.should == [1,3]
	end

	it "should expose DUPD" do
		[1,2,3, :dupd].execute.should == [1,2,2,3]
	end

	it "should expose SWAPD" do
		[1,2,3, :swapd].execute.should == [2,1,3]
	end
	
	it "should expose ROLLUP, ROLLDOWN and ROTATE" do
		a = [3,2,1]
		(a.dup << :rollup).execute.should == [1,3,2]
		(a.dup << :rolldown).execute.should == [2,1,3]
		(a.dup << :rotate).execute.should == [1,2,3]
	end


	it "should expose UNIT" do
		[2, 3, :unit].execute.should == [2, [3]]
	end

	it "should expose IFTE" do
		t = [1000, :>], [2, :/], [3, :*], :ifte
		[1200, *t].execute.should == 600
		[800, *t].execute.should == 2400
		# Test factorial with explicit recursion
		:factorial <= [[0, :==], [:pop, 1], [:dup, 1, :- , :factorial, :*], :ifte]
		[5, :factorial].execute.should == 120
	end

	it "should expose MAP" do
		[[1,2,3,4], [:dup, :*], :map, 1].execute.should == [[1,4,9,16], 1]
	end

	it "should expose STEP" do
		[[1,2,3,4], [:dup, :*], :map, 1].execute.should == [1,4,9,16, 1]
	end

	it "should expose LINREC" do
		# factorial
		[5, [0, :==], [1, :+], [:dup, 1, :-], [:*], :linrec].execute.should == 120
	end

	it "should expose PRIMREC" do
		# factorial
		[5, [1], [:*], :primrec].execute.should == 120
	end

	it "should expose TIMES" do
		[4, [5, 2, :*], :times].execute.should == [10, 10, 10, 10]	
		# factorial
		[5, 1, 1, :rolldown, [:dup, [:*], :dip, :succ], :times, :pop].execute.should == 120
		x1,x2 = 0, 1 
		res = []
		0.upto(50){ res << x1; x1+=x2; x1,x2= x2,x1} 
		# Fibonacci number
		[50, 0, 1, :rolldown, [:dup, [:+], :dip, :swap], :times, :pop].execute.should == res[res.length-1]
	end

	it "should expose WHILE" do
		# gcd
		[40, 25, [0, :>], [:dup, :rollup, :remainder|1], :while, :pop].execute.should == 5
	end

	it "should expose SPLIT" do
		[4, [1,2,3,4,5,6], [:>], :split].execute.should == [4, [1,2,3], [4,5,6]]
	end

	it "should expose BINREC" do
		# quicksort
		[[6,4,2,8,1,7,9], 
		 [:length, 2, :<], [], [:uncons, [:>], :split], [[:swap], :dip, :cons, :concat],	
		 :binrec].execute.should == [1,2,4,6,7,8,9]
	end

end
