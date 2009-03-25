#!usr/bin/env ruby

module Concatenative
	class Stack < Array

		def debug
			if Concatenative::DEBUG then
				print "(##{object_id.to_s(32)})=> "
				pp self
			end
		end

		def from_a(array)
			clear.concat array
		end

		alias old_pop pop

		def pop
			raise EmptyStackError, "Empty stack" if empty?
			old_pop
		end

		# Operators

		alias _pop pop

		alias _zap pop

		alias _push push

		def _top
			raise EmptyStackError, "Empty stack" if empty?
			last
		end

		def _put
			puts _top
		end

		def _get
			push gets
		end

		def _dup
			push _top
		end

		def _swap
			a = pop
			b = pop
			push a
			push b
		end

		def _cons
			array = pop
			element = pop
			raise ArgumentError, "CONS: first element is not an Array." unless array.is_a? Array
			push array.prepend(element)
		end
		
		def _cat
			array1 = pop
			array2 = pop
			raise ArgumentError, "CONS: first element is not an Array." unless array1.is_a? Array
			raise ArgumentError, "CONS: first element is not an Array." unless array2.is_a? Array
			push array2.concat(array1)
		end

		alias _concat _cat
		
		def _first
			array = pop
			raise ArgumentError, "FIRST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "FIRST: empty array." if array.length == 0
			push array.first
		end
		
		def _rest
			array = pop
			raise ArgumentError, "REST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "REST: empty array." if array.length == 0
			array.delete_at 0
			push array
		end
		
		# Combinators

		def _dip
			program = pop
			raise ArgumentError, "DIP: first element is not a quoted program." unless program.is_a? Array
			arg = pop
			push program
			_i
			push arg
		end

		def _i
			program = pop
			raise ArgumentError, "I: first element is not a quoted program." unless program.is_a? Array
			from_a concat_execute(program)
		end

		def _ifte
			_else = pop
			_then = pop
			_if = pop
			arg = pop
			raise ArgumentError, "IFTE: first element is not a quoted program." unless _if.is_a? Array
			raise ArgumentError, "IFTE: second element is not a quoted program." unless _then.is_a? Array
			raise ArgumentError, "IFTE: third element is not a quoted program." unless _else.is_a? Array
			condition = _if.prepend_execute(arg)
			concat (condition.first) ? _then.prepend_execute(arg) : _else.prepend_execute(arg)
		end

		def _map
			program = pop
			list = pop
			raise ArgumentError, "MAP: first element is not a quoted program." unless program.is_a? Array
			raise ArgumentError, "MAP: second element is not an array." unless list.is_a? Array
			push list.map {|e| program.prepend_execute(e).first }
		end
	
		def _step
			program = pop
			list = pop
			raise ArgumentError, "STEP: first element is not a quoted program." unless program.is_a? Array
			raise ArgumentError, "STEP: second element is not an array." unless list.is_a? Array
			list.map {|e| push program.prepend_execute(e).first }
		end

		def _linrec
			rec2 = pop
		 	rec1 = pop
			_then = pop
			_if = pop
			arg = pop
			if _if.prepend_execute(arg).first then
				concat _then.prepend_execute(arg)
			else
				concat [*rec1.prepend_execute(arg), _if, _then, rec1, rec2]
				_linrec
				push rec2
				_i
			end
		end

		def _primrec
			rec2 = pop
			_then = pop
			_then = [:POP, _then.execute.first]
			arg = pop
			# Guessing IF
			case 
			when arg.respond_to?(:blank?) then
				_if = [:blank?]
			when arg.respond_to?(:empty?) then
				_if = [:empty]
			when arg.is_a?(Numeric) then
				_if = [0, :==]
			when arg.is_a?(String) then
				_if = ["", :==]
			else
				raise ArgumentError, "PRIMREC: Unable to create IF element for #{arg} (#{arg.class})"
			end
			# Guessing REC1
			case
			when arg.respond_to?(:pred) then
				rec1 = [:DUP, :pred]
			when arg.respond_to?(:length) && arg.respond_to?(:slice) then
				rec1 = [0, (arg.length-2), :slice|2]
			else
				raise ArgumentError, "PRIMREC: Unable to create REC1 element for #{arg} (#{arg.class})"
			end
			concat [arg, _if, _then, rec1, rec2]
			_linrec
		end
			
	end
end

