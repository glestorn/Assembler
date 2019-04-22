.MODEL small
.STACK 100h
.DATA
	Date_string	db	?,?,".",?,?,".",?,?,?,?,'$'
.CODE
main:
	mov 	ax,@data
	mov 	ds,ax

;current data
	mov 	ah,04h
	int 	1ah
	;jc 	ERROR_HND
	; mov	Age,ch
	; mov	Year,cl
	; mov	Month,dh
	; mov	Day,dl

	mov	al,dl
	call	convert_func
	mov	word ptr Date_string,ax
	
	mov	al,dh
	call	convert_func
	mov	word ptr Date_string+3,ax

	mov	al,ch
	call	convert_func
	mov	word ptr Date_string+6,ax

	mov	al,cl
	call	convert_func
	mov	word ptr Date_string+8,ax

	lea	dx,Date_string
	mov 	ah,9h
	int	21h

	mov 	ah,4ch
	int 	21h

convert_func proc
	mov	ah,0
      ror   ax,4
      shr   ah,4
      or    ax,'00'
      ret
convert_func endp

end main