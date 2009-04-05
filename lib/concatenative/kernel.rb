#!usr/bin/env ruby


# Clears the stack.
:CLEAR <= lambda do 
	Concatenative::DATA_STACK.clear
end

# Pops an item out of the stack.
#
# <tt>A =></tt>
:POP <= lambda do
	raise EmptyStackError, "Empty stack" if Concatenative::DATA_STACK.empty?
	return Concatenative::DATA_STACK.pop unless Concatenative::System.frozen
	if Concatenative::System.pushed > 0 then
		Concatenative::System.pushed -= 1
		Concatenative::DATA_STACK.pop
	else
		raise EmptyStackError, "Empty stack" if Concatenative::System.frozen <= 0
		Concatenative::System.popped += 1
		Concatenative::DATA_STACK[Concatenative::System.frozen-Concatenative::System.popped]
	end	
end

:ZAP <= :POP
:DROP <= :POP

# Prints the top stack item.
:PUT <= lambda do
	puts Concatenative::DATA_STACK.last 
end

# Concatenative::System.pushes a user-entered string on the stack. 
:GET <= lambda do
	Concatenative::System.push gets
end

# Duplicates the top stack item.
#
# <tt>A => A A</tt>
:DUP <= lambda do
	raise EmptyStackError, "Empty stack" if Concatenative::DATA_STACK.empty?
	Concatenative::System.push Concatenative::DATA_STACK.last
end

# Swaps the first two elements on the stack.
#
# <tt>A B => B A</tt> 
:SWAP <= lambda do
	a = ~:POP
	b = ~:POP
	Concatenative::System.push a
	Concatenative::System.push b
end

# Prepends an element to an Array.  
#
# <tt>[A] B => [A B]</tt>
:CONS <= lambda do
	array = ~:POP
	element = ~:POP
	raise ArgumentError, "CONS: first element is not an Array." unless array.is_a? Array
	Concatenative::System.push array.insert(0, element)
end

:SWONS <= lambda do
	~:SWAP
	~:CONS
end

# ReConcatenative::System.moves the first element of an array and puts it on the stack, along with the
# new array
#
# <tt>[A] => B [C]</tt> 
:UNCONS <= lambda do
	array = ~:POP
	raise ArgumentError, "UNCONS: first element is not an Array." unless array.is_a? Array
	Concatenative::System.push array.first
	Concatenative::System.push array.drop 1
end

:UNSWONS <= lambda do
	~:UNCONS
	~:SWAP
end

# Concatenates two arrays.
#
# <tt>[A] [B] => [A B]</tt>
:CAT <= lambda do
	array1 = ~:POP
	array2 = ~:POP
	raise ArgumentError, "CAT: first element is not an Array." unless array1.is_a? Array
	raise ArgumentError, "CAT: first element is not an Array." unless array2.is_a? Array
	Concatenative::System.push array2.concat(array1)
end

:CONCAT <= :CAT

# Returns the first element of an array.
#
# <tt>[A B] => A</tt>
:FIRST <= lambda do
	array = ~:POP
	raise ArgumentError, "FIRST: first element is not an Array." unless array.is_a? Array
	raise ArgumentError, "FIRST: empty array." if array.length == 0
	Concatenative::System.push array.first
end

# Returns everything but the first element of an array.
#
# <tt>[A B C] => [B C]</tt>
:REST <= lambda do
	array = ~:POP
	raise ArgumentError, "REST: first element is not an Array." unless array.is_a? Array
	raise ArgumentError, "REST: empty array." if array.length == 0
	array.delete_at 0
	Concatenative::System.push array
end

# Saves A, executes P, Concatenative::System.restores A.
#
# <tt>A [P] => A</tt>
:DIP <= lambda do
	program = ~:POP
	raise ArgumentError, "DIP: first element is not an Array." unless program.is_a? Array
	Concatenative::System.move
	~program
	Concatenative::System.restore
end

# Saves A and B, executes P, Concatenative::System.restores A and B.
#
# <tt>A B [P] => A B</tt>
:TWODIP <= lambda do
	program = ~:POP
	raise ArgumentError, "TWODIP: first element is not an Array." unless program.is_a? Array
	Concatenative::System.move
	Concatenative::System.move
	~program
	Concatenative::System.restore
	Concatenative::System.restore
end

# Saves A, B and C, executes P, Concatenative::System.restores A, B and C.
#
# <tt>A B C [P] => A B C</tt>
:TREEDIP <= lambda do
	program = ~:POP
	raise ArgumentError, "THREEDIP: first element is not an Array." unless program.is_a? Array
	Concatenative::System.move
	Concatenative::System.move
	Concatenative::System.move
	~program
	Concatenative::System.restore
	Concatenative::System.restore
	Concatenative::System.restore
end

# ReConcatenative::System.moves the second item on the stack.
#
# <tt>A B => B</tt>
:POPD <= lambda do
	Concatenative::System.push [:POP]
	~:DIP
end

# Duplicates the second item on the stack
#
# <tt>A B => A A B</tt>
:DUPD <= lambda do
	Concatenative::System.push [:DUP]
	~:DIP
end

# Swaps the second and third items on the stack
#
# <tt>A B C => B A C</tt>
:SWAPD <= lambda do
	Concatenative::System.push [:SWAP]
	~:DIP
end

# 
# <tt>A B C => B C A</tt>
:ROLLUP <= lambda do
	~:SWAP
	Concatenative::System.push [:SWAP]
	~:DIP
end

# 
# <tt>A B C => C A B</tt>
:ROLLDOWN <= lambda do
	Concatenative::System.push [:SWAP]
	~:DIP
	~:SWAP
end

#
# <tt>A B C => C B A</tt>
:ROTATE <= lambda do
	~:SWAP
	Concatenative::System.push [:SWAP]
  ~:DIP
	~:SWAP	
end

# Executes a quoted program.
#
# <tt>[P] => </tt>
:I <= lambda do
	program = ~:POP
	raise ArgumentError, "I: first element is not an Array." unless program.is_a? Array
	~program
end

:CALL <= :I

# Executes THEN if IF is true, otherwise executes ELSE.
#
# <tt>[IF] [THEN] [ELSE] =></tt> 
:IFTE <= lambda do
	_else = ~:POP
	_then = ~:POP
	_if = ~:POP
	raise ArgumentError, "IFTE: first element is not an Array." unless _if.is_a? Array
	raise ArgumentError, "IFTE: second element is not an Array." unless _then.is_a? Array
	raise ArgumentError, "IFTE: third element is not an Array." unless _else.is_a? Array
	Concatenative::System.save_stack
	~_if
	condition = ~:POP
	Concatenative::System.restore_stack
	if condition then
		~_then
	else
		~_else
	end
end

# Quotes the top stack element.
#
# <tt>A => [A]</tt>
:UNIT <= lambda do
	Concatenative::System.push [~:POP]
end

# Executes P for each element of A, Concatenative::System.pushes an array containing the results on the stack.
# 
# <tt>[A] [P] => [B]</tt>
:MAP <= lambda do
	program = ~:POP
	list = ~:POP
	raise ArgumentError, "MAP: first element is not an Array." unless program.is_a? Array
	raise ArgumentError, "MAP: second element is not an array." unless list.is_a? Array
	Concatenative::System.push []
	list.map do |e| 
		Concatenative::System.push e
		~program
		~:UNIT
		~:CAT	
	end
end

# Executes P for each element of A, Concatenative::System.pushes the results on the stack.
# 
# <tt>[A] [P] => B</tt>
:STEP <= lambda do
	program = ~:POP
	list = ~:POP
	raise ArgumentError, "STEP: first element is not an Array." unless program.is_a? Array
	raise ArgumentError, "STEP: second element is not an array." unless list.is_a? Array
	list.map do |e| 
		Concatenative::System.push e
		~program
	end
end

# If IF is true, executes THEN. Otherwise, executes REC1, recurses and then executes REC2.
#
# <tt>[IF] [THEN] [REC1] [REC2] =></tt>
:LINREC <= lambda do
	rec2 = ~:POP
	rec1 = ~:POP
	_then = ~:POP
	_if = ~:POP
	raise ArgumentError, "LINREC: first element is not an Array." unless _if.is_a? Array
	raise ArgumentError, "LINREC: second element is not an Array." unless _then.is_a? Array
	raise ArgumentError, "LINREC: third element is not an Array." unless rec1.is_a? Array
	raise ArgumentError, "LINREC: fourth element is not an Array." unless rec2.is_a? Array
	Concatenative::System.save_stack
	~_if
	condition = ~:POP
	Concatenative::System.restore_stack
	if condition then
		~_then
	else
		~rec1
		[_if, _then, rec1, rec2].each {|e| Concatenative::System.push e }
		~:LINREC
		~rec2
	end
end

#	Same as _linrec, but it is only necessary to specify THEN and REC2.
#
#	* REC1 = a program to reduce A to its zero value (0, [], "").
#	* IF = a condition to verify if A is its zero value (0, [], "") or not.
#
# <tt>A [THEN] [REC2] =><tt> 
:PRIMREC <= lambda do
	rec2 = ~:POP
	_then = [:POP, ~:POP, :I]
	arg = ~:POP
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
	[arg, _if, _then, rec1, rec2].each {|e| Concatenative::System.push e }
	~:LINREC
end

# Executes P N times.
#
# <tt>N [P] => </tt>
:TIMES <= lambda do
	program = ~:POP
	n = ~:POP
	raise ArgumentError, "TIMEs: second element is not an Array." unless program.is_a? Array
	n.times { ~program.clone }
end

# While COND is true, executes P
#
# <tt>[P] [COND] => </tt>
:WHILE <= lambda do
	program = ~:POP
	cond = ~:POP
	raise ArgumentError, "WHILE: first element is not an Array." unless cond.is_a? Array
	raise ArgumentError, "WHILE: second element is not an Array." unless program.is_a? Array
	Concatenative::System.save_stack
	~cond
	res = ~:POP
	Concatenative::System.restore_stack
	if res then 
		~program
		[cond, program].each {|e| Concatenative::System.push e }
		~:WHILE
	end
end

# Splits an Array into two parts, depending on which element satisfy a condition
#
# <tt>[A] [P] => [B] [C]</tt>
:SPLIT <= lambda do
	cond = ~:POP
	array = ~:POP
	raise ArgumentError, "SPLIT: first element is not an Array." unless cond.is_a? Array
	raise ArgumentError, "SPLIT: second element is not an Array." unless array.is_a? Array
	yes, no = [], []
	array.each do |e|
		Concatenative::System.save_stack
		Concatenative::System.push e
		~cond.dup
		~:POP ? yes << e : no << e
		Concatenative::System.restore_stack
	end
	Concatenative::System.push yes
	Concatenative::System.push no
end

# If IF is true, executes THEN. Otherwise, executes REC1 (which must return two elements),
# recurses twice and then executes REC2.
#
# <tt>[IF] [THEN] [REC1] [REC2] =></tt>
:BINREC <= lambda do
	rec2 = ~:POP
	rec1 = ~:POP
	_then = ~:POP
	_if = ~:POP
	raise ArgumentError, "BINREC: first element is not an Array." unless _if.is_a? Array
	raise ArgumentError, "BINREC: second element is not an Array." unless _then.is_a? Array
	raise ArgumentError, "BINREC: third element is not an Array." unless rec1.is_a? Array
	raise ArgumentError, "BINREC: fourth element is not an Array." unless rec2.is_a? Array
	Concatenative::System.save_stack
	~_if
	condition = ~:POP
	Concatenative::System.restore_stack
	if condition then
		~_then
	else
		~rec1
		a = ~:POP
		b = ~:POP
		[b, _if, _then, rec1, rec2].each {|e| Concatenative::System.push e }
		~:BINREC
		[a, _if, _then, rec1, rec2].each {|e| Concatenative::System.push e }
		~:BINREC
		~rec2
	end
end
