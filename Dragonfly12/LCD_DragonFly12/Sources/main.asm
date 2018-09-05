;**************************************************************
;* This stationery serves as the framework for a              *
;* user application. For a more comprehensive program that    *
;* demonstrates the more advanced functionality of this       *
;* processor, please see the demonstration applications       *
;* located in the examples subdirectory of the                *
;* Freescale CodeWarrior for the HC12 Program directory       *
;**************************************************************
; Include derivative-specific definitions
            INCLUDE 'derivative.inc'

; export symbols
            XDEF Entry, _Startup, main
            ; we use export 'Entry' as symbol. This allows us to
            ; reference 'Entry' either in the linker .prm file
            ; or from C/C++ later on

            XREF __SEG_END_SSTACK      ; symbol defined by the linker for the end of the stack




; variable/data section
DEFAULT_RAM: SECTION
Temp:       DC.B  1


; code section
MyCode:     SECTION
main:
_Startup:
Entry:
            LDS  #__SEG_END_SSTACK     ; initialize the stack pointer
            CLI                     ; enable interrupts
            BSET  DDRT,$FF
            MOVB  #$0F,PTT
            MOVB  #$0F,Temp
mainLoop:
            LDAA  Temp
            DECA
            STAA  Temp
            STAA  PTT
            LDY   #200
            
l1:         NOP
            NOP
            DEY
            BNE   l1            
            LDAA  Temp
            CMPA  #0
            BNE   mainLoop
            MOVB  #$0F,Temp
            jmp   mainLoop


