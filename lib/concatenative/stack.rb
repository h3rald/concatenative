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
			from_a dup.concat(program).execute
		end

		def _ifte
			_else = pop
			_then = pop
			_if = pop
			arg = pop
			raise ArgumentError, "IFTE: first element is not a quoted program." unless _if.is_a? Array
			raise ArgumentError, "IFTE: second element is not a quoted program." unless _then.is_a? Array
			raise ArgumentError, "IFTE: third element is not a quoted program." unless _else.is_a? Array
			condition = _if.dup.prepend(arg).execute
			concat (condition.first) ? _then.dup.prepend(arg).execute : _else.dup.prepend(arg).execute
		end

		def _map
			program = pop
			list = pop
			raise ArgumentError, "MAP: first element is not a quoted program." unless program.is_a? Array
			raise ArgumentError, "MAP: second element is not an array." unless list.is_a? Array
			push list.map {|e| program.dup.prepend(e).execute.first }
		end
	
		def _step
			program = pop
			list = pop
			raise ArgumentError, "STEP: first element is not a quoted program." unless program.is_a? Array
			raise ArgumentError, "STEP: second element is not an array." unless list.is_a? Array
			list.map {|e| push program.dup.prepend(e).execute.first }
		end
	
	end
end

