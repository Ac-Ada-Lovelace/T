FUNC @main:
	var aint, bint, c

	push 1
	pop a

	push 2
	pop b

	push a
	push b
	add
	pop c

ENDFUNC

