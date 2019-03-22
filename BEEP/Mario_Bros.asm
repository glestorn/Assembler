.MODEL small
.STACK 100h
.DATA
      frequency dw 0389h, 0389h, 0000h, 0389h, 0000h, 0416h, 0389h, 0000h, 02f8h, 0000h, 05f1h, 0000h
      time      dw 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0004h, 93e0h, 0004h, 93e0h, 0004h, 93e0h, 0004h, 93e0h
      
.CODE
main:
      mov   ax,@data
      mov   ds,ax

      xor   si,si
      xor   di,di
      mov   al,10110110b 
      out   43h,al
     
      mov   dx,12
      mov   ah,6bh
      out   43h,al
loop_beep:
      push  dx
      mov   bx,frequency[si]
      cmp   bx,0
      je    miss_constr

      
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
      jmp   continue

 miss_constr: 
      ;call  speaker_on    
      mov   bx,si
      mov   ax,time[si+bx]
      mov   cx,ax
      mov   ax,time[si+bx][2]
      mov   dx,ax
      mov   ah,86h
      int   15h 
      ;call  speaker_off

continue:    
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