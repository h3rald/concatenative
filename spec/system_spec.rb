#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative::System do

	it "should process Ruby methods and handle method arities" do
		# Fixnum#>: arity = 1
		concatenate(2, 20, :>).should == false	
		concatenate("Test", /T/, 'F', :sub|2).should == "Fest"	
		concatenate([1,2,3],:join).should == "123"
		concatenate([1,2,3],'|',:join|1).should == "1|2|3"
	end

	it "should process operators" do
		concatenate(2, 2, :DUP).should == [2, 2, 2]
	end

	it "should process combinators" do
		concatenate(2, 3, [:SWAP, :DUP], :I).should == [3, 2, 2]
	end

end
