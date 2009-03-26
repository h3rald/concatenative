#!usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative do

	it "should define SWONS" do
		[[2], 1, :SWAP, :CONS].execute.should == [1,2]
		[[2],1, :SWONS].execute.should == [[2],1, :SWAP, :CONS].execute
		[[2],1, :SWONS].execute.should ==  [1,2]
	end

	it "should define POPD" do
		[1,2,3, :POPD].execute.should == [1,3]
	end

	it "should define DUPD" do
		[1,2,3, :DUPD].execute.should == [1,2,2,3]
	end

	it "should define SWAPD" do
		[1,2,3, :SWAPD].execute.should == [2,1,3]
	end

	it "should define SIP" do
		[[1,2],[3,4],:SIP].execute.should == [[1,2],3,4,[1,2]]
	end

	it "should define REP" do
		[[2,3, :*], :REP, 2].execute.should == [6,6,2]
	end
	
	it "should define ROLLUP, ROLLDOWN and ROTATE" do
		a = [3,2,1]
		(a.dup << :ROLLUP).execute.should == [1,3,2]
		(a.dup << :ROLLDOWN).execute.should == [2,1,3]
		(a.dup << :ROTATE).execute.should == [1,2,3]
	end

end


