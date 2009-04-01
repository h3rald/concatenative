#!usr/bin/env ruby

module Concatenative

	DATA_STACK = []
	RETAIN_STACK = []

	# The System module includes the DATA_STACK constant, methods to interpret items pushed on 
	# the stack and the implementations of all concatenative combinators and operators. 
	module System

		extend Combinators

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

		def self.save
			item = DATA_STACK.pop
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
			diff.times { _pop }
		end	

		# Executes an array as a concatenative program (clears the stack first).
		def self.execute(array)
			DATA_STACK.clear
			array.each { |e| process e }
			(DATA_STACK.length == 1) ? DATA_STACK[0] : DATA_STACK
		end

		# Processes an item (without clearning the stack).
		def self.process(item)
			case
			when !item.is_a?(Symbol) && !item.is_a?(Concatenative::RubyMessage) then
				push item
			when item.is_a?(Symbol) && item.definition then
				item.definition.each {|e| process e}
			else
				call_function item
			end
		end

		# Calls a function (defined using Symbol#define) or a Ruby method identified by item (a Symbol or RubyMessage).
		def self.call_function(item)
			name = "_#{item.to_s.downcase}".to_sym
			if (item.to_s.upcase == item.to_s) && !ARITIES[item] then
				respond_to?(name) ?	send(name) : raise(RuntimeError, "Unknown function: #{item}")
			else
				push send_message(item)
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
			(n+1).times { elements << _pop }
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

