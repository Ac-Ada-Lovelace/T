; enter scope
; enter scope
FUNC @main:
	var a

; enter scope
; exit scope
; loss access to scope
; a : int
; T_IntConstant: 1
	push 1
; Try get symbol: a
; a : int
	pop a

ENDFUNC

; exit scope
; loss access to scope
