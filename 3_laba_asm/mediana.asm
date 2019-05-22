.286
.MODEL small
.STACK 100h
.DATA
	ARRAY_SIZED 	dw		  ?
	MAX_VALUE		db	 	  "3276",?
                                       
	input_string 	db 		  7,0,8 DUP('$')
	matrix  		dw 		  30 DUP(?)
	print_value		db	0dh,0ah,?,?,'$'
	init_string 	db 	  	  "Input all your numbers in matrix:",0dh,0ah,'$'
	result		db 	0dh,0ah,"Medians of matrix are:",		  0dh,0ah,'$'
	err_string		db 	0dh,0ah,"There is wrong enter, try again",  0dh,0ah,'$'
	err_limit 		db 	0dh,0ah,"Your number is too big, try again",0dh,0ah,'$'
	array_size		db 		  "Enter size of array (up to 30) : ",	    '$'
	wrong_enter		db 	0dh,0ah,"Your entered wrong size of array" ,0dh,0ah,'$'
	enter_string	db 	0dh,0ah,'$' 
	symbol		db	 	  ?,'$'
	
.CODE
include check.inc
include init_exchange.inc
include prints.inc


start:
      mov	ax,@data
      mov	ds,ax
      
    
      call	array_size_def
      mov	word ptr ARRAY_SIZED,ax
                    
	print enter_string
      call	matrix_init
      mov	cx,word ptr ARRAY_SIZED
      sub	cx,1
      cmp	cx,0
      je	print_medians
bubble_sort:
	xor	si,si
	mov	dx,cx

	loop_start:
		mov	ah,byte ptr matrix[si][1]
		mov	al,byte ptr matrix[si]
		mov 	bh,byte ptr matrix[si][3]
		mov	bl,byte ptr matrix[si][2]
		cmp 	ax,bx
		jle 	do_not_exch
		exchange si
			
	do_not_exch:
		add 	si,2
		dec 	dx
		cmp 	dx,0
		ja	loop_start
	loop bubble_sort
	
print_medians:               
	print enter_string       
 	print result 
               
 	mov	ax,word ptr ARRAY_SIZED
 	and	ax,1
 	cmp	ax,0
 	jne	odd_matrix
 		
	mov	bx,word ptr ARRAY_SIZED
	call	print_result
	
	mov	bx,word ptr ARRAY_SIZED
	sub	bx,2
	call	print_result
	jmp 	finish
	
odd_matrix:
	mov	bx,word ptr ARRAY_SIZED
	sub	bx,1
	call	print_result
	
finish:
      mov	ah,4Ch
      int 	21h
          
end start