RTN_Home: equ   %00000010
RST_LCD:  equ   %00000001

;**** BITSETUP *******
mShift_Left:   equ   %00000110
mShift_Rigt:   equ   %00000111

Disp_On:       equ   %00001111
Disp_Off:      equ   %00001000

mCurseOn:       equ   %00001010
mCurseOff:      equ   mCurseOn

mCseBlkOn:      equ   %00001001
mCseBlkOff:     equ   mCseBlkOn

mShiftC_Left:   equ   %00010000
mShiftC_Righ:   equ   %00010100

mShiftDCF_Left: equ   %00011000
mShiftDCF_Rigt: equ   %00011100

mBusMode_4Bit:  equ   %00100000
mBusMode_8Bit:  equ   %00110000

; BSET
mLineDisp_One:  equ   %00101000
; BCLR
mLineDisp_Two:  equ   mLineDisp_One

m5by8:          equ   %00100000
m5by11:         equ   %00100100
m5by8_Two:      equ   %00101100
 