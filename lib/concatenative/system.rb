#!usr/bin/env ruby

module Concatenative

	# The System module includes the STACK constant, methods to interpret items pushed on 
	# the stack and the implementations of all concatenative combinators and operators. 
	module System
		
		STACK = []

		# Executes an array as a concatenative program (clears the stack first).
		def self.execute(array)
			STACK.clear
			array.each { |e| process e }
			(STACK.length == 1) ? STACK[0] : STACK
		end

		# Processes an item (without clearning the stack).
		def self.process(item)
			case
			when !item.is_a?(Symbol) && !item.is_a?(Concatenative::RubyMessage) then
				_push item
			when item.is_a?(Symbol) && item.definition then
				item.definition.each {|e| process e}
			else
				call_function item
			end
		end

		# Calls a function (defined using Symbol#define) or a Ruby method identified by item (a Symbol or RubyMessage).
		def self.call_function(item)
			name = "_#{item.to_s.downcase}".to_sym
			if (item.to_s.upcase == item.to_s) && !ARITIES[item] then
				respond_to?(name) ?	send(name) : raise(RuntimeError, "Unknown function: #{item}")
			else
				_push send_message(item)
			end
		end

		# Calls a Ruby method, consuming elements from the stack according to its
		# explicit or implicit arity.
		def self.send_message(message)
			raise EmptyStackError, "Empty stack" if STACK.empty?
			case
			when message.is_a?(Concatenative::RubyMessage) then
				n = message.arity
				method = message.name
			when message.is_a?(Symbol) then
				n = ARITIES[message] || 0
				method = message
			end
			elements = []
			(n+1).times { elements << _pop }
			receiver = elements.pop
			args = []
			(elements.length).times { args << elements.pop }
			begin
				(args.length == 0)	? receiver.send(method) :	receiver.send(method, *args)
			rescue Exception => e
				raise RuntimeError, 
					"Error when calling: #{receiver}##{method}(#{args.join(', ')}) [#{receiver.class}##{method}]"
			end
		end

		# Operators & Combinators

		# Clears the stack.
		def self._clear
			STACK.clear
		end

		# Pops an item out of the stack.
		#
		# A, B => A
		def self._pop
			raise EmptyStackError, "Empty stack" if STACK.empty?
			STACK.pop
		end

		# Pushes an item on the stack.
		#
		# A => A, B
		def self._push(element)
			STACK.push element
		end

		# Prints the top stack item.
		def self._put
			puts STACK.last 
		end

		# Pushes a user-entered string on the stack. 
		def self._get
			_push gets
		end

		# Duplicates the top stack item.
		#
		# A => A, A
		def self._dup
			raise EmptyStackError, "Empty stack" if STACK.empty?
			_push STACK.last
		end

		# Swaps the first two elements on the stack.
		#
		# A, B => B, A 
		def self._swap
			a = _pop
			b = _pop
			_push a
			_push b
		end

		# Prepends an element to an Array.  
		#
		# [A], B => [A, B]
		def self._cons
			array = _pop
			element = _pop
			raise ArgumentError, "CONS: first element is not an Array." unless array.is_a? Array
			_push array.insert(0, element)
		end

		# Concatenates two arrays.
		#
		# [A], [B] => [A, B]
		def self._cat
			array1 = _pop
			array2 = _pop
			raise ArgumentError, "CAT: first element is not an Array." unless array1.is_a? Array
			raise ArgumentError, "CAT: first element is not an Array." unless array2.is_a? Array
			_push array2.concat(array1)
		end

		# Returns the first element of an array.
		#
		# [A, B] => A
		def self._first
			array = _pop
			raise ArgumentError, "FIRST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "FIRST: empty array." if array.length == 0
			_push array.first
		end

		# Returns everything but the first element of an array.
		#
		# [A, B, C] => [B, C]
		def self._rest
			array = _pop
			raise ArgumentError, "REST: first element is not an Array." unless array.is_a? Array
			raise ArgumentError, "REST: empty array." if array.length == 0
			array.delete_at 0
			_push array
		end

		instance_eval do
			alias _zap _pop
			alias _concat _cat
		end

		# Saves A, executes P, pushes A back.
		#
		# A, [P] => B, A
		def self._dip
			program = _pop
			raise ArgumentError, "DIP: first element is not an Array." unless program.is_a? Array
			arg = _pop
			program.unquote
			_push arg
		end

		# Executes a quoted program.
		#
		# [P] => A
		def self._i
			program = _pop
			raise ArgumentError, "I: first element is not an Array." unless program.is_a? Array
			program.unquote
		end

		# Executes THEN if IF is true, otherwise executes ELSE.
		#
		# A, [IF], [THEN], [ELSE] => B
		def self._ifte
			_else = _pop
			_then = _pop
			_if = _pop
			raise ArgumentError, "IFTE: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "IFTE: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "IFTE: third element is not an Array." unless _else.is_a? Array
			snapshot = STACK.clone
			_if.unquote
			condition = _pop
			STACK.replace snapshot
			if condition then
				_then.unquote
			else
				_else.unquote
			end
		end

		# Quotes the top stack element.
		#
		# A => [A]
		def self._unit
			_push [_pop]
		end

		# Executes P for each element of A, pushes an array containing the results on the stack.
		# 
		# [A], [P] => [B]
		def self._map
			program = _pop
			list = _pop
			raise ArgumentError, "MAP: first element is not an Array." unless program.is_a? Array
			raise ArgumentError, "MAP: second element is not an array." unless list.is_a? Array
			_push []
			list.map do |e| 
				_push e
				program.unquote
				_unit
				_cat
			end
		end

		# Executes P for each element of A, pushes the results on the stack.
		# 
		# [A], [P] => B
		def self._step
			program = _pop
			list = _pop
			raise ArgumentError, "STEP: first element is not an Array." unless program.is_a? Array
			raise ArgumentError, "STEP: second element is not an array." unless list.is_a? Array
			list.map do |e| 
				_push e
				program.unquote
			end
		end

		# If IF is true, executes THEN. Otherwise, executes REC1, recurses and then executes REC2.
		#
		# A, [IF], [THEN], [REC1], [REC2] => B
		def self._linrec
			rec2 = _pop
			rec1 = _pop
			_then = _pop
			_if = _pop
			raise ArgumentError, "LINREC: first element is not an Array." unless _if.is_a? Array
			raise ArgumentError, "LINREC: second element is not an Array." unless _then.is_a? Array
			raise ArgumentError, "LINREC: third element is not an Array." unless rec1.is_a? Array
			raise ArgumentError, "LINREC: fourth element is not an Array." unless rec2.is_a? Array
			snapshot = STACK.clone
			_if.unquote
			condition = _pop
			STACK.replace snapshot
			if condition then
				_then.unquote
			else
				rec1.unquote
				STACK.concat [_if, _then, rec1, rec2]
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
		def self._primrec
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
			STACK.concat [arg, _if, _then, rec1, rec2]
			_linrec
		end

		# Executes P N times.
		#
		# N [P] => A
		def self._times
			program = _pop
			n = _pop
			raise ArgumentError, "TIMEs: second element is not an Array." unless program.is_a? Array
			n.times { program.clone.unquote }
		end

		# While COND is true, executes P
		#
		# [P] [COND] => A
		def self._while
			program = _pop
			cond = _pop
			raise ArgumentError, "WHILE: first element is not an Array." unless cond.is_a? Array
			raise ArgumentError, "WHILE: second element is not an Array." unless program.is_a? Array
			snapshot = STACK.clone
			cond.unquote
			res = _pop
			STACK.replace snapshot
			if res then 
				program.unquote
				STACK.concat [cond, program]
				_while
			end
		end
		
	end
end

