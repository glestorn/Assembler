exchange macro string_offset
 	pusha
 	mov	ax,matrix[string_offset]
 	mov	bx,matrix[string_offset][2]
 	mov	matrix[string_offset],bx
 	mov	matrix[string_offset][2],ax
 	popa
exchange endm




array_size_def proc
start_matrix:
	print array_size
      lea	dx,input_string
      mov	ah,0Ah
      int	21h

	mov	ax,0
	mov	bh,0
	mov	bl,input_string[1]
	cmp	bl,0
	je	once_again_matrix
	cmp 	bl,2
	je	array_double_def
	ja	once_again_matrix


	mov	bl,input_string[2]
	cmp 	bl,'1'
	jb	once_again_matrix
	sub	bl,'0'
	mov	ax,bx
	ret
	    	
array_double_def:
	mov	al,input_string[2]
	cmp	al,'1'
	jb	once_again_matrix
	cmp 	al,'9'
	ja	once_again_matrix
	sub	al,'0'
	mov	bl,10
	mul	bl
	mov	bl,input_string[3]
	cmp	bl,'0'
	jb	once_again_matrix
	cmp 	bl,'9'
	ja 	once_again_matrix
	sub	bl,'0'
	add	ax,bx
	cmp	ax,30
	ja	once_again_matrix
	ret

once_again_matrix:
	print wrong_enter
	jmp	start_matrix
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