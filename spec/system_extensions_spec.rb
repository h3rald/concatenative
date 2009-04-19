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

	it "should support namespaces" do
		lambda { :local/:a }.should_not raise_error
		[[1,2,3],[4,5,6],:concat].execute.should == [1,2,3,4,5,6]
		[[1,2,3],[4,5,6],:kernel/:concat].execute.should == [1,2,3,4,5,6]
		[[1,2,3],[4,5,6],:ruby/:concat|1].execute.should == [1,2,3,4,5,6]

	end
	
	it "should allow definitions" do
		lambda {:square <= [:dup, :*]}.should_not raise_error
		lambda {:square <= [:dup, :+]}.should raise_error
		lambda {:kernel/:dup <= [:dup]}.should raise_error
		lambda {:ruby/:gsub <= []}.should raise_error
		a = :test <= :square
		a.class.to_s.should == "Array"
		[4, :test].execute.should == 16
	end

	it "should be executable" do
		:square <= [:dup, :*] unless :square.defined?
		[3, :square, 2, :+].execute.should == 11 
	end

	it "should allow arity to be specified" do
		msg = :gsub|2
		msg.is_a?(Concatenative::RubyMessage).should == true
		msg.arity.should == 2
		msg.name.should == :gsub
	end

end
