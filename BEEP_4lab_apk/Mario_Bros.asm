.MODEL small
.STACK 100h
.DATA
      frequency         dw      659,   659,     0,   659,     0,   523,   659,     0,   784,     0,   392,     0
      time              dw    0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h, 0002h, 49f0h 
                        dw    0002h, 49f0h, 0002h, 49f0h, 0004h, 93e0h, 0004h, 93e0h, 0004h, 93e0h, 0004h, 93e0h
      generator_freq    dw    0012h, 34dch
      port_state        db    " ",0dh,0ah,'$'
      print_1           db    '1','$'
      print_0           db    '0','$'
      enter_string      db    0dh,0ah,'$'

      SIZE_ARRAY        EQU   12
      SOUND_MODE        EQU   10110110b
      SPEAKER_SLEEP     EQU   11111100b
      SPEAKER_UP        EQU   00000011b
      PORT_1            EQU   11000010b
      PORT_2            EQU   11000100b
      PORT_3            EQU   11001000b
     
.CODE
main:
      mov   ax,@data
      mov   ds,ax

      xor   si,si
      xor   di,di
      mov   al,SOUND_MODE
      out   43h,al
     
      mov   dx,SIZE_ARRAY

loop_beep:
      push  dx
      mov   bx,frequency[si]
      cmp   bx,0
      je    miss_constr

      mov   dx,generator_freq[0]
      mov   ax,generator_freq[2]
      div   bx

      out   42h,al
      shr   ax,8
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
      mov   bx,si
      mov   ax,time[si+bx]
      mov   cx,ax
      mov   ax,time[si+bx][2]
      mov   dx,ax
      mov   ah,86h
      int   15h 

continue:    
      add	si,2
      pop   dx
      dec   dx
      cmp   dx,0
      ja   loop_beep


      xor   di,di
      mov   al,PORT_1
      out   43h,al
      in    al,40h
      mov   port_state,al     
      call  bin_out
      inc   di

      mov   al,PORT_2
      out   43h,al
      in    al,41h
      mov   port_state,al
      call  bin_out
      inc   di

      mov   al,PORT_3
      out   43h,al
      in    al,41h
      mov   port_state,al
      call  bin_out

      mov   ah,4ch
      int   21h


speaker_on proc
      push  ax
      in    al,61h
      or    al,SPEAKER_UP
      out   61h,al
      pop   ax
      ret
speaker_on endp

speaker_off proc
      push  ax
      in    al,61h
      and   al,SPEAKER_SLEEP
      out   61h,al
      pop   ax
      ret
speaker_off endp

bin_out     proc
      mov   al,port_state[0]
      mov   cx,8

bin_div:
      mov   bl,al
      and   bl,10000000b
      push  ax
      cmp   bl,0
      je    zero_print

      lea   dx,print_1
      jmp   cont_div

zero_print:
      lea   dx,print_0

cont_div:
      mov   ah,9h
      int   21h

      pop   ax
      shl   al,1
      loop bin_div

      lea   dx,enter_string
      mov   ah,9h
      int   21h
      ret
endp

end main