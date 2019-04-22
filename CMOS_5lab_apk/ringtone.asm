.286
MAIN segment
ASSUME cs:MAIN,ds:MAIN,es:MAIN,ss:MAIN
	org 	100h
	start:
	jmp start_code

print macro offs
	push 	ds
	mov 	ax,seg offs
	mov 	ds,ax
	lea	dx,offs
	mov 	ah,9h
	int 	21h
	pop 	ds
endm print 

input macro offs
	push 	ds
	mov 	ax,seg offs
	mov 	ds,ax
	lea	dx,offs
	mov	ah,0Ah
	int	21h
	pop 	ds
endm input

set_time macro register,offs
	push 	ds
	mov  	ax,seg time
	mov  	ds,ax
	mov 	ax,16
	mov 	ah,time[offs]
	sub 	ah,'0'
	mul 	ah
	add 	al,time[offs][1]
	sub 	al,'0'
	mov 	register,al
	pop 	ds
endm set_time

new_handler proc 
	; pushf
 ;    	pusha
 ;    	push 	ds
 ;    	push 	es
    	mov 	ax,seg success
    	mov 	ds,ax
    	mov 	dx,offset success
    	mov 	ah,9h
    	int 	21h
 
    	mov 	ah,07
    	int 	1Ah
    	; pop 	es
    	; pop 	ds
    	; popa
    	; popf
	iret
new_handler endp

start_code:
	mov 	ax,seg flag
	mov 	ds,ax
	mov 	ah,0
	cmp 	flag,ah
	je 	continue
	jmp 	finish
continue:
	mov	ah,07h
	int	1ah
	print request_for_input
	print enter_string
	input time
	set_time ch,2
	set_time cl,5
	set_time dh,8
	mov	ah,06h
	int	1Ah
	print enter_string

	mov 	ah,35h
	mov 	al,4Ah
	int 	21h
	mov 	word ptr old_handler,bx
	mov 	word ptr old_handler+2,es
	
cli
    	mov 	ah,25h
    	mov 	al,4Ah
    	lea 	dx,new_handler
    	int 	21h
sti
	; mov ah,49h
	; mov es,word ptr cs:[2Ch]
	; int 21h

	;pushf 
	;call old_handler
	; mov al,0Bh
	; out 70h,al
	; in al,71h
	; or al,00100000b
	; out 71h,al
	; in al,0A1h
	; and al,11111110b
	; out 0A1h,al


    ; mov ah,31h
    ; mov dx,(s1-start+15)/16;объем резервируемой памяти в параграфах
    ; int 21h
	; mov ah,49h
	; int 21h
 
 	; mov ah,1
 	; int 21h
 	; mov 	cx,1CC9h
 	; mov 	dx,0C380h
 	; mov 	ah,86h
 	; int 	15h
 ; 	mov 	ax,seg MAIN
	; mov 	ds,ax
; pause:

	; mov 	ah,0
	; cmp 	flag,ah
	; je	save
 ; 	mov 	ax,254Ah
 ; 	mov 	ds,word ptr cs:[old_handler+2]
 ; 	mov 	dx,word ptr cs:[old_handler]
 ; 	int 	21h

 ; 	push 	cs
	; pop 	ds
	; push 	cs
	; pop  	es
	; mov 	ah,49h
	; int 	21h
	;jmp finish

save:
	mov 	dx,offset start_code
	mov 	ah,31h
	; mov 	al,00h
	int 	21h
	mov 	flag,1
	jmp 	finish_end


finish:
	print result
finish_end:
	mov	ah,4ch
	int 	21h

jmp finish_end
jmp finish_end
	; mov 	ah,31h
	; mov 	al,0
	; mov 	bx,offset initialize
	; sub 	bx,offset start
	; mov 	ah,31h
	; add 	dx,(initialize-start+15)/16
	; int 	21h

; handler proc far
;     	pushf
;     	pusha
;     	push 	ds
;     	push 	es
;     	lea 	dx,success
;     	mov 	ah,9h
;     	int 	21h
;     	mov 	ah,07
;     	int 	1Ah
;     	pop 	es
;     	pop 	ds
;     	popa
;     	popf
 
    ; push ax
    ; push cx
    ; push dx
    ; mov   al,SOUND_MODE
    ; out   43h,al

    ; mov   ax,0a97h
    ; out   42h,al
    ; shr   ax,8
    ; out   42h,al

    ; in    al,61h
    ; or    al,SPEAKER_UP
    ; out   61h,al

    ; mov	cx,0007h
    ; mov	dx,0a120h
    ; mov	ah,86h
    ; int	15h

    ; in    al,61h
    ; and   al,SPEAKER_SLEEP
    ; out   61h,al
    ; pop  dx
    ; pop  cx
    ; pop  ax
;     	iret 
; handler endp   

	request_for_input 	db "Input time of alarm clock (HH:MM:SS): ",'$'
	enter_string 		db 0dh,0ah,'$'
	time 				db 11 DUP('$')
	success 			db "ALARM CLOCK WORKS",'$'
	old_handler 		dd ?
	flag 				db 0
	result 			db "I don't know what happenes",'$'
	; new_handler dd ?
	;initialize	db ?
	  ; SOUND_MODE        EQU   10110110b
    ; SPEAKER_SLEEP     EQU   11111100b
    ; SPEAKER_UP        EQU   00000011b
      ;s1 db ?
	MAIN ends
end start