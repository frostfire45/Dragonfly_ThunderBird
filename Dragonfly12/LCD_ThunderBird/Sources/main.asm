
            INCLUDE 'derivative.inc'
            INCLUDE '1602a1LCD.inc'

            XDEF Entry, _Startup, main,
            XDEF lcd_init,set_lcd_addr,clear_lcd,hex2lcd,hex2asc,type_lcd
            XREF __SEG_END_SSTACK 

EN:     EQU   mPORTA_BIT0
R:      EQU   mPORTA_BIT1
RW:     EQU   mPORTA_BIT2

DataSect:     SECTION
Period:         DS.B    2
EntryLCD:       DS.W    6
TICKS:          DS.B    1
COUNT:          DS.B    1
COUNT_SEC:      DS.W    1
BUFFER:         DS.W    2
LCD_BUFFER:     DS.W    16

ConstSect:      SECTION


init_codes: 
                fcb	12		; number of high nibbles
                fcb	$30		; 1st reset code, must delay 4.1ms after sending
                fcb	$30		; 2nd reste code, must delay 100us after sending
                ;  following 10 nibbles must  delay 40us each after sending
                fcb     $30   ; 3rd reset code,
                fcb	$20		; 4th reste code,
                fcb	$20   ; 4 bit mode, 2 line, 5X7 dot
                fcb	$80   ; 4 bit mode, 2 line, 5X7 dot
                fcb	$00		; cursor increment, disable display shift
                fcb	$60		; cursor increment, disable display shift
                fcb	$00		; display on, cursor off, no blinking
                fcb	$C0		; display on, cursor off, no blinking
                fcb	$00		; clear display memory, set cursor to home pos
                fcb	$10		; clear display memory, set cursor to home pos
  
           
MyCode:     SECTION
main:
_Startup:
Entry:
        LDS  #__SEG_END_SSTACK
        CLI
 ifdef _HCS12_SERIALMON
        ; set registers at $0000
        CLR   $11 ;INITRG= $0
        ; set ram to end at $3fff
        LDAB  #$39; INITRM= $39
        STAB  $10 
        LDAA  #$9;  set eeprom to end at $0fff             
        STAA  $12; INITEE= $9
 endif

SetUp:
        JSR     lcd_init
        JSR     Clock_Init
        JSR     Hall_Init
        JSR     Puls_Init
        MOVB    #$00,TICKS
        
MainLoop:
        JSR     Hall1
        JSR     Calc_Period
        JSR     Calc_RPM
        BLO     TimeTick
        JMP     MainLoop

;===================================================
;   LCD Suboutines
;---------------------------------------------------
;   * Initiate - lcd_init
;   * Set Address - set_lcd_addr
;   * Clear Disp - clear_lcd
;   * Ouptut Hex - hex2lcd
;   * Output ACHII - hex2asc
;   * Output String - type_lcd
;___________________________________________________
lcd_init:
        ldaa	#$ff
        staa	DDRB		              ; port K = output
        ldx	#init_codes 	        ; point to init. codes.
        pshb            	          ; output instruction command.
       	ldab   	1,x+                ; no. of codes
lcdi1:	ldaa   	1,x+                ; get next code
       	jsr    	write_instr_nibble 	; initiate write pulse.
       	pshd
       	ldd     #5
       	jsr     ms_delay		;delay 5 ms
       	puld
       	decb                    ; in reset sequence to simplify coding
       	bne    	lcdi1
       	pulb
       	rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx 
          
write_instr_nibble:
        anda    #$F0
        lsra
        lsra            ; nibble in PK2-PK5
        oraa    #$02    ; E = 1 in PK1; RS = 0 in PK0
        staa    PORTB
        ldy     #10
win     dey
        bne     win
        anda    #$FC    ; E = 0 in PK1; RS = 0 in PK0
        staa    PORTB
        rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx

write_data_nibble:
        anda    #$F0
        lsra
        lsra            ; nibble in PK2-PK5
        oraa    #$03    ; E = 1 in PK1; RS = 1 in PK0
        staa    PORTB
        ldy     #10
wdn     dey
        bne     wdn
        anda    #$FD    ; E = 0 in PK1; RS = 1 in PK0
        staa    PORTB
        rts
write_instr_byte:
        psha
        jsr     write_instr_nibble
        pula
        asla
        asla
        asla
        asla
        jsr     write_instr_nibble
        rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx

write_data_byte:
        psha
        jsr     write_data_nibble
        pula
        asla
        asla
        asla
        asla
        jsr     write_data_nibble
        rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx  
      
;   write instruction byte B to LCD
instr8:
            tba
;            jsr   sel_inst
            jsr   write_instr_byte
            ldd     #10
            jsr     ms_delay
            rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx            

;   write data byte B to LCD
data8:
            tba
;            jsr   sel_data
            jsr   write_data_byte
            ldd     #10
            jsr     ms_delay
            rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx
;   set address to B
set_lcd_addr:
            orab    #$80
            tba
            jsr     write_instr_byte
            ldd     #10
            jsr     ms_delay
            rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx
;   clear LCD
clear_lcd:
            ldaa    #$01
            jsr     write_instr_byte
            ldd     #10
            jsr     ms_delay
            rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx                                    
;	display hex value in B on LCD�
hex2lcd:  
	          bsr	hex2asc		  ;convert to ascii
	          jsr	data8		    ;display it
	          rts
 ;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx
;       Hex to ascii subroutine
;       input: B = hex value
;       output: B = ascii value of lower nibble of input
hex2asc:
        andb    #$0f    	;mask upper nibble
        cmpb    #$9     	;if B > 9
        bls     ha1     
        addb    #$37    	; add $37
        rts             	  ;else
ha1     addb    #$30    	; add $30
        rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx
;---------------------------------------------------------
;	display asciiz string on LCD
;	D -> asciiz string�
type_lcd:
        pshx              ;save X
        tfr     D,X       ;X -> asciiz string
next_char:   ldaa        1,X+		  ;get next char
        beq	    done		  ;if null, quit
	jsr	    write_data_byte	;else display it
        ldd     #10
        jsr     ms_delay
	bra	    next_char	;and repeat
done:	pulx              ;restore X
        rts
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx
StringToHex:
        LDX     #10000
        LDY     BUFFER
        LDD     BUFFER+1
        EDIV
        XGDY
        STAB    BUFFER
        XGDY
        LDY     #BUFFER+1
        LDX     #1000
        IDIV
        XGDX
        STAB    1,Y+
        XGDX    
        LDX     #100
        IDIV    
        XGDX
        STAB    1,Y+
        XGDX
        LDX     #10
        IDIV
        XGDX
        STAB    1,Y+
        XGDX
        STAB    1,Y+
        RTS
;xxxxxxxxxxxxxxxxxxx
;x END SUBROUTINE  x
;xxxxxxxxxxxxxxxxxxx
;-----------------------------------------------------------

;===================================
; Clock Details
;-----------------------------------
;

Clock_Init: 
        MOVB    #$90,TSCR1
        BSET    #$07,TSCR2
        BSET    #$01,TFLG2
        MOVB    COUNT,TICKS
        RTS

Clock_IRQ:
            INC         TICKS
            LDAA        TICKS
            BEQ         OneComplete
            RTS
            
OneComplete:
            MOVB        #$00,TICKS
            LDD         #Read_Count
            STD         7,SP
            RTS
;---------------------------------------------------------------

;===================================
;  Hall Sensor Routines
;-----------------------------------
;Using PT0 and PT1
Hall_Init:
        ; PACN0                
        ;MOVB    $40,PBCTL
        ;MOVW    $0000,PACN0
        
        BCLR    TIOS,$01
        BSET    TIE,$01
        BSET    TCTL4,$02
        BSET    TFLG1,$01
        RTS

Hall1:  BRCLR   TFLG1,$01,Hall1
        MOVW    TC0,Period
Hall2:  BRCLR   TFLG1,$01,Hall2
        LDD     TC0
        CPD     Period
        BLO     COMP
        SUBD    Period
        JMP     Hall_End
COMP:   COM     Period
        COM     Period+1
        ADDD    Period        
Hall_End:
        STD     Period
        RTS     

Read_Count:
        SEI
        MOVW    PACN10,COUNT_SEC
        JSR     Calc_Results
        JMP     MainLoop
 ;===================================
 ;  Pulse Width Functions
 ;-----------------------------------
 ;  * Puls_Init
 Puls_Init:
        BSET   PWME,$01
        BSET   PWMPOL,$01 ; Starts High
        BSET   PWMCLK,$01 ; Using Scaled B
        BSET   PWMPRCLK,07 ; 24 MHz / 128
        BSET   PWMSCLA,$0A
        BCLR   PWMCAE,$01
        MOVB   #100,PWMCNT0
        MOVB   #50,PWMDTY0
        RTS
 
 Set_PW:   
        STAB   PWMDTY0
        RTS
;==========================================
;  Calc_Results
;------------------------------------------
;
Calc_Period:
        LDD     Period
        LDX     #187
        IDIV
        STX     BUFFER
        STD     BUFFER+2
        RTS
Calc_RPM:
        LDY     #60
        LDD     
Calc_Results:
        LDD    COUNT_SEC
        LDY    #60
        EMUL
        STY     BUFFER
        STD     BUFFER+1
        RTS 
;===================================================
;Time Delay
;---------------------------------------------------
;
;
;___________________________________________________
ms_delay:
          pshx
          pshy
          tfr     D,Y
md1:      ldx     #5999   ; N = (24000 - 5)/4
md2:      dex             ; 1 ccycle
          bne     md2     ; 3 ccycle
          dey             
          bne     md1     ; Y ms
          puly
          pulx
          rts
           
           LDY	#10000		; 10000 x 4 = 40,000 cycles = 1.67ms
dly1		   DEY			; 1 cycle
		       BNE	dly1		; 3 cycles 		
		
		       RTS
			
d_10ms   	LDY	#60000		; 60000 x 4 = 240,000 cycles = 10ms
dly		    DEY			; 1 cycle
		      BNE	dly		; 3 cycles
		      RTS
 
DELAY:    jmp   dly
