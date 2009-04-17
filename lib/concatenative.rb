require 'pp'

libdir = File.dirname(File.expand_path(__FILE__))+'/concatenative/'

class EmptyStackError < RuntimeError; end

require libdir+'kernel'
require libdir+'system_extensions'

module Concatenative

	extend Concatenative::Kernel

	STACK = []
	ARITIES = {}
	DEBUG = false

	# RubyMessage objects wrap a symbol and its arity 
	# (returned by Symbol#|). 
	class RubyMessage
		attr_reader :name, :arity
		def initialize(name, arity)
			@name = name
			@arity = arity
		end
	end

	class << self
		attr_accessor :frozen, :popped, :pushed
	end

	@frozen = nil
	@popped = nil
	@pushed = nil

	# Pushes an item on the stack.
	def self.push(element)
		STACK.push element
		@pushed += 1 if @frozen
		element
	end

	# Saves the stack state
	def self.save_stack
		@frozen = STACK.length
		@popped = 0
		@pushed = 0
	end

	# Restored the previously saved stack state
	def self.restore_stack
		diff = STACK.length - @frozen
		@frozen = nil
		diff.times { _pop }
	end	

	# Executes an array as a concatenative program (clears the stack first).
	def self.execute(array)
		STACK.clear
		array.each { |e| process e }
		(STACK.length == 1) ? STACK[0] : STACK
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
		if (item.to_s.upcase == item.to_s) && !ARITIES[item] then
			respond_to?(item.to_s.downcase.to_sym) ?	send(item.to_s.downcase.to_sym) : raise(RuntimeError, "Unknown function: #{item}")
		else
			push send_message(item)
		end
	end

	# Calls a Ruby method, consuming elements from the stack according to its
	# explicit or implicit arity.
	def self.send_message(message)
		raise EmptyStackError, "Empty stack" if STACK.empty?
		case
		when message.is_a?(Concatenative::RubyMessage) then
			n = message.arity
			method = message.name
		when message.is_a?(Symbol) then
			n = ARITIES[message] || 0
			method = message
		end
		elements = []
		(n+1).times { elements << pop }
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

# Setting some default arities
set_arity :+, 1
set_arity :*, 1
set_arity :-, 1
set_arity :/, 1
set_arity :|, 1
set_arity :&, 1
set_arity :^, 1
set_arity :%, 1
set_arity :>, 1
set_arity :<, 1
set_arity :~, 1
set_arity :**, 1
set_arity :[], 1
set_arity :[]=, 1
set_arity :<<, 1
set_arity :>>, 1
set_arity :==, 1
set_arity :'!=', 1
set_arity :>=, 1
set_arity :<=, 1
set_arity :'%=', 1
set_arity :'*=', 1
set_arity :'+=', 1
set_arity :'-=', 1
set_arity :'/=', 1
set_arity :'||', 1
set_arity :'&&', 1
set_arity :'-=', 1
set_arity :===, 1
set_arity :<=>, 1
set_arity :'**=', 1
