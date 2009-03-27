#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Array do
	
	it "should be executable" do
		[2, 3, :+].execute.should == 5
	end

	it "should be dequotable" do
		[2, 3, :*].unquote
		Concatenative::System::STACK.last.should == 6
	end

end

describe Kernel do

	it "should concatenate programs" do
		concatenate(
			"Goodbye, World!",
			/Goodbye/,
			"Hello",
			:sub|2
		).should == "Hello, World!"
		concatenate(
			[1,2,3],
			[:DUP, :*],
			:STEP
		).should == [1,4,9]
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

	it "should allo arity to be specified" do
		msg = :gsub|2
		msg.is_a?(RubyMessage).should == true
		msg.arity.should == 2
		msg.name.should == :gsub
	end

end
