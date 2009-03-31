require 'pp'

libdir = File.dirname(File.expand_path(__FILE__))+'/concatenative/'

class EmptyStackError < RuntimeError; end

require libdir+'combinators'
require libdir+'system'
require libdir+'system_extensions'
require libdir+'definitions'

# The Concatenative module (included automatically when required) defines
# some constants, the <tt>concatenate</tt> method and the RubyMessage class.
module Concatenative

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

	# Execute an array as a concatenative program (clears the STACK first).
	def self.concatenate(*program)
		System.execute program
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
