exchange macro string_offset
 	pusha
 	mov	ax,matrix[string_offset]
 	mov	bx,matrix[string_offset][2]
 	mov	matrix[string_offset],bx
 	mov	matrix[string_offset][2],ax
 	popa
exchange endm




array_size_def proc
	mov	ax,0
	mov	bh,0
	mov	bl,input_string[3]
	cmp 	bl,'0'
	jb	array_single_def
	
	mov	al,input_string[3]
	sub	al,'0'
	mov	bl,10
	mul	bl
	mov	bl,input_string[2]
	sub	bl,'0'
	add	ax,bx
	ret
    	
array_single_def:
	mov	bl,input_string[2]
	sub	bl,'0'
	mov	ax,bx
	ret
array_size_def endp




matrix_init proc
	print init_string
	push 	word ptr ARRAY_SIZED
	push 	0

loop_init:
once_again:					
	mov 	ah,0ah
	lea	dx,input_string
	int 	21h

	check_for_err  input_string
	oct_to_dec	   input_string
	print enter_string
	
	pop 	di
	mov	matrix[di],dx
	pop 	cx
	dec 	cx
	push 	cx
	inc 	cx			
	add 	di,2
	push 	di
	sub  	di,2
	loop 	loop_init
	
	pop 	di
	pop	cx
	ret
matrix_init endp