.MODEL	small
.STACK 	100h
.DATA
	cmdLen 		dw 	?
	IDfileIn		dw	?
	IDfileOut		dw	?
	symbol		db 	?
	searchWord		db	126 		DUP('$')
	fileIn		db	126 		DUP(0)
	fileOut		db			"fileOut.txt",0

	err_message		db 	0dh,0ah,	"Your input isn't word",'$'
	empty_request	db 	0dh,0ah,	"There is nothing in cmd",'$'
	empty_cmd		db	0dh,0ah,	"There is no word in cmd",'$'
	wrg_params		db	0dh,0ah,	"You enter is wrong (too much params "
				db		  	"or there are spaces/tabs in the end)",'$'
	wrongFileName	db	0dh,0ah,	"You entered wrong file name",'$'
	wrongPath		db 	0dh,0ah,	"You entered wrong path of file",'$'
	tooManyFiles 	db 	0dh,0ah,	"There are opened too many files",'$'
	noAccess 		db 	0dh,0ah,	"Access to this file is denied",'$'
	wrongAcess 		db 	0dh,0ah,	"There is using wrong access mode",'$'
	OKopening		db 	0dh,0ah,	"File was opened successfully",'$'

	endFlag	db	0

	
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
	xor 	si,si

loop_check:
	mov	al,offs[si]
	cmp	al,'0'
	jb	not_number
	cmp	al,'9'
	jbe	error_input
not_number:
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
	cmp	al,'$'
	je 	end_check
	inc 	si
	loop 	loop_check
	jmp	end_check

error_input:
	output err_message
	jmp	finish

end_check:
check_word 	endm

fileReadOpen	macro	file,ID
	lea	dx,file
	mov	ah,3Dh
	mov	al,00h
	int	21h
	jc	errorHandling
	mov	ID,ax
	output OKopening
	jmp	open_write_file

errorHandling:
	cmp 	al,02h
	jne 	pathNotFound
	output wrongFileName
	jmp	finish

pathNotFound:
	cmp 	al,03h
	jne 	tooManyFilesOpened
	output wrongPath
	jmp 	finish

tooManyFilesOpened:
	cmp 	al,04h
	jne 	accessDenied
	output tooManyFiles
	jmp 	finish

accessDenied:
	cmp 	al,05h
	jne 	wrongAccessMode
	output noAccess
	jmp 	finish

wrongAccessMode:
	output wrongAcess
	jmp 	finish
fileReadOpen	endm 

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

	call	readCmdArgs
	cmp 	endFlag,0
	jne 	finish

	check_word  searchWord

	fileReadOpen	fileIn,IDfileIn
open_write_file:
	fileWriteOpen	fileOut,IDfileOut

	xor 	si,si
check_for_word:
	call 	read
	cmp	searchWord[si],'$'
	jne 	no_find_word
	cmp	symbol,00h
	je 	finish
	xor 	si,si
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
	
	xor 	si,si
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

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

readCmdArgs	proc
	push 	ax
    	push 	cx
    
    	mov 	cx,0
	mov 	cl,es:[80h]
	cmp 	cx,1
	jle 	emptyRequest		           
    
	cld
	mov 	di,81h 
	mov 	al,' '
	rep 	scasb   
	dec 	di
	
	lea 	si,fileIn
skip:
	mov 	al,es:[di]
	cmp 	al,0Dh
	je 	noWordInCmd
	cmp 	al,' '
	je 	skip_spaces_tabs
	cmp 	al,09h
	je 	skip_spaces_tabs
	mov 	ds:[si],al
	inc 	di
	inc 	si
	jmp 	skip
       
skip_spaces_tabs:
	inc 	di
	mov	al,es:[di]
	cmp	al,' '
	je 	skip_spaces_tabs		
	cmp	al,09h
	je 	skip_spaces_tabs
	cmp	al,0Dh
	je 	noWordInCmd

	lea	si,searchWord
defineWordOfSearch:
	mov	al,es:[di]
	cmp	al,0Dh
	je 	endCmd
	cmp	al,' '
	je 	errorCmdInput
	cmp 	al,09h
	je 	errorCmdInput
	mov	ds:[si],al
	inc 	di
	inc 	si
	jmp	defineWordOfSearch

endCmd:
	pop 	cx
	pop 	ax    
	ret

emptyRequest:
	output empty_request
	pop 	cx
	pop 	ax
	mov 	endFlag,1
	ret

noWordInCmd:
	output empty_cmd
	pop 	cx
	pop 	ax
	mov	endFlag,1
	ret
	
errorCmdInput:
	output wrg_params
	pop 	cx
	pop 	ax
	mov 	endFlag,1
	ret

readCmdArgs endp

end start