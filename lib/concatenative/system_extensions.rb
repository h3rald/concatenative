#!usr/bin/env ruby

module Kernel

	# Execute an array as a concatenative program (clears the STACK first).
	def concatenate(*program)
		Concatenative.execute program
	end

	# Specify the arity of a ruby method (regardless of the receiver).
	def set_arity(meth, arity)
		Concatenative::ARITIES[meth] = arity
	end

end

# The Array class is extended to allow execution of concatenative programs.
class Array

	# Execute self as a concatenative program (clears the STACK first).
	def execute
		Concatenative.execute self
	end

	# Processes each element of the array as a concatenative expression.
	def ~
		each { |e| Concatenative.process e }
	end

end

# The Symbol class is extended allowing explicit arities to be specified using the | operator,
# word definition and execution.
class Symbol

	attr_accessor :namespace
	attr_reader :definition
	attr_writer :name

	# Assigns a quoted program (Array) as the symbol's definition.
	def <=(item)
		definition = item.respond_to?(:definition) ? item.definition : item
		raise(RuntimeError, "'#{self}' is already defined.") if self.defined?
		raise(RuntimeError, "Cannot redefine a Ruby word") if @namespace == :ruby
		raise(RuntimeError, "Cannot redefine a Kernel word") if @namespace == :kernel
		case 
		when item.is_a?(Symbol) then
			@definition = [item]
		when item.is_a?(Array) then
			@definition = item
		else
			raise ArgumentError, "Invalid definition for '#@namespace/#@name'"
		end
	end

	# Specifies the arity of a ruby method. Example: :gsub|2 will return 
	# a RubyMessage with name = :gsub and arity = 2.
	def |(arity)
		Concatenative::RubyMessage.new(self.name, arity)
	end

	# Returns the symbol's name (without namespace).
	def name
		@name||self
	end

	# Returns whether the symbol is defined or not.
	def defined?
		@definition != nil
	end

	# Concatenates two symbols (used for namespaces).
	def /(sym)
		s = "#{self}/#{sym}".to_sym
		s.namespace = self
		s.name = sym
		s
	end

end
