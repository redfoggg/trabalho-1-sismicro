; ======================================
;	Relógio digital em assembly
; ======================================
;	Dupla:
;		Erick Suzart Souza
;		Valdiney
; ======================================

; Pin declaration:

DISPLAY_1			equ		P2.0
DISPLAY_2			equ		P2.1
DISPLAY_3			equ		P2.2
DISPLAY_4			equ		P2.3
DISPLAY_0			equ		P2.4
DISPLAY_5			equ		P2.5
DISPLAY_6			equ		P2.6
DISPLAY_7			equ		P2.7
BOTAO_DATA  	equ		P3.0	; Mostra data nos displays
BOTAO_DIA			equ		P3.1	; Mostra dia da semana: DOM, SEG, TER, QUA, QUI, SEX, SAB.
AJUSTE_SEG  	equ		P3.2	; Zera SegundOo
AJUSTE_MIN  		equ		P3.3	; Ajuste Minuto
AJUSTE_HORA   	equ		P3.4	; Ajuste Hora
AJUSTE_DIA  		equ		P3.5	; Ajuste Dia
AJUSTE_MES  	equ		P3.6	; Ajuste Mês
AJUSTE_ANO 		equ		P3.7	; Ajuste Ano

; DATA SEGMENT:
dseg			at 		8

;						   HORAS   DATA
COD0:
				ds		1		;  US		UA
COD1:
				ds		1		;  DS		DA
COD2:
				ds		1		;  .		-
COD3:
				ds		1		;  UM		UM
COD4:
				ds		1		;  DM		DM
COD5:
				ds		1		;  .		-
COD6:
				ds		1		;  UH		UD
COD7:
				ds		1		;  DH		DD

SEGUNDOS:
				ds		1		; Ocupa 1 bytes
MINUTOS:
				ds		1
HORAS:
				ds		1
DIAS:
				ds		1
MESES:
				ds		1
ANOS:
				ds		1
DIA_SEMANA:
				ds		1

; CODE SEGMENT:

cseg			at 		0

; ======================================
;				Reset do relógio
; ======================================

Reset:
		clr 		DISPLAY_0			; liga display 0
		setb		DISPLAY_1			; desliga display 1
		setb		DISPLAY_2			; desliga display 2
		setb		DISPLAY_3			; desliga display 3
		setb		DISPLAY_4			; desliga display 4
		setb		DISPLAY_5			; desliga display 5
		setb		DISPLAY_6			; desliga display 6
		setb		DISPLAY_7			; desliga display 7

		mov		SEGUNDOS, #0	; zera segundos
		mov		MINUTOS, #0 		; zera minutos
		mov		HORAS, #12			; define hora inicial = 12
		mov		DIAS, #26				; define dia inicial = 26
		mov		MESES, #4			; define mês inicial = 4
		mov		ANOS, #21			; define ano inicial = 21

; ======================================
;		  Varredura do display
; ======================================

DisplayScan:
		jnb		DISPLAY_0, Set_D0		; caso DISPLAY_0 ativo, seta display 0
		jnb		DISPLAY_1, Set_D1		; caso DISPLAY_1 ativo, seta display 1
		jnb		DISPLAY_2, Set_D2		; caso DISPLAY_2 ativo, seta display 2
		jnb		DISPLAY_3, Set_D3		; caso DISPLAY_3 ativo, seta display 3
		jnb		DISPLAY_4, Set_D4		; caso DISPLAY_4 ativo, seta display 4
		jnb		DISPLAY_5, Set_D5		; caso DISPLAY_5 ativo, seta display 5
		jnb		DISPLAY_6, Set_D6		; caso DISPLAY_6 ativo, seta display 6
		jnb		DISPLAY_7, Set_D7		; caso DISPLAY_7 ativo, seta display 7

Set_D0:
		setb		DISPLAY_0
		mov 		P0, COD1
		clr 		DISPLAY_1
		jmp 		Delay

Set_D1:
		setb		DISPLAY_1
		mov 		P0, COD2
		clr 		DISPLAY_2
		jmp 		Delay

Set_D2:
		setb		DISPLAY_2
		mov 		P0, COD3
		clr 		DISPLAY_3
		jmp 		Delay

Set_D3:
		setb		DISPLAY_3
		mov 		P0, COD4
		clr 		DISPLAY_4
		jmp 		Delay

Set_D4:
		setb		DISPLAY_4
		mov 		P0, COD5
		clr 		DISPLAY_5
		jmp 		Delay

Set_D5:
		setb		DISPLAY_5
		mov 		P0, COD6
		clr 		DISPLAY_6
		jmp 		Delay

Set_D6:
		setb		DISPLAY_6
		mov 		P0, COD7
		clr 		DISPLAY_7
		jmp 		Delay

Set_D7:
		setb		DISPLAY_7
		mov 		P0, COD0
		clr 		DISPLAY_0
		jmp 		Delay

; ======================================
;				Delay de 2.08 ms
; ======================================

Delay:
		mov 		r6, #6			; Delay  2,08ms para um clock de 12Mhz
L1:
		mov 		r5, #172
		djnz		r5, $
		djnz		r6, L1


; ======================================
;		  Mostrar dia da semana no display
; ======================================

IfBotaoDia:
		jnb 		BOTAO_DIA, MostrarDiaDaSemana
		jmp 		IfBotaoData

; ======================================
; 	Adicionar 5 números:
; 	R1 = OffsetDoMes + DIA + 6 + ANOS + ANOS / 4 (parte inteira)
; 	Dividir R1 por 7 e pegar o resto
; 	Dia = R1 % 7
; 	Se o ano for bissexto subtrair 1 do dia:
; 	Dia = Dia - 1
; ======================================
; Cálculo do dia da semana normal

MostrarDiaDaSemana:
		mov 		a, MESES 			; A = MESES
		mov 		dptr, #Offsets
		movc	a, @a+dptr			; A = OffsetDoMes
		mov 		b, DIAS
		add 		a, b						; A = OffsetDoMes + DIA
		mov 		b, #6
		add 		a, b						; A = OffsetDoMes + DIA + 6
		mov 		b, ANOS
		add 		a, b						; A = OffsetDoMes + DIA + 6 + ANOS
		mov 		r1, a						; R1 = A (guardo esse valor)
		mov 		a, ANOS
		mov 		b, #4
		div 		ab						; ANOS // 4 = a, ANOS % 4 = b
		add 		a, r1						; A = OffsetDoMes + DIA + 6 + ANOS + ANOS//4
		mov 		b, #7
		div 		ab						; A // 7 = a, A % 7 = b
		mov 		DIA_SEMANA, b	; R1 = b ( Dia da Semana: 0 - 6)

; Verificar se o ano é bissexto
		mov		a,ANOS
		mov		b,#4
		div		ab
		mov		a,b
		jz 		EhBissexto			; Se for bissexto
		mov		a, DIA_SEMANA
		jmp		Domingo

EhBissexto:
		dec 		DIA_SEMANA
		mov 		a, DIA_SEMANA
		jmp 		Domingo

Domingo:
		cjne		a, #0, SegundaFeira
		mov 		cod7, #0FFh	;domingo
		mov 		cod6, #0A1h
		mov 		cod5, #0A3h
		mov 		cod4, #0C8h
		mov 		cod3, #0CFh
		mov 		cod2, #0ABh
		mov 		cod1, #0C2h
		mov 		cod0, #0A3h

SegundaFeira:
		cjne		a, #1, TercaFeira
		mov 		cod7, #0FFh	;segunda-feira
		mov 		cod6, #92h
		mov 		cod5, #86h
		mov 		cod4, #0C2h
		mov 		cod3, #0c1h
		mov 		cod2, #0ABh
		mov 		cod1, #0A1h
		mov 		cod0, #88h

TercaFeira:
		cjne		a, #2, QuartaFeira
		mov 		cod7, #0FFh	;terça-feira
		mov 		cod6, #0FFh
		mov 		cod5, #0FFh
		mov 		cod4, #87h
		mov 		cod3, #86h
		mov 		cod2, #0AFh
		mov 		cod1, #0C6h
		mov 		cod0, #88h

QuartaFeira:
		cjne		a, #3, QuintaFeira
		mov 		cod7, #0FFh	;quarta-feira
		mov 		cod6, #0FFh
		mov 		cod5, #98h
		mov 		cod4, #0C1h
		mov 		cod3, #88h
		mov 		cod2, #0AFh
		mov 		cod1, #087h
		mov 		cod0, #88h
	
 QuintaFeira:
 		cjne		a, #4, SextaFeira
		mov 		cod7, #0FFh	;quinta-feira
		mov 		cod6, #0FFh
		mov 		cod5, #98h
		mov 		cod4, #0C1h
		mov 		cod3, #0CFh
		mov 		cod2, #0ABh
		mov 		cod1, #087h
		mov 		cod0, #88h

SextaFeira:
		cjne		a, #5, Sabado
		mov 		cod7, #0FFh	;sexta-feira
		mov 		cod6, #0FFh
		mov 		cod5, #0FFh
		mov 		cod4, #92h
		mov 		cod3, #86h
		mov 		cod2, #89h
		mov 		cod1, #087h
		mov 		cod0, #88h

Sabado:
		cjne		a, #6, GoToContador
		mov 		cod7, #0FFh	;sábado
		mov 		cod6, #0FFh
		mov 		cod5, #92h
		mov 		cod4, #88h
		mov 		cod3, #83h
		mov 		cod2, #88h
		mov 		cod1, #0A1h
		mov 		cod0, #0A3h

GoToContador:
		jmp		IncrementarContador

; Caso o botão esteja pressionado, mostrar data
IfBotaoData:
		jnb		BOTAO_DATA, MostrarData
; Caso o botão não seja pressionado, mostrar horas

; ======================================
;		Mostrar horas no display
; ======================================
		mov		a, SEGUNDOS
		mov		b, #10
		div		ab					; Quociente: dezena (a), Resto: unidade (b)
		mov		dptr, #tabela
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD1, a 			; Dezena de segundo
		mov		a, b
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD0, a 			; Unidade de segundo

		mov		COD2, #7Fh		; .

		mov		a, MINUTOS
		mov		b, #10
		div		ab					; Quociente: dezena (a), Resto: unidade (b)
		mov		dptr, #tabela
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD4, a 			; Dezena de minutos
		mov		a, b
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD3,  a			; Unidade de minutos

		mov		COD5, #7Fh		; .

		mov		a, HORAS
		mov		b, #10
		div		ab					; Quociente: dezena (a), Resto: unidade (b)
		mov		dptr, #tabela
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD7,  a			; Dezena de horas
		mov		a, b
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD6,  a			; Unidade de horas

		jmp		IncrementarContador

; ======================================
;		  Mostrar data no display
; ======================================

MostrarData:
		mov		a, ANOS
		mov		b, #10
		div		ab					; Quociente: dezena (a), Resto: unidade (b)
		mov		dptr, #tabela
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD1, a				; Dezena de dia
		mov		a, b
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov 		COD0, a 			; Unidade de dia
		mov 		COD2, #0bFh 	; - 
		mov 		a, MESES
		mov 		b, #10
		div 		ab					; Quociente: dezena (a),  Resto: unidade (b)
		mov 		dptr, #tabela
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD4, a 		 	; Dezena de mẽs
		mov		a, b
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD3, a 			; Unidade de mẽs
		mov		COD5, #0bFh 	; -
		mov		a, DIAS
		mov		b, #10
		div		ab					; Quociente: dezena (a),  Resto: unidade (b)
		mov		dptr, #tabela
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD7,  a		 	; Dezena de ano
		mov		a, b
		movc	a, @a + dptr		; Pega o código em 7 segmentos
		mov		COD6, a 		 	; Unidade de ano
		jmp		IncrementarContador

; ======================================
;		  Incrementar e zerar contador 
; ======================================

IncrementarContador:
;   R4 HIGH = 1 R3 LOW = E0h
		inc 		r3
		mov 		a, r3
		jnz 		LoopDoContador
		inc 		r4

LoopDoContador:
		mov 		a, r3
		cjne		a, #low(480), GoToDisplayScan
		mov 		a, r4
		cjne		a, #high(480), GoToDisplayScan
		jmp 		ZerarContador							; Passou 1 segundo

; Usando IncrementarSegundo como intermediário por causa do comando "jc"
GoToDisplayScan:
		jc			IncrementarSegundo 

ZerarContador:
		mov 		r3, #0
		mov 		r4, #0

; ======================================
;		  Ajustes
; ======================================

		jnb 		AJUSTE_SEG, AjustarSegundo
		jmp 		IfAjusteMinutos

AjustarSegundo:
		mov 		SEGUNDOS, #0

IfAjusteMinutos:
		jnb 		AJUSTE_MIN, AjustarMinutos
		jmp 		IfAjusteHora

AjustarMinutos:
		inc 		MINUTOS
		mov 		a, MINUTOS
		cjne		a, #60, IfAjusteHora
		mov 		MINUTOS, #0 						; não incrementa hora

IfAjusteHora:
		jnb 		AJUSTE_HORA, AjustarHoras
		jmp 		IfAjusteDia

AjustarHoras:
		inc 		HORAS
		mov 		a, HORAS
		cjne		a, #24, IfAjusteDia					; Hora diferente de 24
		mov 		HORAS, #0							; Hora igual a 24 (não incrementa o dia)

IfAjusteDia:
		jnb 		AJUSTE_DIA, AjustarDia
		jmp 		IfAjusteMes

AjustarDia:
		inc 		DIAS

IfAjusteMes:
		jnb 		AJUSTE_MES, AjustarMes
		jmp 		IfAjusteAno

AjustarMes:
		inc 		MESES
		mov 		a, MESES
		cjne		a, #13, IfAjusteAno				; Mes diferente de 13
		mov 		MESES, #1							; Mes igual a 13

IfAjusteAno:
		jnb 		AJUSTE_ANO, AjustarAno
		jmp 		ContagemDoRelogio

AjustarAno:
		inc 		ANOS
		mov 		a, ANOS
		cjne		a, #100, ContagemDoRelogio	; Ano diferente de 100
		mov 		ANOS, #0								; Ano igual a 100

; ======================================
;		  Incrementa relógio
; ======================================

ContagemDoRelogio:
		inc 		SEGUNDOS
		mov 		a, SEGUNDOS
		cjne		a, #60, IncrementarSegundo	; Segundo diferente de 60
		jmp 		ZerarSegundo 						; Segundo igual a 60

IncrementarSegundo:
		jc  		LoopDoRelogio

ZerarSegundo:
		mov 		SEGUNDOS, #0
		inc 		MINUTOS
		mov 		a, MINUTOS
		cjne		a, #60, IncrementarMinuto		; Minuto diferente de 60
		jmp 		ZerarMinuto 							; Minuto igual a 60

IncrementarMinuto:
		jc			LoopDoRelogio

ZerarMinuto:
		mov 		MINUTOS, #0
		inc 		HORAS
		mov 		a, HORAS
		cjne		a, #24, IncrementarHora 		; Hora diferente de 24
		jmp 		ZerarHora								; Hora igual a 24

IncrementarHora:
		jc			LoopDoRelogio  ; É menor

ZerarHora:
		mov 		HORAS, #0
		inc 		DIAS
		jmp 		IfJaneiro

LoopDoRelogio:
		jnb 		AJUSTE_DIA, IfJaneiro 		; Caso esteja ajustando o dia, verificar o mês para reset do dia
		jmp 		DisplayScan


; ======================================
;		  Incrementar mês e ano
; ======================================
IfJaneiro:
		mov 		a, MESES
		cjne		a, #1, IfFevereiro					; Mes diferente de 1 (Fev)
		jmp 		Mes31

IfFevereiro:
		cjne		a, #2, IfMarco
		jmp 		Fevereiro

IfMarco:
		cjne		a, #3, IfAbril
		jmp 		Mes31

IfAbril:
		cjne		a, #4, IfMaio
		jmp 		Mes30

IfMaio:
		cjne		a, #5, IfJunho
		jmp 		Mes31

IfJunho:
		cjne		a, #6, IfJulho
		jmp 		Mes30

IfJulho:
		cjne		a, #7, IfAgosto
		jmp 		Mes31

IfAgosto:
		cjne		a, #8, IfSetembro
		jmp 		Mes31

IfSetembro:
		cjne		a, #9, IfOutubro
		jmp 		Mes30

IfOutubro:
		cjne		a, #10, IfNovembro
		jmp 		Mes31

IfNovembro:
		cjne		a, #11, IfDezembro
		jmp 		Mes30

IfDezembro:
		cjne		a, #12, AtualizarDisplay
		mov 		a, DIAS
		cjne		a, #31, IncrementarAno
		jmp 		AtualizarDisplay

IncrementarAno:
		jc			AtualizarDisplay
		mov 		DIAS, #1
		mov 		MESES, #1
		inc 		ANOS
		mov 		a, ANOS
		cjne		a, #100, ResetaAno
		jmp 		AtualizarDisplay

ResetaAno:
		jc  		AtualizarDisplay
		mov 		ANOS, #0
		jmp 		AtualizarDisplay

Mes30:
		mov 		a, DIAS
		cjne		a, #30, IncrementaMes
		jmp 		AtualizarDisplay

Mes31:
		mov 		a, DIAS
		cjne		a, #31, IncrementaMes
		jmp 		AtualizarDisplay

Fevereiro:
		mov 		a, ANOS
		mov 		b, #4
		div 		ab
		mov 		a, b
		jz			AnoBissexto
		mov 		a, DIAS
		cjne		a, #28, IncrementaMes
		jmp 		AtualizarDisplay

AnoBissexto:
		mov 		a, DIAS
		cjne		a, #29, IncrementaMes
		jmp 		AtualizarDisplay

IncrementaMes:
		jc			AtualizarDisplay
		mov 		DIAS, #1
		inc 		MESES
		jmp 		AtualizarDisplay

AtualizarDisplay:
		jmp 		DisplayScan
;=====================================================		   


tabela:
		db		0c0h		; 0 código do zero
		db		0f9h		; 1 
		db		0a4h		; 2 
		db		0b0h		; 3 
		db		099h		; 4 
		db		092h		; 5 
		db		082h		; 6 
		db		0f8h		; 7 
		db		080h		; 8 
		db		090h		; 9

; Tabela auxiliar para encontrar o dia da semana

Offsets:
		db		0h  		; Zero
		db		0h  		; janeiro
		db		3h  		; fevereiro
		db		3h  		; março
		db		6h  		; abril
		db		1h  		; maio
		db		4h  		; junho
		db		6h  		; julho
		db		2h  		; agosto
		db		5h  		; setembro
		db		0h  		; outubro
		db		3h  		; novembro
		db		5h  		; dezembro
end