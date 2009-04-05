#!usr/bin/env ruby

module Concatenative

	DATA_STACK = []
	RETAIN_STACK = []

	# The System module includes the DATA_STACK constant, methods to interpret items pushed on 
	# the stack and the implementations of all concatenative combinators and operators. 
	module System

		class << self
			attr_accessor :frozen, :popped, :pushed
		end
		
		@frozen = nil
		@popped = nil
		@pushed = nil

		# Pushes an item on the stack.
		def self.push(element)
			DATA_STACK.push element
			@pushed += 1 if @frozen
			element
		end

		def self.move
			item = DATA_STACK.pop
			RETAIN_STACK.push item
		 	item	
		end

		def self.copy
			item = DATA_STACK.last
			RETAIN_STACK.push item
		 	item	
		end

		def self.restore
			item = RETAIN_STACK.pop
			DATA_STACK.push item
			item
		end

		# Saves the stack state
		def self.save_stack
			@frozen = DATA_STACK.length
			@popped = 0
			@pushed = 0
		end

		# Restored the previously saved stack state
		def self.restore_stack
			diff = DATA_STACK.length - @frozen
			@frozen = nil
			diff.times { :POP.call}
		end	

		# Executes an array as a concatenative program (clears the stack first).
		def self.execute(array)
			DATA_STACK.clear
			array.each { |e| process e }
			(DATA_STACK.length == 1) ? DATA_STACK[0] : DATA_STACK
		end

		def self.process(item)
			case	
			when item.is_a?(Symbol) then
				~item 
			when item.is_a?(RubyMessage) then
				push send_message(item)
			else
				push item 
			end
		end

		# Calls a Ruby method, consuming elements from the stack according to its
		# explicit or implicit arity.
		def self.send_message(message)
			raise EmptyStackError, "Empty stack" if DATA_STACK.empty?
			case
			when message.is_a?(Concatenative::RubyMessage) then
				n = message.arity
				method = message.name
			when message.is_a?(Symbol) then
				n = ARITIES[message] || 0
				method = message
			end
			elements = []
			(n+1).times { elements << ~:POP }
			receiver = elements.pop
			args = []
			(elements.length).times { args << elements.pop }
			begin
				(args.length == 0)	? receiver.send(method) :	receiver.send(method, *args)
			rescue Exception => e
				raise RuntimeError, 
					"Error when calling: #{receiver}##{method}(#{args.join(', ')}) [#{receiver.class}##{method}]"
			end
		end
				
	end
end

