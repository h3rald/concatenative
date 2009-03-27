require 'pp'

libdir = File.dirname(File.expand_path(__FILE__))+'/concatenative/'

class EmptyStackError < RuntimeError; end

require libdir+'system'
require libdir+'system_extensions'
require libdir+'definitions'

module Concatenative

	ARITIES = {}
	DEBUG = false

	def set_arity(meth, arity)
		ARITIES[meth] = arity
	end


	class RubyMessage
		attr_reader :name, :arity
		def initialize(name, arity)
			@name = name
			@arity = arity
		end
	end

	def concatenate(*program)
		System.execute program
	end

	def self.concatenate(*program)
		System.execute program
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
