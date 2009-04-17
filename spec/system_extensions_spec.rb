#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 

require dir+"concatenative"

describe Array do

	it "should be unquotable" do
		~[2, 3, :*]
		Concatenative::STACK.last.should == 6
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
			[:dup, :*],
			:step
		).should == [1,4,9]
	end
	
end

describe Symbol do
	
	it "should allow definitions" do
		lambda {:square <= [:dup, :*]}.should_not raise_error
	end

	it "should be executable" do
		:square <= [:dup, :*] unless :square.definition
		[3, :square, 2, :+].execute.should == 11 
	end

	it "should allo arity to be specified" do
		msg = :gsub|2
		msg.is_a?(Concatenative::RubyMessage).should == true
		msg.arity.should == 2
		msg.name.should == :gsub
	end

end
