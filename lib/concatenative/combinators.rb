#!usr/bin/env ruby

module Concatenative

	module Combinators

		# Clears the stack.
		def _clear
			DATA_STACK.clear
		end

		# Pops an item out of the stack.
		#
		# A, B => A
		def _pop
			raise EmptyStackError, "Empty stack" if DATA_STACK.empty?
			return DATA_STACK.pop unless @frozen
			if @pushed > 0 then
				@pushed -= 1
				DATA_STACK.pop
			else
				raise EmptyStackError, "Empty stack" if @frozen <= 0
				@popped += 1
				DATA_STACK[@frozen-@popped]
			end	
		end

		# Prints the top stack item.
		def _put
			puts DATA_STACK.last 
		end

		# Pushes a user-entered string on the stack. 
		def _get
			push gets
		end

		# Duplicates the top stack item.
		#
		# A => A, A
		def _dup
			raise EmptyStackError, "Empty stack" if DATA_STACK.empty?
			push DATA_STACK.last
		end

		# Swaps the first two elements on the stack.
		#
		# A, B => B, A 
		def _swap
			
			a = _pop
			b = _pop
			push a
			push b
		end

		# Prepends an element to an Array.  
		#
		# [A], B => [A, B]
		def _cons
			array = _pop
			element = _pop
			raise ArgumentError, "CONS: first element is not an Array." unless array.is_a? Array
			push array.insert(0, element)
		end

		def _swons
			_swap
			_cons
		end

		# Removes the first element of an array and puts it on the stack, along with the
		# new array
		#
		# [A] => B [C] 
		def _uncons
			array = _pop
			raise ArgumentError, "UNCONS: first element is not an Array." unless array.is_a? Array
			push array.first
			push array.drop 1
		end

		def _unswons
			_uncons
			_swap
		end

		# Concatenates two arrays.
		#
		# [A], [B] => [A, B]
		def _cat
			array1 = _pop
			array2 = _pop
			raise ArgumentError, "CAT: first element is not an Array." unless array1.is_a? Array
			raise ArgumentError, "CAT: first element is not an Array." unless array2.is_a? Array
			push array2.concat(array1)
		end

		# Returns the first element of an array.
		#
		# [A, B] => A
		def _first
			array = _pop
			raise ArgumentError, "FIRST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "FIRST: empty array." if array.length == 0
			push array.first
		end

		# Returns everything but the first element of an array.
		#
		# [A, B, C] => [B, C]
		def _rest
			array = _pop
			raise ArgumentError, "REST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "REST: empty array." if array.length == 0
			array.delete_at 0
			push array
		end

		alias _drop _pop
		alias _zap _pop
		alias _concat _cat

		# Saves A, executes P, restores A.
		#
		# A, [P] => A
		def _dip
			program = _pop
			raise ArgumentError, "DIP: first element is not an Array." unless program.is_a? Array
			save
			program.unquote
			restore
		end

		# Saves A and B, executes P, restores A and B.
		#
		# A, B, [P] => A, B
		def _2dip
			program = _pop
			raise ArgumentError, "2DIP: first element is not an Array." unless program.is_a? Array
			save
			save
			program.unquote
			restore
			restore
		end

		# Saves A, B and C, executes P, restores A, B and C.
		#
		# A, B, C, [P] => A, B, C
		def _3dip
			program = _pop
			raise ArgumentError, "2DIP: first element is not an Array." unless program.is_a? Array
			save
			save
			save
			program.unquote
			restore
			restore
			restore
		end

		def _popd
			push [:POP]
			_dip
		end

		def _dupd
			push [:DUP]
			_dip
		end

		def _swapd
			push [:SWAP]
			_dip
		end

		def _sip
			_dupd
			_swap
			push [:I]
			_dip
		end

		def _rollup
			_swap
			push [:SWAP]
			_dip
		end
		
		def _rolldown
			push [:SWAP]
			_dip
			_swap
		end

		def _rotate
			_swap
			push [:SWAP]
			_dip
			_swap
		end

		# Executes a quoted program.
		#
		# [P] => 
		def _i
			program = _pop
			raise ArgumentError, "I: first element is not an Array." unless program.is_a? Array
			program.unquote
		end

		def _rep
			_i
			_dup
		end

		# Executes THEN if IF is true, otherwise executes ELSE.
		#
		# A, [IF], [THEN], [ELSE] => B
		def _ifte
			_else = _pop
			_then = _pop
			_if = _pop
			raise ArgumentError, "IFTE: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "IFTE: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "IFTE: third element is not an Array." unless _else.is_a? Array
			save_stack
			_if.unquote
			condition = _pop
			restore_stack
			if condition then
				_then.unquote
			else
				_else.unquote
			end
		end

		# Quotes the top stack element.
		#
		# A => [A]
		def _unit
			push [_pop]
		end

		# Executes P for each element of A, pushes an array containing the results on the stack.
		# 
		# [A], [P] => [B]
		def _map
			program = _pop
			list = _pop
			raise ArgumentError, "MAP: first element is not an Array." unless program.is_a? Array
			raise ArgumentError, "MAP: second element is not an array." unless list.is_a? Array
			push []
			list.map do |e| 
				push e
				program.unquote
				_unit
				_cat
			end
		end

		# Executes P for each element of A, pushes the results on the stack.
		# 
		# [A], [P] => B
		def _step
			program = _pop
			list = _pop
			raise ArgumentError, "STEP: first element is not an Array." unless program.is_a? Array
			raise ArgumentError, "STEP: second element is not an array." unless list.is_a? Array
			list.map do |e| 
				push e
				program.unquote
			end
		end

		# If IF is true, executes THEN. Otherwise, executes REC1, recurses and then executes REC2.
		#
		# A, [IF], [THEN], [REC1], [REC2] => B
		def _linrec
			rec2 = _pop
			rec1 = _pop
			_then = _pop
			_if = _pop
			raise ArgumentError, "LINREC: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "LINREC: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "LINREC: third element is not an Array." unless rec1.is_a? Array
			raise ArgumentError, "LINREC: fourth element is not an Array." unless rec2.is_a? Array
			save_stack
			_if.unquote
			condition = _pop
			restore_stack
			if condition then
				_then.unquote
			else
				rec1.unquote
				[_if, _then, rec1, rec2].each {|e| push e }
				_linrec
				rec2.unquote
			end
		end

		#	Same as _linrec, but it is only necessary to specify THEN and REC2.
		#
		#	* REC1 = a program to reduce A to its zero value (0, [], "").
		#	* IF = a condition to verify if A is its zero value (0, [], "") or not.
		#
		# A, [THEN], [REC2] => B 
		def _primrec
			rec2 = _pop
			_then = [:POP, _pop, :I]
			arg = _pop
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
			when arg.respond_to?(:length) && arg.respond_to?(:slice) then
				rec1 = [0, (arg.length-2), :slice|2]
			when arg.respond_to?(:-) then
				rec1 = [:DUP, 1, :-]
			else
				raise ArgumentError, "PRIMREC: Unable to create REC1 element for #{arg} (#{arg.class})"
			end
			[arg, _if, _then, rec1, rec2].each {|e| push e }
			_linrec
		end

		# Executes P N times.
		#
		# N [P] => A
		def _times
			program = _pop
			n = _pop
			raise ArgumentError, "TIMEs: second element is not an Array." unless program.is_a? Array
			n.times { program.clone.unquote }
		end

		# While COND is true, executes P
		#
		# [P] [COND] => A
		def _while
			program = _pop
			cond = _pop
			raise ArgumentError, "WHILE: first element is not an Array." unless cond.is_a? Array
			raise ArgumentError, "WHILE: second element is not an Array." unless program.is_a? Array
			save_stack
			cond.unquote
			res = _pop
			restore_stack
			if res then 
				program.unquote
				[cond, program].each {|e| push e }
				_while
			end
		end

		# Splits an Array into two parts, depending on which element satisfy a condition
		#
		# [A] [P] => [B] [C]
		def _split
			cond = _pop
			array = _pop
			raise ArgumentError, "SPLIT: first element is not an Array." unless cond.is_a? Array
			raise ArgumentError, "SPLIT: second element is not an Array." unless array.is_a? Array
			yes, no = [], []
			array.each do |e|
				save_stack
				push e
				cond.dup.unquote
				_pop ? yes << e : no << e
				restore_stack
			end
			push yes
			push no
		end
		
		# If IF is true, executes THEN. Otherwise, executes REC1 (which must return two elements),
		# recurses twice and then executes REC2.
		#
		# A, [IF], [THEN], [REC1], [REC2] => B
		def _binrec
			rec2 = _pop
			rec1 = _pop
			_then = _pop
			_if = _pop
			raise ArgumentError, "BINREC: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "BINREC: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "BINREC: third element is not an Array." unless rec1.is_a? Array
			raise ArgumentError, "BINREC: fourth element is not an Array." unless rec2.is_a? Array
			save_stack
			_if.unquote
			condition = _pop
			restore_stack
			if condition then
				_then.unquote
			else
				rec1.unquote
				a = _pop
				b = _pop
				[b, _if, _then, rec1, rec2].each {|e| push e }
				_binrec
				[a, _if, _then, rec1, rec2].each {|e| push e }
				_binrec
				rec2.unquote
			end
		end

	end
end
