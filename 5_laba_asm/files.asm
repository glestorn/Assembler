;.286
.MODEL	small
.STACK 	100h
.DATA
	fileIn	db	"fileIn.txt",0
	IDfileIn	dw	?
	fileOut	db	"fileOut.txt",0
	IDfileOut	dw	?
	input_mess 	db 	"Enter word to find : ",'$'
	symbol	db 	?
	searchWord	db	21,0,22 DUP('$')
	err_message db 	0dh,0ah,"You input isn't word, try again",0dh,0ah,'$'
.CODE
input 	macro offs
	pusha
	lea	dx,offs
	mov	ah,0Ah
	int 	21h
	popa
input 	endm 

output	macro offs
	pusha
	lea	dx,offs
	mov	ah,9h
	int 	21h
	popa
output	endm

check_word 	macro offs
	mov	si,2
	mov	cx,0
	mov	cl,offs[1]
	cmp	cx,0
	je 	error_input

loop_check:
	mov	al,offs[si]
	cmp	al,' '
	je 	error_input
	cmp	al,0Ah
	je	error_input
	cmp	al,0Dh
	je 	error_input
	cmp	al,09h
	je 	error_input
	cmp	al,2Ch
	je 	error_input
	cmp	al,21h
	je 	error_input
	cmp	al,2Eh
	je 	error_input
	cmp	al,3Fh
	je 	error_input
	inc 	si
	loop 	loop_check
	jmp	end_check

error_input:
	output err_message
	jmp	word_input

end_check:
check_word 	endm

fileOpen	macro	file,ID
	lea	dx,file
	mov	ah,3Dh
	mov	al,00h
	int	21h
	mov	ID,ax
fileOpen	endm 

fileWriteOpen macro file,ID
	lea	dx,file
	mov	ah,3Dh
	mov	al,01h
	int	21h
	mov	ID,ax
fileWriteOpen endm

fileClose	macro	ID
	mov	ah,3Eh
	mov	bx,ID
	int	21h
fileClose	endm

read 	proc
	push 	cx
	mov	bx,IDfileIn
	lea 	dx,symbol
	mov	cx,1
	mov	ah,3Fh
	int	21h
	pop 	cx
	ret
read 	endp

write proc
	push 	cx
	mov 	ah,40h
	mov 	bx,IDfileOut
	mov 	cx,1
	lea 	dx,symbol
	int 	21h
	pop 	cx
	ret
write endp

two_pos_back proc
	mov 	ah,42h
	mov 	bx,IDfileIn
	mov 	al,1
	mov 	cx,0FFFFh
	mov 	dx,0FFFEh
	int 	21h
	ret
two_pos_back endp

one_pos_back proc
	mov 	ah,42h
	mov 	bx,IDfileIn
	mov 	al,1
	mov 	cx,0FFFFh
	mov 	dx,0FFFFh
	int 	21h 
	ret
one_pos_back endp

skip_newl 	proc
	mov	ah,42h
	mov	bx,IDfileIn
	mov	al,1
	mov	cx,0
	mov	dx,1
      int	21h
      ret
skip_newl	endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
       
start:
	mov	ax,@DATA
	mov	ds,ax

word_input:
	output	input_mess
	input		searchWord
	check_word  searchWord

;TEST END OF FILE (IN ANOTHER PROGRAM)
;TEST START OF FILE (IN ANOTHER PROGRAM)
;check if when read in end of file it move further

	fileOpen	fileIn,IDfileIn
	fileWriteOpen	fileOut,IDfileOut

	mov 	si,2
check_for_word:
	call 	read
	cmp	searchWord[si],0Dh
	jne 	no_find_word
	cmp	symbol,00h
	je 	finish
	mov 	si,2
	cmp	symbol,' '
	je 	miss_row
	cmp	symbol,09h
	je 	miss_row
	cmp 	symbol,0Dh
	jne 	miss_word
	call	skip_newl
	jmp	check_for_word

no_find_word:
	cmp	symbol,00h
	je 	return_to_row_start
	cmp	symbol,' '
	je 	enter_place
	cmp	symbol,09h
	je 	enter_place
	cmp 	symbol,0Dh
	je 	return_to_row_start
      
      mov	ah,searchWord[si]
	cmp	symbol,ah
	jne	miss_word

	inc 	si
	jmp 	check_for_word

miss_word:
	call 	read
	cmp	symbol,' '
	je 	enter_place
	cmp	symbol,09h
	je	enter_place
	cmp 	symbol,0Dh
	je 	return_to_row_start
	cmp 	symbol,00h
	je 	return_to_row_start
	jmp 	miss_word

enter_place:
	call	read
	cmp 	symbol,00h
	je 	return_to_row_start
	cmp	symbol,' '
	je	enter_place
	cmp	symbol,09h
	je	enter_place
	cmp 	symbol,0Dh
	je 	return_to_row_start
	
	mov	si,2
	call 	one_pos_back
	jmp	check_for_word

miss_row:
	call	read
	cmp 	symbol,00h
	je 	finish
	cmp 	symbol,0Dh
	jne 	miss_row
	call	skip_newl
	jmp 	check_for_word
	
return_to_row_start:
	call	two_pos_back
	jc	print_from_start_of_file
	call 	read
	cmp	symbol,0Ah
	je 	print_row
	jmp 	return_to_row_start
	
print_from_start_of_file:
	call	one_pos_back
	jmp	print_row

print_row:
	call 	read
	cmp	symbol,00h
	je 	finish
	call 	write
	cmp 	symbol,0Ah
	je 	check_for_word
	jmp	print_row

finish:
	fileClose	IDfileIn
	fileClose	IDfileOut

	mov	ax,4C00h
	int	21h
end start