#!usr/bin/env ruby

module Concatenative

	module Kernel

		# Clears the stack.
		def clear
			STACK.clear
		end

		# Pops an item out of the stack.
		#
		# <tt>A =></tt>
		def pop
			raise EmptyStackError, "Empty stack" if STACK.empty?
			return STACK.pop unless @frozen
			if @pushed > 0 then
				@pushed -= 1
				STACK.pop
			else
				raise EmptyStackError, "Empty stack" if @frozen <= 0
				@popped += 1
				STACK[@frozen-@popped]
			end	
		end

		# Prints the top stack item.
		def put
			puts STACK.last 
		end

		# Pushes a user-entered string on the stack. 
		def get
			push gets
		end

		# Duplicates the top stack item.
		#
		# <tt>A => A A</tt>
		def dup
			raise EmptyStackError, "Empty stack" if STACK.empty?
			push STACK.last
		end

		# Swaps the first two elements on the stack.
		#
		# <tt>A B => B A</tt> 
		def swap
			a = pop
			b = pop
			push a
			push b
		end

		# Prepends an element to an Array.  
		#
		# <tt>[A] B => [A B]</tt>
		def cons
			array = pop
			element = pop
			raise ArgumentError, "CONS: first element is not an Array." unless array.is_a? Array
			push array.insert(0, element)
		end

		def swons
			swap
			cons
		end

		# Removes the first element of an array and puts it on the stack, along with the
		# new array
		#
		# <tt>[A] => B [C]</tt> 
		def uncons
			array = pop
			raise ArgumentError, "UNCONS: first element is not an Array." unless array.is_a? Array
			push array.first
			push array.drop 1
		end

		def unswons
			uncons
			swap
		end

		# Concatenates two arrays.
		#
		# <tt>[A] [B] => [A B]</tt>
		def cat
			array1 = pop
			array2 = pop
			raise ArgumentError, "CAT: first element is not an Array." unless array1.is_a? Array
			raise ArgumentError, "CAT: first element is not an Array." unless array2.is_a? Array
			push array2.concat(array1)
		end

		# Returns the first element of an array.
		#
		# <tt>[A B] => A</tt>
		def first
			array = pop
			raise ArgumentError, "FIRST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "FIRST: empty array." if array.length == 0
			push array.first
		end

		# Returns everything but the first element of an array.
		#
		# <tt>[A B C] => [B C]</tt>
		def rest
			array = pop
			raise ArgumentError, "REST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "REST: empty array." if array.length == 0
			array.delete_at 0
			push array
		end

		alias drop pop
		alias zap pop
		alias concat cat

		# Saves A, executes P, restores A.
		#
		# <tt>A [P] => A</tt>
		def dip
			program = pop
			raise ArgumentError, "DIP: first element is not an Array." unless program.is_a? Array
			item = pop
			~program
			push item
		end

		# Saves A and B, executes P, restores A and B.
		#
		# <tt>A B [P] => A B</tt>
		def twodip
			program = pop
			raise ArgumentError, "2DIP: first element is not an Array." unless program.is_a? Array
			items = []
			2.times { items << pop }
			~program
			items.reverse.each {|i| push i }
		end

		# Saves A, B and C, executes P, restores A, B and C.
		#
		# <tt>A B C [P] => A B C</tt>
		def threedip
			program = pop
			raise ArgumentError, "2DIP: first element is not an Array." unless program.is_a? Array
			items = []
			3.times { items << pop }
			~program
			items.reverse.each {|i| push i }
		end
		
		# Removes the second item on the stack.
		#
		# <tt>A B => B</tt>
		def popd
			push [:pop]
			dip
		end

		# Duplicates the second item on the stack
		#
		# <tt>A B => A A B</tt>
		def dupd
			push [:dup]
			dip
		end

		# Swaps the second and third items on the stack
		#
		# <tt>A B C => B A C</tt>
		def swapd
			push [:swap]
			dip
		end

		# 
		# <tt>A B C => B C A</tt>
		def rollup
			swap
			push [:swap]
			dip
		end

		# 
		# <tt>A B C => C A B</tt>
		def rolldown
			push [:swap]
			dip
			swap
		end

		#
		# <tt>A B C => C B A</tt>
		def rotate
			swap
			push [:swap]
			dip
			swap
		end

		# Executes a quoted program.
		#
		# <tt>[P] => </tt>
		def i
			program = pop
			raise ArgumentError, "I: first element is not an Array." unless program.is_a? Array
			~program
		end

		# Executes THEN if IF is true, otherwise executes ELSE.
		#
		# <tt>[IF] [THEN] [ELSE] =></tt> 
		def ifte
			_else = pop
			_then = pop
			_if = pop
			raise ArgumentError, "IFTE: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "IFTE: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "IFTE: third element is not an Array." unless _else.is_a? Array
			save_stack
			~_if
			condition = pop
			restore_stack
			if condition then
				~_then
			else
				~_else
			end
		end

		alias if ifte

		# Quotes the top stack element.
		#
		# <tt>A => [A]</tt>
		def unit
			push [pop]
		end

		# Executes P for each element of A, pushes an array containing the results on the stack.
		# 
		# <tt>[A] [P] => [B]</tt>
		def map
			program = pop
			list = pop
			raise ArgumentError, "MAP: first element is not an Array." unless program.is_a? Array
			raise ArgumentError, "MAP: second element is not an array." unless list.is_a? Array
			push []
			list.map do |e| 
				push e
				~program
				unit
				cat
			end
		end

		# Executes P for each element of A, pushes the results on the stack.
		# 
		# <tt>[A] [P] => B</tt>
		def step
			program = pop
			list = pop
			raise ArgumentError, "STEP: first element is not an Array." unless program.is_a? Array
			raise ArgumentError, "STEP: second element is not an array." unless list.is_a? Array
			list.map do |e| 
				push e
				~program
			end
		end

		# If IF is true, executes THEN. Otherwise, executes REC1, recurses and then executes REC2.
		#
		# <tt>[IF] [THEN] [REC1] [REC2] =></tt>
		def linrec
			rec2 = pop
			rec1 = pop
			_then = pop
			_if = pop
			raise ArgumentError, "LINREC: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "LINREC: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "LINREC: third element is not an Array." unless rec1.is_a? Array
			raise ArgumentError, "LINREC: fourth element is not an Array." unless rec2.is_a? Array
			save_stack
			~_if
			condition = pop
			restore_stack
			if condition then
				~_then
			else
				~rec1
				[_if, _then, rec1, rec2].each {|e| push e }
				linrec
				~rec2
			end
		end

		#	Same as linrec, but it is only necessary to specify THEN and REC2.
		#	* REC1 = a program to reduce A to its zero value (0, [], "").
		#	* IF = a condition to verify if A is its zero value (0, [], "") or not.
		#
		# <tt>A [THEN] [REC2] =><tt> 
		def primrec
			rec2 = pop
			_then = [:pop, pop, :i]
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
			when arg.respond_to?(:length) && arg.respond_to?(:slice) then
				rec1 = [0, (arg.length-2), :slice|2]
			when arg.respond_to?(:-) then
				rec1 = [:dup, 1, :-]
			else
				raise ArgumentError, "PRIMREC: Unable to create REC1 element for #{arg} (#{arg.class})"
			end
			[arg, _if, _then, rec1, rec2].each {|e| push e }
			linrec
		end

		# Executes P N times.
		#
		# <tt>N [P] => </tt>
		def times
			program = pop
			n = pop
			raise ArgumentError, "TIMEs: second element is not an Array." unless program.is_a? Array
			n.times { ~program.dup }
		end

		# While COND is true, executes P
		#
		# <tt>[P] [COND] => </tt>
		def while
			program = pop
			cond = pop
			raise ArgumentError, "WHILE: first element is not an Array." unless cond.is_a? Array
			raise ArgumentError, "WHILE: second element is not an Array." unless program.is_a? Array
			save_stack
			~cond
			res = pop
			restore_stack
			if res then 
				~program
				[cond, program].each {|e| push e }
				self.while
			end
		end

		# Splits an Array into two parts, depending on which element satisfy a condition
		#
		# <tt>[A] [P] => [B] [C]</tt>
		def split
			cond = pop
			array = pop
			raise ArgumentError, "SPLIT: first element is not an Array." unless cond.is_a? Array
			raise ArgumentError, "SPLIT: second element is not an Array." unless array.is_a? Array
			yes, no = [], []
			array.each do |e|
				save_stack
				push e
				~cond.dup
				pop ? yes << e : no << e
				restore_stack
			end
			push yes
			push no
		end
		
		# If IF is true, executes THEN. Otherwise, executes REC1 (which must return two elements),
		# recurses twice and then executes REC2.
		#
		# <tt>[IF] [THEN] [REC1] [REC2] =></tt>
		def binrec
			rec2 = pop
			rec1 = pop
			_then = pop
			_if = pop
			raise ArgumentError, "BINREC: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "BINREC: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "BINREC: third element is not an Array." unless rec1.is_a? Array
			raise ArgumentError, "BINREC: fourth element is not an Array." unless rec2.is_a? Array
			save_stack
			~_if
			condition = pop
			restore_stack
			if condition then
				~_then
			else
				~rec1
				a = pop
				b = pop
				[b, _if, _then, rec1, rec2].each {|e| push e }
				binrec
				[a, _if, _then, rec1, rec2].each {|e| push e }
				binrec
				~rec2
			end
		end

	end
end
