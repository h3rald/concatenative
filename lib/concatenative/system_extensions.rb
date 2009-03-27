#!usr/bin/env ruby

class Array

	def execute
		Concatenative.concatenate *self
	end

	def prepend(element)
		insert 0, element
	end

	def unquote
		each { |e| Concatenative::System.process e }
	end
end

class Symbol

	attr_reader :definition

	def define(*array)
		d = (array.length == 1) ? array.first : array
		raise ArgumentError, "Argument for :#{self} definition is not a quoted program" unless d.is_a? Array
		@definition = d
	end

	def execute
		raise RuntimeError, ":#{self} is not defined" unless @definition
		@definition.execute
	end

	def |(arity)
		Concatenative::RubyMessage.new self, arity
	end

end
