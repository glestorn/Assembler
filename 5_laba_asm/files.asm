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
	lea	dx,offs
	mov	ah,0Ah
	int 	21h
input 	endm 

output	macro offs
	lea	dx,offs
	mov	ah,9h
	int 	21h
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
	cmp	al,'\r'		;??????????????
	je 	error_input
	cmp	al,'\t'		;??????????????
	je 	error_input
	cmp	al,','
	je 	error_input
	cmp	al,'!'
	je 	error_input
	cmp	al,'.'
	je 	error_input
	cmp	al,'?'
	je 	error_input
	inc 	si
	loop 	loop_check
	jmp	end_check

error_input:
	output err_message
	jmp	word_input

end_check:
check_word 	endm

start:
	mov	ax,@DATA
	mov	ds,ax

	; call getComArgs
	; ;{
	; 		push ax
	; 	   	push cx
		    
	; 	    	mov cx, 0
	; 		mov cl, es:[80h]	;80h - cmd length	
	; 		mov cmdLen, cx
	; 		cmp cx, 1
	; 		jle endGCA 		           
		    
	; 		cld
	; 		mov di, 81h         ;81h - cmd itself
	; 		mov al, ' '
	; 		rep scasb   ;repeat send byte while not end
	; 		dec di
			
	; 		lea si, cmdLine
	; 	skip:
	; 		mov al,es:[di]
	; 		cmp al, 0dh ;/r?
	; 		je endSkip
	; 		cmp al, 20h ;space?
	; 		je endSkip 
	; 		cmp al, 9h  ;tab?
	; 		je endSkip
	; 		mov ds:[si], al 
	; 		inc di
	; 		inc si
	; 		jmp skip  
		       	
	; 	endSkip:
	; 		inc si
	; 		mov ds:[si], word ptr '$'   
		             
	; 	endGCA:
	; 		pop cx
	; 		pop ax    
 ;    ;}    
    
 ;    	mov ax, cmdLen  
 ;    	cmp cmdLen, 1
 ;   	jle noData
    
 ;    	;display cmdLine
    
 ;    	display procStartStr
 ;    	lea dx, cmdLine
word_input:
	output	input_mess
	input		searchWord
	check_word  searchWord

	fileOpen	fileIn,IDfileIn
	fileOpen	fileOut,IDfileOut

	mov 	si,2
check_for_word:
	call 	read
	cmp	searchWord[si],0Dh
	jne 	no_find_word
	cmp 	ax,0
	je 	finish
	mov 	si,2
	cmp	symbol,' '
	je 	miss_row
	cmp 	symbol,0Dh
	je 	check_for_word
	jmp	miss_word

no_find_word:
	cmp	ax,0
	je 	print_row
	cmp	symbol,' '
	je 	enter_place
	cmp 	symbol,0Dh
	je 	print_row
      
      mov	ah,searchWord[si]
	cmp	symbol,ah
	jne	miss_word

	inc 	si
	jmp 	check_for_word

miss_word:
	call 	read
	cmp	symbol,' '
	je 	enter_place
	cmp 	symbol,0Dh
	je 	print_row
	cmp 	ax,0
	je 	print_row
	jmp 	miss_word

enter_place:
	call	read
	cmp 	ax,0
	je 	print_row
	cmp	symbol,' '
	je	enter_place
	cmp 	symbol,0Dh
	je 	print_row
	
	mov	si,2
	call 	one_pos_back
	jmp	check_for_word

miss_row:
	call	read
	cmp 	symbol,0Dh
	je 	check_for_word
	cmp 	ax,0
	je 	finish
	jmp	miss_row	

print_row:
	call	two_pos_back
	call 	read
	jc	print_row_from_start
	cmp	symbol,0Dh
	je 	print_row_from_start
	jmp 	print_row

print_row_from_start:
	call 	read
	cmp	ax,0
	je 	finish
	call 	write
	cmp 	symbol,0Dh
	je 	check_for_word

finish:
	fileClose	IDfileIn
	fileClose	IDfileOut

	mov	ah,4Ch
	int	21h
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;
fileOpen	macro	file,ID
	lea	dx,file
	mov	ah,3Dh
	mov	al,00h 	;SET RIGHTS CORRECTLY
	int	21h
	mov	ID,ax
fileOpen	endm

fileClose	macro	ID
	mov	ah,3Eh
	mov	bx,ID
	int	21h
fileClose	endm

read 	proc
	mov	bx,IDfileIn
	lea 	dx,symbol
	mov	cx,1
	mov	ah,3Fh
	int	21h
	ret
read 	endp

write proc
	mov 	ah,40h
	mov 	bx,IDfileOut
	mov 	cx,1
	lea 	dx,symbol
	int 	21h
	ret
write endp

two_pos_back proc
	mov 	ah,42h
	mov 	bx,IDfileIn
	mov 	al,1
	mov 	cx,FFFFh
	mov 	dx,FFFEh
	int 	21h
	ret
two_pos_back endp

one_pos_back proc
	mov 	ah,42h
	mov 	bx,IDfileIn
	mov 	al,1
	mov 	cx,FFFFh
	mov 	dx,FFFFh
	int 	21h
one_pos_back endp

end start

;TEST END OF FILE (IN ANOTHER PROGRAM)
;TEST START OF FILE (IN ANOTHER PROGRAM)
;check if when read in end of file it move further