check_for_err macro string
	mov	ch,0
	mov 	cl,string[1]

	mov	ah,string[2]
	cmp 	ah,'-'
	je 	neg_numb

	mov	si,2
	push 	cx
	push 	si
	mov	al,'7'
	mov 	MAX_VALUE[4],al
	jmp 	empty_check 
							
neg_numb:
	sub	cl,1
	mov	si,3
	push 	cx
	push 	si
	mov 	al,'8'
	mov 	MAX_VALUE[4],al

empty_check:
	cmp 	cx,0
	je 	error_input
	
	mov	al,string[si+1]
	cmp 	al,'0'
	jb	check
	
	mov	al,string[si]
	cmp 	al,'0'
	je	error_input

check:
	mov	ah,string[si]
	cmp 	ah,'0'
	jb	error_input
	cmp 	ah,'9'
	ja 	error_input

	inc 	si
	loop 	check

	pop 	si
	pop 	cx
	cmp 	cx,5
	jb	return
	ja 	error_limit
	
	xor 	di,di
check_for_limit:
	mov	ah,string[si]
	cmp 	ah,MAX_VALUE[di]
	ja	error_limit
	jb	return
	
	inc	si
	inc 	di
	loop 	check_for_limit

	jmp	return

error_input:
	pop 	cx
	pop 	si		
	print err_string
	jmp	once_again

error_limit:
	print err_limit
	jmp 	once_again

return:
check_for_err endm




oct_to_dec macro number
	push	0
	mov	si,2
	mov	cl,input_string[1]
	mov	ch,0
	mov	bh,input_string[si]
	
	cmp 	bh,'-'
	jne 	loop_convert

	inc 	si
	dec 	cx

loop_convert:
	mov	al,input_string[si]
	sub 	al,'0'
	mov 	ah,0
	mov	bx,cx
	dec 	bx

mul_10:
	cmp 	bx,0
	jbe 	num_counted

	mov	dx,10
	mul 	dx
	dec 	bx
	jmp 	mul_10

num_counted:
	pop 	dx
	add 	dx,ax
	push 	dx
	inc	si
	loop 	loop_convert
	
	pop 	dx
	mov	bh,input_string[2]
	cmp 	bh,'-'
	jne	return_back
	neg 	dx

return_back:
endm oct_to_dec