.MODEL small
.STACK 100h
.DATA
      frequency dw 0be3h, 0be3h, 0be3h, 0e2ah, 0d5ah, 0d5ah, 0d5ah, 0fe8h, 0fe8h
      time      dw 0006h, 1a80h, 0006h, 1a80h, 0006h, 1a80h, 000fh, 4240h, 0006h
                dw 1a80h, 0006h, 1a80h, 0006h, 1a80h, 000ch, 3500h, 000fh, 4240h 
      
.CODE
main:
      mov   ax,@data
      mov   ds,ax

      xor   si,si
      xor   di,di
      mov   al,10110110b 
      out   43h,al
     
      mov   dx,8
      mov   ah,6bh
      out   43h,al
loop_beep:
      push  dx
      mov   bx,frequency[si]

      mov   al,bl
      out   42h,al
      mov   al,bh
      out   42h,al
    
      call  speaker_on
      
      mov	bx,si
      mov	ax,time[si+bx]
      mov	cx,ax
      mov	ax,time[si+bx][2]
      mov	dx,ax
      mov	ah,86h
      int	15h
      
      call  speaker_off

      
      add	si,2
      pop   dx
      dec   dx
      cmp   dx,0
      ja   loop_beep

      ;call speaker_off
      mov   ah,4ch
      int   21h

speaker_on proc
      push  ax
      in    al,61h
      or    al,00000011b
      out   61h,al
      pop   ax
      ret
speaker_on endp

speaker_off proc
      push  ax
      in    al,61h
      and   al,11111100b
      out   61h,al
      pop   ax
      ret
speaker_off endp

end main