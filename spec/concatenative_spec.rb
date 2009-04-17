#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Concatenative do

	it "should process Ruby methods and handle method arities" do
		# Fixnum#>: arity = 1
		[2, 20, :>].execute.should == false	
		["Test", /T/, 'F', :sub|2].execute.should == "Fest"	
		[[1,2,3],:join].execute.should == "123"
		[[1,2,3],'|',:join|1].execute.should == "1|2|3"
	end

	it "should process operators" do
		[2, 2, :dup].execute.should == [2, 2, 2]
	end

	it "should process combinators" do
		[2, 3, [:swap, :dup], :i].execute.should == [3, 2, 2]
	end

end
