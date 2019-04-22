.MODEL small
.STACK 100h
.DATA
    time     db ?,?,":",?,?,":",?,?,0dh,0ah,'$'
    buf_time db ?,?,?,?
.CODE
main:
      mov   ax,@data
      mov   ds,ax

      call  set_native_time
      call  get_time

      mov   bx,0
      call  set_time
      call  get_time
      
      mov   bx,1
      call  set_time
      call  get_time

      mov   ah,4ch
      int   21h

get_time proc
      mov   ah,02h
      int   1Ah

      mov   al,ch
      call  convert_func
      mov   word ptr time,ax

      mov   al,cl
      call  convert_func
      mov   word ptr time+3,ax

      mov   al,dh
      call  convert_func
      mov   word ptr time+6,ax

      mov   ah,9h
      mov   dx,offset time
      int   21h 
      ret    
get_time endp

set_time proc
      cmp   bx,1
      je    native_time

      mov   ah,03h
      mov   ch,05h
      mov   cl,05h
      mov   dh,05h
      mov   dl,01h
      int   1Ah
      ret

native_time:
      mov   ah,03h
      mov   ch,buf_time[0]
      mov   cl,buf_time[1]
      mov   dh,buf_time[2]
      mov   dl,buf_time[3]
      int   1Ah
      ret
set_time endp

set_native_time proc
      mov   ah,02h
      int   1Ah
      mov   buf_time[0],ch
      mov   buf_time[1],cl
      mov   buf_time[2],dh
      mov   buf_time[3],dl
      ret
set_native_time endp

convert_func proc
      mov   ah,0
      ror   ax,4
      shr   ah,4
      or    ax,'00'
      ret
convert_func endp
end main