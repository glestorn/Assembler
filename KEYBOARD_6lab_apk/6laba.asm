.286
.MODEL	small
.STACK	100h
.DATA
	LIGHT_MODE 	db	0EDh
	SET_LAMP	db	0FAh
	SET_ERR 	db	0FEh
	DELAY_TIME	dw	0002h,86A0h
	SMALL_DELAY	dw 	0001h,86A0h
	old_handler	dd	?
	code_mess	db 	0ah,"Code is ",'$'	
	code_num	db	?,?,'$'
	err_mess	db	"There is an error in lamp setting",'$'
.CODE

print	macro offs
	pusha
	lea 	dx,offs
	mov	ah,9h
	int 	21h
	popa
endm 	print

make_delay macro offs
	pusha
	mov	cx,offs[0]
	mov	dx,offs[2]
	mov	ah,86h
	int 	15h
	popa
endm make_delay

set_lights	macro	mode,signal
	pusha
	mov	dx,0
set_constr:
	mov	bx,0
once_again:
	in 	al,64h
	and 	al,2
	cmp	al,0
	je	continue
	jmp	once_again

continue:
	inc	bx
	cmp	bx,4
	jae	set_error

	cmp	dx,0
	jne 	signal_set
	mov	al,mode
	jmp	miss_signal_set
signal_set:
	mov	al,signal

miss_signal_set:
	out	60h,al
	in 	al,60h
	cmp	al,SET_ERR
	je 	continue

	inc	dx
	cmp	dx,1
	je 	set_constr
	popa
endm		set_lights

hex_convert	macro
	cmp	al,0Ah
	jae	al_letter
	add	al,'0'
	jmp	convert_ah
al_letter:
	sub	al,0Ah
	xadd	'A',al

	cmp	ah,0Ah
	jae	ah_letter
	add	ah,'0'
	jmp	finish_convert
ah_letter:
	sub	ah,0Ah
	xadd	'A',ah
finish_convert:
hex_convert	endm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
start:
	mov	ax,@DATA
	mov	ds,ax

	call	set_new_handler
	mov	cx,7

loop_lights:
	set_lights 	LIGHT_MODE,cl
	make_delay 	DELAY_TIME
	cmp 	cx,1
	ja	loop_lights
	mov	cx,7
	jmp 	loop_lights
	
finish:
	call	restore_handler
	mov	ah,4Ch
	int	21h

set_error:
	print	err_mess
	jmp 	finish
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
new_handler proc far
	pusha
	pushf
	mov	ax,0
    	in 	al,60h
    	cmp 	al,SET_LAMP
    	je	inter_end

    	mov	dl,10h
    	div	dl
    	hex_convert
    	mov	code_num[0],al
    	mov	code_num[1],ah
    	print	code_mess
    	print	code_num

inter_end:
	popf
	popa
	pushf
	call 	cs:[old_handler]
	iret
new_handler endp

set_new_handler proc
	mov	ah,35h
	mov	al,09h
	int 	21h
	mov	word ptr old_handler,bx
	mov	word ptr old_handler+2,es
cli
	mov	ah,25h
	mov	al,09h
	lea 	dx,new_handler
	int 	21h
sti
	ret
set_new_handler endp

restore_handler proc
	lds	dx,old_handler
	mov	ax,2587h
	int 	21h
	ret
restore_handler endp
end	start