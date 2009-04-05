#!/usr/bin/env ruby

dir = File.dirname(File.expand_path(__FILE__))+'/../lib/' 
require dir+"concatenative"

puts " ========================================="
puts " => Concatenative CLI"
puts "    Enter an item to push it on the stack"
puts "    or 'exit' to end the program."
puts " ========================================="
loop do
	print " => "
	begin
		Concatenative::System.process(instance_eval(gets))	
	rescue Exception => e
		if e.is_a? SystemExit then
			puts " Exiting."
			exit
		end
		print " ERROR: "
		puts e.message
	end
	print " STACK: "
	pp Concatenative::DATA_STACK
end
