org 0000h
ajmp inicio

;-----Rotina de interrupção INT0 Botão + relé ------
org	0003h	;endereço da interrupção do INT0

jb P0.1, desliga_lampada
jnb P0.0, desliga_lampada
jb P0.0, liga_lampada

ajmp retorna_da_interrupcao		;retorna da interrupcao


;-----Rotina de Interrupção INT1 ------
org	0013h	;endereço da interrupção do INT1
ajmp desliga_lampada 	;salta para desliga_lampada
ajmp retorna_da_interrupcao		;retorna da interrupção

;------Final das Rotinas de interrupção  ------

;------ Configurações iniciais ------
inicio:
	mov ie, #10000101b		;habilita interrupção INT0 e INT1
	mov ip, #00000100b		;INT0 com baixa prioridade e INT1 com alta prioridade
	mov tcon, #00000101b		;INT0 e INT1 como sensivel a borda
	clr P0.5 ; seta P0.5 em baixo nível
	clr P0.6 ; seta P0.6 em baixo nível
	clr P0.7 ; seta P0.7 em baixo nível
	ajmp  loop	;jmp para loop
   
loop:
	 jb P0.2, 0013h
	 jb P0.3, 0013h
	 jb P0.4, 0013h
	 jb P0.0, 0003h
	 ajmp loop
	 
liga_lampada:
	 setb P1.0 ; seta P1.0 em alto nível
	 ajmp retorna_da_interrupcao		;retorna da interrupção

desliga_lampada:
	 clr P1.0 ; seta P1.0 em baixo nível
	 ajmp retorna_da_interrupcao		;retorna da interrupção

retorna_da_interrupcao:
	 reti ; retorna da interrupção

end
