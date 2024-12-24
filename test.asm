FUNC @main:
	var a

; loss access to scope
; a : int
; T_IntConstant: 1
	push 1
	pop a

ENDFUNC

; loss access to scope
