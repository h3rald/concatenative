#!usr/bin/env ruby

module Kernel

	# Execute an array as a concatenative program (clears the DATA_STACK first).
	def concatenate(*program)
		Concatenative::System.execute program
	end

	# Specify the arity of a ruby method (regardless of the receiver).
	def set_arity(meth, arity)
		Concatenative::ARITIES[meth] = arity
	end

end

# The Array class is extended to allow execution of concatenative programs.
class Array

	# Processes each element of the array as a concatenative expression.
	def ~
		each { |e| Concatenative::System.process e }
	end

end

# The Symbol class is extended allowing explicit arities to be specified using the | operator,
# concatenative function definition and execution.
class Symbol

	attr_reader :definition

	# Assigns a quoted program (Array) as the symbol's definition.
	def <=(item)
		@definition = item.is_a?(Symbol) ? item.definition : item
	end

	def ~
		case 
		when @definition.is_a?(Proc) then
			@definition.call
		when @definition.is_a?(Array) then
			~@definition
		else
			Concatenative::System.push Concatenative::System.send_message(self) 
		end
	end

	# Specifies the arity of a ruby method. Example: :gsub|2 will return a RubyMessage with name = :gsub and
	# arity = 2.
	def |(arity)
		Concatenative::RubyMessage.new self, arity
	end

	def /(sym)
		"#{self}/#{sym}".to_sym
	end

end
