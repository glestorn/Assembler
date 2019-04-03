comment @
CHANGE SUBSTRING IN STRING ON ANOTHER ONE
@

.MODEL small
.STACK 100h
.DATA 
	substring			db 101,0,102 						DUP('$')
	xchsubstr			db 101,0,102 						DUP('$')
	string 			db 201,0,202 						DUP('$')
	
	input_str_message		db 		"Input your string:",			0dh,0ah,"$"
	input_substr_message	db 0dh,0ah,	"Input your substring:", 		0dh,0ah,"$"
	input_xchstr_message 	db 0dh,0ah,	"Input your xchange substr:",		0dh,0ah,"$"
	buff_err			db 0dh,0ah,0dh,0ah,"Your substring can't be exchanged,"
					db "because it'll overflow your string",		0ah,0ah,"$"
	input_error			db 0dh,0ah,	"Error: your input is empty",		0dh,0ah,"$"
	complete_message 		db 0dh,0ah,	"Final string is:",			0dh,0ah,"$"
	
.CODE
	
macro check_for_empty str
	pusha
	mov	dl,str[1]
	cmp	dl,0
	je	empty_string
	popa
endm	check_for_empty

macro	print	offs
	pusha
	lea	dx,offs
	mov	ah,9h
	int	21h
	popa
endm	print

macro	input	offs
	pusha
	lea	dx,offs
	mov	ah,0Ah
	int	21h
	popa
endm	input

start:	
	mov	ax,@data			;set ds at start of program
	mov	ds,ax
    				
	print	input_str_message
	input	string
	check_for_empty string    
	print	input_substr_message
	input	substring
	check_for_empty string
	print	input_xchstr_message
	input	xchsubstr
	check_for_empty	xchsubstr
        
	mov	dx,1
find_underrow:
	inc	dx
	mov	di,2				;set substring and string offsets
	mov	si,dx
                      
	cmp	string[si],0dh
	je	result

loop_underrow:
	mov	al,string[si]
	mov	bl,substring[di]
	
	cmp	al,bl
	jne	find_underrow

	inc	si				;elements are equal,
	inc	di				;we move further

	cmp	substring[di],0dh		;we arrived end of substring,
	je	xchange			;there is substring in this string

	cmp	string[si],0dh		;we arrived end of string,
	je	find_underrow		;there is no substring in this string

	loop	loop_underrow

         
xchange:
	mov	al,string[1]            ;check for overflow of size of string
	sub	al,substring[1]
	add	al,xchsubstr[1]
	mov	bl,200
	cmp	al,bl
	ja	buff_error

	mov	ah,substring[1]		;set direction of shift
	cmp	ah,xchsubstr[1]
	je	paste
	ja	left_shift


right_shift:				;shift of underrow
	mov	cl,string[1]		;(previous underrow is less than new)
	mov	ch,0
	mov	di,cx
	add	cx,4
	sub	cx,si
	add	di,3

	mov	bl,xchsubstr[1]
	sub	bl,substring[1]
 	mov	bh,0

loop_right_shift:
	mov	ah,string[di]
	mov	string[bx+di],ah
	dec	di
	loop	loop_right_shift 
	
	add	string[1],bl            ;change size of string

	jmp	paste

                        
left_shift:					;shift of underrow
	mov	cl,string[1]		;(previous underrow is greater than new)
	mov	ch,0
	add	cx,4
	sub	cx,si
	mov	di,si

	mov	bl,substring[1]         
	sub	bl,xchsubstr[1]
	mov	bh,0
	neg	bx

loop_left_shift:
	mov	ah,string[di]
	mov	string[di+bx],ah
	inc	di
	loop	loop_left_shift
                                    
	neg	bx                      ;change size of string
	sub	string[1],bl


paste:					;paste of new underrow
	mov	cl,xchsubstr[1]
	mov	ch,0
	xor	di,di
	mov	si,2
	mov	bx,dx       
	
	add	dl,xchsubstr[1]         ;change search position of string
	sub	dl,1
    
loop_paste:
	mov	ah,xchsubstr[si]
	mov	string[di+bx],ah
	inc	di
	inc	si
	loop	loop_paste
	
	jmp	find_underrow
	

result:                             ;output of final string
	print	complete_message
    
	lea	dx,string+2
	mov	ah,9h
	int	21h
    
	jmp	finish

      
empty_string:
	print	input_error
	jmp	finish
          

buff_error:
	print	buff_err
	jmp	result

finish:
	mov	ah,4ch
	int	21h  
	

end start