#!usr/bin/env ruby

# The Array class is extended to allow execution of concatenative programs.
class Array

	# Executes a concatenative program (clears the STACK first).
	def execute
		Concatenative.concatenate *self
	end
	
	# Processes each element of the array as a concatenative expression.
	def unquote
		each { |e| Concatenative::System.process e }
	end
end

# The Symbol class is extended allowing explicit arities to be specified using the | operator,
# concatenative function definition and execution.
class Symbol

	attr_reader :definition

	# Assigns a quoted program (Array) as the symbol's definition.
	def define(*array)
		d = (array.length == 1) ? array.first : array
		raise ArgumentError, "Argument for :#{self} definition is not a quoted program" unless d.is_a? Array
		@definition = d
	end

	# Executes a concatenative function identified by the symbol (if it has been defined).
	def execute
		raise RuntimeError, ":#{self} is not defined" unless @definition
		@definition.execute
	end

	# Specifies the arity of a ruby method. Example: :gsub|2 will return a RubyMessage with name = :gsub and
	# arity = 2.
	def |(arity)
		Concatenative::RubyMessage.new self, arity
	end

end
