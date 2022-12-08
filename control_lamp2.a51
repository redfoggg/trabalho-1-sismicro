org 0000h
ajmp inicio

;-----Rotina de interrupção INT0 Botão + relé ------
    org     0003h                     ;endereço da interrupção do INT0
    jb      P0.1,latchLamp
    jnb     P0.0,latchLamp
    ajmp    retorna_da_interrupcao    ;retorna da interrupcao


;-----Rotina de Interrupção INT1 ------
    org     0013h                   ;endereço da interrupção do INT1
    acall   desliga_lampada
    ajmp    retorna_da_interrupcao  ;retorna da interrupção

;-----Rotina de Interrupção SERIAL ------
    org     0023h                   ;endereço da interrupção do SERIAL
    acall   recebeDados             ;recebe os dados
    anl     A, #01H                ;limpa os 7 bits menos significativos
    jnz     desliga_tudo            ;se não for zero em ACC desliga tudo
    ajmp    retorna_da_interrupcao  ;retorna da interrupção

;------Final das Rotinas de interrupção  ------

;------ Configurações iniciais ------
inicio:
    setb    IP.4
    clr     TCON.0
    clr     TCON.2
    mov     ie, #10010101b    ;habilita interrupção INT0, INT1, serial e global
    mov     ip, #00000100b    ;INT0 com baixa prioridade e INT1 com alta prioridade
    mov     tcon, #00000101b  ;INT0 e INT1 como sensivel a borda
    clr     P0.5              ; seta P0.5 em baixo nível
    clr     P0.6              ; seta P0.6 em baixo nível
    clr     P0.7              ; seta P0.7 em baixo nível
    ; Configura a porta serial
    mov     TMOD,#20H         ;Timer 1, mode 2
    mov     TH1,#0FDH         ;baud rate: 9600
    mov     SCON,#50H         ;8-bit, 1 stop bit, 1 start bit (MODO1)
    setb    TR1               ;Start timer
  ; ajmp  loop  ;jmp para loop

main:
    ; delay de 5 segundos
    ; acall   delay
    ; acall   delay
    acall   delay
    acall   delay
    acall   delay
    acall   moveDados   ; move os dos pinos para o ACC
    acall   enviaDados  ; envia os dados em ACC via serial
    ajmp    main

moveDados:
    mov    A, P0
    ; mask bit 5, 6 and 7
    anl    A, #00011111b ; remove os 3 bits mais significativos
    ; A = 000XXXXX
    mov    R7, A
    mov    A, P1
    ; mask bit 0
    anl    A, #00000001b ; mantém apenas o bit menos significativo
    ; mov    A =  #00000001b 
    ; shift A by 5 bits A = 00100000b
    clr     C
    rlc     A
    rlc     A
    rlc     A
    rlc     A
    rlc     A
    ;¨or¨ para juntar os 2 bytes
    orl     A, R7
    orl     A, #01000000b
    ; A = 00XXXXXX
    ; 00XXXXXX = controlador 0
    ; 01XXXXXX = controlador 1
    ; 10XXXXXX = controlador 2
    ; 11XXXXXX = controlador 3
    ret

desliga_tudo:
    ajmp    desliga_lampada  ;desliga a lampada
    jmp     $                ;loop infinito

liga_lampada:
    setb    P1.0                    ; seta P1.0 em alto nível
    ajmp    retorna_da_interrupcao

latchLamp:
    mov     R1, A       ; salva o valor de A
    mov     A, P1       ; move o valor de P1 para A
    cpl     A           ; inverte os bits
    anl     A, #01h     ; mantem apenas o bit menos significativo
    mov     P1, A       ; escreve os bits invertidos no pino P0 de volta
    mov     A, R1       ; recupera o valor de A
    ajmp    retorna_da_interrupcao

desliga_lampada:
    clr     P1.0  ; seta P1.0 em baixo nível
    ret           ;retorna para quem chamou

retorna_da_interrupcao:
    reti          ; retorna da interrupção

; delay de 1 segundo
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
    mov     A,SBUF          ;armazena os dados recebidos no acc
    clr     RI              ;limpa o RI
    setb    IE.4            ;habilita a interrupção serial
    ret                     ;retorna para quem chamou a rotina

end
