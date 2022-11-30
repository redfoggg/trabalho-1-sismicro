org 0000h
ajmp inicio

;-----Rotina de interrupção INT0 Botão + relé ------
    org     0003h                     ;endereço da interrupção do INT0
    jb      P0.1,desliga_lampada
    jnb     P0.0,desliga_lampada
    jb      P0.0,liga_lampada
    ajmp    retorna_da_interrupcao    ;retorna da interrupcao


;-----Rotina de Interrupção INT1 ------
    org     0013h                   ;endereço da interrupção do INT1
    ajmp    desliga_lampada         ;salta para desliga_lampada
    ajmp    retorna_da_interrupcao  ;retorna da interrupção

;-----Rotina de Interrupção SERIAL ------
    org     0023h                   ;endereço da interrupção do SERIAL
    ajmp    recebe_dados            ;salta para recebe_dados
    jnz     desliga_tudo            ;se não for zero em ACC desliga tudo
    ajmp    retorna_da_interrupcao  ;retorna da interrupção

;------Final das Rotinas de interrupção  ------

;------ Configurações iniciais ------
inicio:
    mov     ie, #10010101b    ;habilita interrupção INT0, INT1, serial e global
    mov     ip, #00000100b    ;INT0 com baixa prioridade e INT1 com alta prioridade
    mov     tcon, #00000101b  ;INT0 e INT1 como sensivel a borda
    clr     P0.5              ; seta P0.5 em baixo nível
    clr     P0.6              ; seta P0.6 em baixo nível
    clr     P0.7              ; seta P0.7 em baixo nível
    ; Configura a porta serial
    mov     TMOD,#20H         ;Timer 1, mode 2
    mov     TH1,#0FDH         ;baud rate: 9600
    mov     SCON,#50H         ;8-bit, 1 stop bit, 1 start bit
    setb    TR1               ;Start timer
  ; ajmp  loop  ;jmp para loop

main:
    jb      P0.2, 0013h
    jb      P0.3, 0013h
    jb      P0.4, 0013h
    jb      P0.0, 0003h
    ; envia os dados via serial a cada 0.5 segundo
    mov     R7,a        ;Move o valor de acc para o registrador R7
    cpl     a           ;Complementa o acumulador (acc = not acc)
    mov     P2,a        ;Move o valor de acc para o Port P2
    ; delay de 5 segundos
    acall   delay
    acall   delay
    acall   delay
    acall   delay
    acall   delay
    mov     a, P0       ;Move o valor de P0 para o acumulador
    acall   envia_dados ;envia os dados via serial
    ajmp    main

desliga_tudo:
    ajmp    desliga_lampada  ;desliga a lampada
    jmp     $                ;loop infinito

liga_lampada:
    setb    P1.0                    ; seta P1.0 em alto nível
    ajmp    retorna_da_interrupcao  ;retorna da interrupção

desliga_lampada:
    clr     P1.0  ; seta P1.0 em baixo nível
    ret           ;retorna para quem chamou

retorna_da_interrupcao:
    reti          ; retorna da interrupção

delay:
    mov     R0,#255D
D1:
    mov     R4,#92D
timer:
    mov     TH0,#0FFH;
    mov     TL0,#000H;
    setb    TR0
again:
    jnb     TF0, again
    clr     TR0
    clr     TF0
    djnz    R4,timer
    djnz    R0,D1
    ret


enviaDados:
    clr     IE.4      ; desabilita interrupção serial
    mov     SBUF,A    ;armazena no buffer os dados do ACC
laco:
    jnb     TI,laco   ;espera pelo ultimo dado ser enviado
    clr     TI        ;limpa o TI
    setb    IE.4      ;habilita interrupção serial
    ret               ;retorna para quem chamou a rotina

recebeDados:
    clr     IE.4            ;desabilita a interrupção serial
    jnb     RI,recebeDados  ;espera receber dados
    mov     A,SBUF          ;armazena os dados recebidos no reg A
    clr     RI              ;limpa o RI
    setb    IE.4            ;habilita a interrupção serial
    ret                     ;retorna para quem chamou a rotina


end
