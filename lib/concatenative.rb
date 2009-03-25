require 'pp'
require 'yaml'

libdir = File.dirname(File.expand_path(__FILE__))+'/concatenative/'

class EmptyStackError < RuntimeError; end

require libdir+'stack'
require libdir+'system_extensions'
require libdir+'definitions'

module Concatenative

	ARITIES = {}
	DEBUG = false # for tests only
	
	def set_arity(meth, arity)
		ARITIES[meth] = arity
	end

	def concatenate(*array)
		array = (array.length == 1) ? array.first : array
		stack = Stack.new
		while array.length > 0 do
			item = array.shift
			stack.debug
			if item.is_a?(Symbol)||item.is_a?(Concatenative::Message) then
				if item.is_a?(Symbol) && item.definition then
					stack.from_a stack.concat_execute(item.definition)
				else
					call_function(item, stack)
				end
			else
				stack.push item
			end
		end
		stack
	end

	class Message
		attr_reader :name, :arity
		def initialize(name, arity)
			@name = name
			@arity = arity
		end
	end

	private

	def call_function(item, stack)
		name = "_#{item.to_s.downcase}".to_sym
		if item.to_s.upcase == item.to_s && stack.respond_to?(name) then
			stack.send name
		else
			stack.push send_message(item, stack)
		end
	end

	def send_message(message, stack)
		raise EmptyStackError, "Empty stack" if stack.empty?
		case
		when message.is_a?(Concatenative::Message) then
			n = message.arity
			method = message.name
		when message.is_a?(Symbol) then
			n = ARITIES[message] || 0
			method = message
		end
		elements = []
		(n+1).times { elements << stack.pop}
		receiver = elements.pop
		args = []
		(elements.length).times { args << elements.pop }
		begin
			(args.length == 0)	? receiver.send(method) :	receiver.send(method, *args)
		rescue Exception => e
			raise RuntimeError, "Error when calling: #{receiver}##{method}(#{args.join(', ')})"
		end
	end
end


include Concatenative

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
