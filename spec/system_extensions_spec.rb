#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Array do
	
	it "should be executable" do
		[2, 3, :+].execute.should == 5
	end

end

describe Symbol do
	
	it "should allow definitions" do
		lambda {:SQUARE.define [:DUP, :*]}.should_not raise_error
	end

	it "should be executable" do
		:SQUARE.define [:DUP, :*]
		[3, :SQUARE, 2, :+].execute.should == 11 
	end

end

