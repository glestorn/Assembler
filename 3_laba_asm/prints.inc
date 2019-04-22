print macro string_offset
	pusha
	lea	dx,string_offset
	mov	ah,9h
	int 	21h
	popa
print endm
 



recurs_print_number proc
	mov	dx,0
	mov	cx,10
	div	cx
	cmp   ax,0
	jne 	not_ret
	
	print_symbol dl
	ret
not_ret:     
	push	dx
	call	recurs_print_number
	pop	dx
	print_symbol dl 
	ret
recurs_print_number endp           
    



print_result proc   
	mov 	ah,byte ptr matrix[bx+1]
	mov	al,byte ptr matrix[bx]
	cmp 	ax,0
	jge	cont
	
	call	print_minus
	neg 	ax
cont:         
	call recurs_print_number
	
	print enter_string
	ret
print_result endp




print_symbol macro ascii
	pusha
	mov	dl,ascii
	add	dl,'0'
	mov	symbol[0],dl
	print symbol
	popa
endm print_symbol




print_minus proc
	pusha
	mov	dl,'-'
	mov	symbol[0],dl
	print symbol 
	popa
	ret
print_minus endp