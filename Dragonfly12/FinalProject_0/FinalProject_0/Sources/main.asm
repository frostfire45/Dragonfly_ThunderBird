;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000  ; absolute address to place my code/constant data


            ORG     $1000
EDGE1:      DC.W    1
EDGE_COM:   DC.W    1

; variable/data section

 ifdef _HCS12_SERIALMON
            ORG $3FFF - (RAMEnd - RAMStart)
 else
            ORG RAMStart
 endif

            ORG   ROMStart


Entry:
_Startup:
            ; remap the RAM &amp; EEPROM here. See EB386.pdf
 ifdef _HCS12_SERIALMON
            ; set registers at $0000
            CLR   $11                  ; INITRG= $0
            ; set ram to end at $3FFF
            LDAB  #$39
            STAB  $10                  ; INITRM= $39

            ; set eeprom to end at $0FFF
            LDAA  #$9
            STAA  $12                  ; INITEE= $9


            LDS   #$3FFF+1        ; See EB386.pdf, initialize the stack pointer
 else
            LDS   #RAMEnd+1       ; initialize the stack pointer
 endif

            CLI                     ; enable interrupts
            JSR     HallSetup
            JSR     PW_SETUP
            
mainLoop:
            

HallSetup:
            BSET    TIOS,mTIOS_IOS0   ; INPUT CAPTURE PT0
            BSET    TSCR1,$90
            BSET    TCTL4,$02
            BCLR    TIE,$01    ; CORRESPONDING BIT TO FOR FLAG
            BSET    TSCR2,$87
            BSET    TFLG1,$01  ; FLAG OCCURANCE; SETTING NOW.     
            RTS

ReadSensor:
            LDAA    TC0
INPUT       BRCLR   TFLG1,$01,INPUT
            LDD     TC0
            STD     EDGE1
INPUT2      BRCLR   TFLG1,$01,INPUT2
            CPD     EDGE1
            BLO     COMP
            SUBD    EDGE1
            JMP     RES
COMP        COM     EDGE1
            COM     EDGE1+1
            ADDD    EDGE1
RES         STD     EDGE_COM              
            RTS

PW_SETUP:   
            BSET    PWME,mPWME_PWME5
            BSET    PWMPOL,mPWMPOL_PPOL5
            BSET    PWMCLK,mPWMCLK_PCLK5
            BSET    PWMPRCLK,$07
            BCLR    PWMCAE,mPWMCAE_CAE5
            MOVB    #255,PWMPER5
            MOVB    #123,PWMDTY5
            RTS
            
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
