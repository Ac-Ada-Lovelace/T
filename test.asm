FUNC @main:
	var a, b, c, d, z, x, y

	var e, f, g, h, i, j, k

; T_FltConstant: 1.0
	pushf 1.0
	pop a

; T_FltConstant: 2.0
	pushf 2.0
	pop b

; T_FltConstant: 3.0
	pushf 3.0
	pop c

; T_FltConstant: 4.0
	pushf 4.0
	pop d

; T_IntConstant: 1
	push 1
	pop e

; T_IntConstant: 2
	push 2
	pop f

; T_IntConstant: 3
	push 3
	pop g

; T_IntConstant: 4
	push 4
	pop h

; T_Identifier: aType: flt
	push a
; T_Identifier: bType: flt
	push b
	add
	pop z

; T_Identifier: cType: flt
	push c
; T_Identifier: dType: flt
	push d
	sub
	pop x

; T_Identifier: xType: flt
	push x
; T_Identifier: zType: flt
	push z
	mul
	pop y

; T_Identifier: eType: int
	push e
; T_Identifier: fType: int
	push f
	add
	pop i

; T_Identifier: gType: int
	push g
; T_Identifier: hType: int
	push h
	sub
	pop j

; T_Identifier: iType: int
	push i
; T_Identifier: jType: int
	push j
	add
	pop k

ENDFUNC

