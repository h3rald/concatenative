#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Array do
	
	it "should be callable" do
		concatenate(2, 3, :*)
		Concatenative::DATA_STACK.last.should == 6
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
		lambda {:SQUARE <= [:DUP, :*]}.should_not raise_error
		lambda {:CUBE <= [:DUP, :DUP, :*, :*]}.should_not raise_error
		:SQUARE.definition.should == [:DUP, :*]
		:CUBE.definition.should == [:DUP, :DUP, :*, :*]
	end

	it "should be callable" do
		~[1,2,3]
		~:+
		~:+
		(~:POP).should == 6
	end

	it "should allow symbol concatenations" do
		(:local/:test).should == "local/test".to_sym
		:local/:test <= [1,2,3]
		concatenate(:local/:test, :+, :+).should == 6
	end

	it "should allow arities to be specified" do
		msg = :gsub|2
		msg.is_a?(Concatenative::RubyMessage).should == true
		msg.arity.should == 2
		msg.name.should == :gsub
	end

end
