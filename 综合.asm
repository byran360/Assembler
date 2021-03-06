;This is a curriculum design with assembler language. The function of clock and alarm clock is realised in this project.

.486
CODE    SEGMENT		USE16
        ASSUME 	CS:CODE
	ORG     1000H
START:JMP BEG
;1. 设置变量
;三色数码管变量
   DUAN	DB 0C0H,0F9H,0A4H,0B0H,99H,92H,82H,0F8H,80H,90H  ;0~9 字形码
   TL_A1 	EQU 200H			;第1个8255地址
   TL_B1 	EQU 204H
   TL_A2 	EQU 201H			;第2个8255地址
   TL_B2 	EQU 205H
   TL_A3	EQU 202H			;第3个8255地址
   TL_B3 	EQU 206H
   TL_A4 	EQU 203H			;第4个8255地址
   TL_B4 	EQU 207H 
   TL_C1	EQU 208H			;颜色
   TL_C2	EQU 209H
   TL_C3	EQU 20AH
   TL_C4	EQU 20BH
   TL_CON1  	EQU 20CH	;控制端口
   TL_CON2 	EQU 20DH
   TL_CON3  	EQU 20EH
   TL_CON4  	EQU 20FH
   MIAO_A 	DB 0			;秒标识
   MIAO_B 	DB 0
   FEN_A	DB 0			;分标识
   FEN_B  	DB 0
   SHI_A	DB 0			;时标识
   SHI_B 	DB 0
;8254变量
   PORT0 EQU 360H		;通道0
   PORT1 EQU 364H		;通道1，用于级联
   PORT2 EQU 368H		
   CTRL_8254 EQU 36CH
;8255变量
   PORTA EQU 3A0H		;A0判断8254
   PORTB EQU 3A4H		;B0输出到蜂鸣器
   PORTC EQU 3A8H		;C口接键盘
   CTRL_8255  EQU 3ACH	
;键盘标识
   TIME_KFLAG	EQU	11100000B	;时钟键盘标识
   ALARM_KFLAG	EQU	11010000B	;定时闹钟键盘标识
  COUNTER_KFLAG EQU	10110000B	;计时闹钟键盘标识
   MODIFY_FLAG	EQU	00001110B	;修改键
   ENTER_FLAG	EQU	00001101B	;确定键
   ADD1_FLAG	EQU	00001011B	;加一键
   SUB1_FLAG	EQU	00000111B	;减一键
;闪烁、加一减一标识
   GLINT_FLAG		DB 	0
   GLINT_ALARM_FLAG	DB	0	;定时闹钟标识
   GLINT_COUNTER_FLAG	DB 	0	;计时闹钟标识
;闹钟标识
   ;定时器
   ALARM_MIAO_A DB 0			;秒
   ALARM_MIAO_B DB 0
   ALARM_FEN_A  DB 0			;分
   ALARM_FEN_B  DB 0
   ALARM_SHI_A  DB 1			;时
   ALARM_SHI_B  DB 4
   ;计时器
   COUNTER_MIAO_A 	DB 0			;秒
   COUNTER_MIAO_B 	DB 1
   COUNTER_FEN_A	DB 0			;分
   COUNTER_FEN_B  	DB 0
   COUNTER_SHI_A	DB 0			;时
   COUNTER_SHI_B 	DB 0
   COUNTER_FLAG		DB 0  			;计时器标识
   
BEG:	
;2.初始化
   ;初始化三色数码管8255
	MOV DX,TL_CON1				;控制字，全输出
	MOV AL,80H	
	OUT DX,AL
	MOV DX,TL_CON2
	MOV AL,80H
	OUT DX,AL
	MOV DX,TL_CON3
	MOV AL,80H
	OUT DX,AL
	MOV DX,TL_CON4
	MOV AL,80H
	OUT DX,AL
	;MOV DX,TL_C1					;屏蔽
	;MOV AL,0FH
	;OUT DX,AL
	;MOV DX,TL_C2					;绿色
	;MOV AL,0AH
	;OUT DX,AL
	;MOV DX,TL_C3					;绿色
	;MOV AL,0AH
	;OUT DX,AL
	;MOV DX,TL_C4					;绿色
	;MOV AL,0AH
	;OUT DX,AL
	;CALL DISPLAY_NUM			;显示00：00：00
   ;8254定时1s
	MOV DX,CTRL_8254			;8254通道0送控制字，方式2
	MOV AL,00110100B
	OUT DX,AL
	MOV DX,PORT0				;计时1s
	MOV AX,47000
	OUT DX,AL
	MOV AL,AH
	OUT DX,AL
   ;8255初始化
	MOV DX,CTRL_8255		;A通道输入（8254），C口高四位输出，低四位输入（键盘）
	MOV AL,10010001B        
	OUT DX,AL  
	
;3 MAIN.ASM
AGAIN:
	CALL KEYBOARD			;键盘功能
	CALL JUDGE1S		;判断是否到1s，当有1s，则时钟标识加一
	CALL DISPLAY_NUM	;显示时钟数值XX-XX-XX
	JMP AGAIN	
WT:	JMP WT				;死循环		

;判断是否按下时钟修改键
JUDGE_TIME_MODIFY_KEY	PROC 	NEAR
	MOV DX,PORTC				;判断按键
	MOV AL,TIME_KFLAG
	OUT DX,AL
	NOP
	IN AL,DX
	AND AL,0FH
	RET
JUDGE_TIME_MODIFY_KEY ENDP

;判断是否按下定时闹钟修改键
JUDGE_ALARM_MODIFY_KEY	PROC 	NEAR
	MOV DX,PORTC				;判断按键
	MOV AL,ALARM_KFLAG
	OUT DX,AL
	NOP
	IN AL,DX
	AND AL,0FH
	RET
JUDGE_ALARM_MODIFY_KEY ENDP

;判断是否按下定时闹钟修改键
JUDGE_COUNTER_MODIFY_KEY	PROC 	NEAR
	MOV DX,PORTC				;判断按键
	MOV AL,COUNTER_KFLAG
	OUT DX,AL
	NOP
	IN AL,DX
	AND AL,0FH
	RET
JUDGE_COUNTER_MODIFY_KEY ENDP 

;键盘	
KEYBOARD	PROC 	NEAR
;闹钟功能
ALARM_CLOCK:
	CALL JUDGE_ALARM_MODIFY_KEY		;定时闹钟
	CMP AL,MODIFY_FLAG
	JZ ALARM_JUDGE				
	CALL JUDGE_COUNTER_MODIFY_KEY		;计时闹钟
	CMP AL,MODIFY_FLAG
	JZ COUNTER_JUDGE			
	JMP TIME_CLOCK
ALARM_JUDGE:
	CALL ALARM_CLOCK_CHANGE
	JMP TIME_CLOCK
COUNTER_JUDGE:
	CALL COUNTER_CLOCK_CHANGE

;时钟功能
TIME_CLOCK:
	CALL JUDGE_TIME_MODIFY_KEY
	CMP AL,MODIFY_FLAG			;修改键
	JZ MODIFY_KEY
	JMP KEYBOARD_END
MODIFY_KEY:
	CALL DISPLAY_NUM
	CALL GLINT				;闪烁
	CALL JUDGE1S			;在设置时间时，倒计时也同时在运行
	CALL JUDGE_TIME_MODIFY_KEY	;按下修改键？
	CMP AL,MODIFY_FLAG			;修改键
	JZ GLINT_CHANGE
	CMP AL,ENTER_FLAG			;确定键
	JZ ENTER_KEY		
	CMP AL,ADD1_FLAG			;加一键
	JZ ADD_1
	CMP AL,SUB1_FLAG			;减一键
	JZ SUB_1
	JMP MODIFY_KEY
GLINT_CHANGE:
	INC GLINT_FLAG
	CMP GLINT_FLAG,3
	JNZ GLINT_RESET
	MOV GLINT_FLAG,0
GLINT_RESET:
	CALL GLINT
	JMP MODIFY_KEY
ADD_1:
	CALL ADD1
	CALL DISPLAY_NUM
	CALL DELAY_L
	JMP MODIFY_KEY
SUB_1:
	CALL SUB1
	CALL DISPLAY_NUM
	CALL DELAY_L
	JMP MODIFY_KEY
ENTER_KEY:
	CALL DISPLAY_NUM
KEYBOARD_END:
	RET
KEYBOARD ENDP


;是否到1s，标志位是否加
JUDGE1S	   PROC    NEAR
	MOV DX,PORTA
	IN AL,DX
	AND AL,01H
	CMP AL,00H	;是否1s
	JNZ NOT_ADD1
	CALL TIME_ADD	
	CALL ALARM_CLOCK_CALL		;是否闹钟响
	CMP COUNTER_FLAG,1		;是否启用计数器
	JNZ NOT_ADD1
	CALL COUNTER_TIME_SUB
	CALL COUNTER_CLOCK_CALL
NOT_ADD1:
	RET
JUDGE1S ENDP
	
	
;显示时钟时间
DISPLAY_NUM	PROC	NEAR
	MOV BX,OFFSET DUAN		;秒最低位赋初值
	MOV AL,MIAO_B
	XLAT
	MOV DX,TL_B4
	OUT DX,AL
	CALL DELAY_L
	MOV BX,OFFSET DUAN		;秒最高位赋初值
	MOV AL,MIAO_A
	XLAT
	MOV DX,TL_A4
	OUT DX,AL
	CALL DELAY_L
	MOV BX,OFFSET DUAN		;分最低位赋初值
	MOV AL,FEN_B
	XLAT
	MOV DX,TL_B3
	OUT DX,AL
	CALL DELAY_L
	MOV BX,OFFSET DUAN		;分最高位赋初值
	MOV AL,FEN_A
	XLAT
	MOV DX,TL_A3
	OUT DX,AL
	CALL DELAY_L
	MOV BX,OFFSET DUAN		;时最低位赋初值
	MOV AL,SHI_B
	XLAT
	MOV DX,TL_B2
	OUT DX,AL
	CALL DELAY_L
	MOV BX,OFFSET DUAN		;时最高位赋初值
	MOV AL,SHI_A
	XLAT
	MOV DX,TL_A2
	OUT DX,AL
	CALL DELAY_L
	RET
DISPLAY_NUM ENDP

;显示定时闹钟时间
DISPLAY_ALARM	PROC	NEAR
	MOV BX,OFFSET DUAN		;秒最低位赋初值
	MOV AL,ALARM_MIAO_B
	XLAT
	MOV DX,TL_B4
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;秒最高位赋初值
	MOV AL,ALARM_MIAO_A
	XLAT
	MOV DX,TL_A4
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;分最低位赋初值
	MOV AL,ALARM_FEN_B
	XLAT
	MOV DX,TL_B3
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;分最高位赋初值
	MOV AL,ALARM_FEN_A
	XLAT
	MOV DX,TL_A3
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;时最低位赋初值
	MOV AL,ALARM_SHI_B
	XLAT
	MOV DX,TL_B2
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;时最高位赋初值
	MOV AL,ALARM_SHI_A
	XLAT
	MOV DX,TL_A2
	OUT DX,AL
	CALL DELAY_S
	RET
DISPLAY_ALARM ENDP

;显示计时时钟时间
DISPLAY_COUNTER		PROC	NEAR
	MOV BX,OFFSET DUAN		;秒最低位赋初值
	MOV AL,COUNTER_MIAO_B
	XLAT
	MOV DX,TL_B4
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;秒最高位赋初值
	MOV AL,COUNTER_MIAO_A
	XLAT
	MOV DX,TL_A4
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;分最低位赋初值
	MOV AL,COUNTER_FEN_B
	XLAT
	MOV DX,TL_B3
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;分最高位赋初值
	MOV AL,COUNTER_FEN_A
	XLAT
	MOV DX,TL_A3
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;时最低位赋初值
	MOV AL,COUNTER_SHI_B
	XLAT
	MOV DX,TL_B2
	OUT DX,AL
	CALL DELAY_S
	MOV BX,OFFSET DUAN		;时最高位赋初值
	MOV AL,COUNTER_SHI_A
	XLAT
	MOV DX,TL_A2
	OUT DX,AL
	CALL DELAY_S
	RET
DISPLAY_COUNTER ENDP

;时钟时间+1s
TIME_ADD   PROC    NEAR
	CMP MIAO_B,9
	JNB MIAOB_RESET		;秒最低位归零
	INC MIAO_B
	JMP TIME_ADD_END
MIAOB_RESET:
	MOV MIAO_B,0
	CMP MIAO_A,5
	JNB MIAOA_RESET		;秒最高位归零
	INC MIAO_A
	JMP TIME_ADD_END
MIAOA_RESET:
	MOV MIAO_A,0
	CMP FEN_B,9
	JNB FENB_RESET		;分最低位归零
	INC FEN_B
	JMP TIME_ADD_END
FENB_RESET:
	MOV FEN_B,0
	CMP FEN_A,5
	JNB FENA_RESET		;分最高位归零
	INC FEN_A
	JMP TIME_ADD_END
FENA_RESET:
	MOV FEN_A,0
	CMP SHI_B,3
	JZ SHIA_JUDGE
	CMP SHI_B,9
	JNB SHIB_RESET
SHIB_ADD1:
	INC SHI_B
	JMP TIME_ADD_END
SHIA_JUDGE:
	CMP SHI_A,1
	JNA SHIB_ADD1
SHIB_RESET:
	MOV SHI_B,0
	CMP SHI_A,2
	JNB SHIA_RESET		;时最高位归零
	INC SHI_A
	JMP TIME_ADD_END
SHIA_RESET:
	MOV SHI_A,0
TIME_ADD_END:
	RET
TIME_ADD ENDP	

;定时时钟-1s
COUNTER_TIME_SUB	PROC	NEAR
	CMP COUNTER_MIAO_B,0
	JNA COUNTER_MIAOB_RESET		;秒最低位归9
	DEC COUNTER_MIAO_B
	JMP TIME_SUB_COUNTER_END
COUNTER_MIAOB_RESET:
	MOV COUNTER_MIAO_B,9
	CMP COUNTER_MIAO_A,0
	JNA COUNTER_MIAOA_RESET		;秒最高位归5
	DEC COUNTER_MIAO_A
	JMP TIME_SUB_COUNTER_END
COUNTER_MIAOA_RESET:
	MOV COUNTER_MIAO_A,5
	CMP COUNTER_FEN_B,0
	JNA COUNTER_FENB_RESET		;分最低位归9
	DEC COUNTER_FEN_B
	JMP TIME_SUB_COUNTER_END
COUNTER_FENB_RESET:
	MOV COUNTER_FEN_B,9
	CMP COUNTER_FEN_A,0
	JNA COUNTER_FENA_RESET		;分最高位归5
	DEC COUNTER_FEN_A
	JMP TIME_SUB_COUNTER_END
COUNTER_FENA_RESET:
	MOV FEN_A,5
	CMP SHI_B,0
	JNA COUNTER_SHIB_RESET			;时最低位归3
	DEC SHI_B
	JMP TIME_SUB_COUNTER_END
COUNTER_SHIB_RESET:
	CMP SHI_A,1
	JNB COUNTER_SHIB_RESET9
	MOV SHI_B,3
	MOV SHI_A,2
	JMP TIME_SUB_COUNTER_END
COUNTER_SHIB_RESET9:
	MOV SHI_B,9
	DEC SHI_A
	JMP TIME_SUB_COUNTER_END	
TIME_SUB_COUNTER_END:
	RET
COUNTER_TIME_SUB ENDP	
	
;--------时钟---------;
;闪烁
GLINT	PROC	 NEAR
	CMP GLINT_FLAG,0		;时闪烁
	JZ SHI_GLINT
	CMP GLINT_FLAG,1		;分闪烁
	JZ FEN_GLINT
	CMP GLINT_FLAG,2		;秒闪烁
	JZ MIAO_GLINT
SHI_GLINT:
	MOV DX,TL_B2	;时灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A2	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_END
FEN_GLINT:
	MOV DX,TL_B3	;分灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A3	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_END
MIAO_GLINT:
	MOV DX,TL_B4	;秒灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A4	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_END
GLINT_END:
	RET
GLINT ENDP
	
;加一
ADD1	PROC	NEAR
	CMP GLINT_FLAG,0		;时+1
	JZ SHI_ADD1
	CMP GLINT_FLAG,1		;分+1
	JZ FEN_ADD1
	CMP GLINT_FLAG,2		;秒+1
	JZ MIAO_ADD1
SHI_ADD1:					;时
	CMP SHI_B,4
	JNB SHIB_RESET1
	INC SHI_B
	JMP ADD1_END
SHIB_RESET1:
	MOV SHI_B,0
	CMP SHI_A,2
	JNB SHIA_RESET1
	INC FEN_A
	JMP ADD1_END
SHIA_RESET1:
	MOV SHI_A,0
	JMP ADD1_END
FEN_ADD1:					;分
	CMP FEN_B,9
	JNB FENB_RESET1
	INC FEN_B
	JMP ADD1_END
FENB_RESET1:
	MOV FEN_B,0
	CMP FEN_A,5
	JNB FENA_RESET1
	INC FEN_A
	JMP ADD1_END
FENA_RESET1:
	MOV FEN_A,0 
	JMP ADD1_END
MIAO_ADD1:					;秒
	CMP MIAO_B,9
	JNB MIAOB_RESET1
	INC MIAO_B
	JMP ADD1_END
MIAOB_RESET1:
	MOV MIAO_B,0
	CMP MIAO_A,5
	JNB MIAOA_RESET1
	INC MIAO_A
	JMP ADD1_END
MIAOA_RESET1:
	MOV MIAO_A,0 
	JMP ADD1_END	
ADD1_END:
	RET
ADD1 ENDP
	
;减一
SUB1	PROC	NEAR
	CMP GLINT_FLAG,0		;时-1
	JZ SHI_SUB1
	CMP GLINT_FLAG,1		;分-1
	JZ FEN_SUB1
	CMP GLINT_FLAG,2		;秒-1
	JZ MIAO_SUB1
SHI_SUB1:					;时
	CMP SHI_B,0
	JNA SHIB_RESET2
	DEC SHI_B
	JMP SUB1_END
SHIB_RESET2:
	MOV SHI_B,3
	CMP SHI_A,0
	JNA SHIA_RESET2
	DEC FEN_A
	JMP SUB1_END
SHIA_RESET2:
	MOV SHI_A,2
	JMP SUB1_END
FEN_SUB1:					;分
	CMP FEN_B,0
	JNA FENB_RESET2
	DEC FEN_B
	JMP SUB1_END
FENB_RESET2:
	MOV FEN_B,9
	CMP FEN_A,0
	JNA FENA_RESET2
	DEC FEN_A
	JMP SUB1_END
FENA_RESET2:
	MOV FEN_A,5
	JMP SUB1_END
MIAO_SUB1:					;秒
	CMP MIAO_B,0
	JNA MIAOB_RESET2
	DEC MIAO_B
	JMP SUB1_END
MIAOB_RESET2:
	MOV MIAO_B,9
	CMP MIAO_A,0
	JNA MIAOA_RESET2
	DEC MIAO_A
	JMP SUB1_END
MIAOA_RESET2:
	MOV MIAO_A,5
	JMP SUB1_END	
SUB1_END:
	RET
SUB1 ENDP
	
;---------定时闹钟-----------;
;定时闹钟闪烁
GLINT_ALARM	PROC	 NEAR
	CMP GLINT_ALARM_FLAG,0		;时闪烁
	JZ SHI_ALARM_GLINT
	CMP GLINT_ALARM_FLAG,1		;分闪烁
	JZ FEN_ALARM_GLINT
	CMP GLINT_ALARM_FLAG,2		;秒闪烁
	JZ MIAO_ALARM_GLINT
SHI_ALARM_GLINT:
	MOV DX,TL_B2	;时灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A2	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_ALARM_END
FEN_ALARM_GLINT:
	MOV DX,TL_B3	;分灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A3	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_ALARM_END
MIAO_ALARM_GLINT:
	MOV DX,TL_B4	;秒灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A4	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_ALARM_END
GLINT_ALARM_END:
	RET
GLINT_ALARM ENDP
	
;定时闹钟加一
ADD1_ALARM	PROC	NEAR
	CMP GLINT_ALARM_FLAG,0		;时+1
	JZ SHI_ALARM_ADD1
	CMP GLINT_ALARM_FLAG,1		;分+1
	JZ FEN_ALARM_ADD1
	CMP GLINT_ALARM_FLAG,2		;秒+1
	JZ MIAO_ALARM_ADD1
SHI_ALARM_ADD1:					;时
	CMP ALARM_SHI_B,4
	JNB SHIB_ALARM_RESET1
	INC ALARM_SHI_B
	JMP ADD1_ALARM_END
SHIB_ALARM_RESET1:
	MOV ALARM_SHI_B,0
	CMP ALARM_SHI_A,2
	JNB SHIA_ALARM_RESET1
	INC ALARM_FEN_A
	JMP ADD1_ALARM_END
SHIA_ALARM_RESET1:
	MOV ALARM_SHI_A,0
	JMP ADD1_ALARM_END
FEN_ALARM_ADD1:					;分
	CMP ALARM_FEN_B,9
	JNB FENB_ALARM_RESET1
	INC ALARM_FEN_B
	JMP ADD1_ALARM_END
FENB_ALARM_RESET1:
	MOV ALARM_FEN_B,0
	CMP ALARM_FEN_A,5
	JNB FENA_ALARM_RESET1
	INC ALARM_FEN_A
	JMP ADD1_ALARM_END
FENA_ALARM_RESET1:
	MOV ALARM_FEN_A,0 
	JMP ADD1_ALARM_END
MIAO_ALARM_ADD1:				;秒
	CMP ALARM_MIAO_B,9
	JNB MIAOB_ALARM_RESET1
	INC ALARM_MIAO_B
	JMP ADD1_ALARM_END
MIAOB_ALARM_RESET1:
	MOV ALARM_MIAO_B,0
	CMP ALARM_MIAO_A,5
	JNB MIAOA_ALARM_RESET1
	INC ALARM_MIAO_A
	JMP ADD1_ALARM_END
MIAOA_ALARM_RESET1:
	MOV ALARM_MIAO_A,0 
	JMP ADD1_ALARM_END	
ADD1_ALARM_END:
	RET
ADD1_ALARM ENDP
	
;定时闹钟减一
SUB1_ALARM	PROC	NEAR
	CMP GLINT_ALARM_FLAG,0		;时-1
	JZ SHI_ALARM_SUB1
	CMP GLINT_ALARM_FLAG,1		;分-1
	JZ FEN_ALARM_SUB1
	CMP GLINT_ALARM_FLAG,2		;秒-1
	JZ MIAO_ALARM_SUB1
SHI_ALARM_SUB1:							;时
	CMP ALARM_SHI_B,0
	JNA SHIB_ALARM_RESET2
	DEC ALARM_SHI_B
	JMP SUB1_ALARM_END
SHIB_ALARM_RESET2:
	MOV ALARM_SHI_B,3
	CMP ALARM_SHI_A,0
	JNA SHIA_ALARM_RESET2
	DEC ALARM_FEN_A
	JMP SUB1_ALARM_END
SHIA_ALARM_RESET2:
	MOV ALARM_SHI_A,2
	JMP SUB1_ALARM_END
FEN_ALARM_SUB1:						;分
	CMP ALARM_FEN_B,0
	JNA FENB_ALARM_RESET2
	DEC ALARM_FEN_B
	JMP SUB1_ALARM_END
FENB_ALARM_RESET2:
	MOV ALARM_FEN_B,9
	CMP ALARM_FEN_A,0
	JNA FENA_ALARM_RESET2
	DEC ALARM_FEN_A
	JMP SUB1_ALARM_END
FENA_ALARM_RESET2:
	MOV ALARM_FEN_A,5
	JMP SUB1_ALARM_END
MIAO_ALARM_SUB1:					;秒
	CMP ALARM_MIAO_B,0
	JNA MIAOB_ALARM_RESET2
	DEC ALARM_MIAO_B
	JMP SUB1_ALARM_END
MIAOB_ALARM_RESET2:
	MOV ALARM_MIAO_B,9
	CMP ALARM_MIAO_A,0
	JNA MIAOA_ALARM_RESET2
	DEC ALARM_MIAO_A
	JMP SUB1_ALARM_END
MIAOA_ALARM_RESET2:
	MOV ALARM_MIAO_A,5
	JMP SUB1_ALARM_END	
SUB1_ALARM_END:
	RET
SUB1_ALARM ENDP
	
;---------计时闹钟------------;
;计时闹钟闪烁
GLINT_COUNTER	PROC	 NEAR
	CMP GLINT_COUNTER_FLAG,0		;时闪烁
	JZ SHI_COUNTER_GLINT
	CMP GLINT_COUNTER_FLAG,1		;分闪烁
	JZ FEN_COUNTER_GLINT
	CMP GLINT_COUNTER_FLAG,2		;秒闪烁
	JZ MIAO_COUNTER_GLINT
SHI_COUNTER_GLINT:
	MOV DX,TL_B2	;时灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A2	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_COUNTER_END
FEN_COUNTER_GLINT:
	MOV DX,TL_B3	;分灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A3	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_COUNTER_END
MIAO_COUNTER_GLINT:
	MOV DX,TL_B4	;秒灭
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	MOV DX,TL_A4	
	MOV AL,0FFH
	OUT DX,AL
	CALL DELAY_L
	JMP GLINT_COUNTER_END
GLINT_COUNTER_END:
	RET
GLINT_COUNTER ENDP
	
;计时闹钟加一
ADD1_COUNTER	PROC	NEAR
	CMP GLINT_COUNTER_FLAG,0		;时+1
	JZ SHI_COUNTER_ADD1
	CMP GLINT_COUNTER_FLAG,1		;分+1
	JZ FEN_COUNTER_ADD1
	CMP GLINT_COUNTER_FLAG,2		;秒+1
	JZ MIAO_COUNTER_ADD1
SHI_COUNTER_ADD1:					;时
	CMP COUNTER_SHI_B,4
	JNB SHIB_COUNTER_RESET1
	INC COUNTER_SHI_B
	JMP ADD1_COUNTER_END
SHIB_COUNTER_RESET1:
	MOV COUNTER_SHI_B,0
	CMP COUNTER_SHI_A,2
	JNB SHIA_COUNTER_RESET1
	INC COUNTER_FEN_A
	JMP ADD1_COUNTER_END
SHIA_COUNTER_RESET1:
	MOV COUNTER_SHI_A,0
	JMP ADD1_COUNTER_END
FEN_COUNTER_ADD1:					;分
	CMP COUNTER_FEN_B,9
	JNB FENB_COUNTER_RESET1
	INC COUNTER_FEN_B
	JMP ADD1_COUNTER_END
FENB_COUNTER_RESET1:
	MOV COUNTER_FEN_B,0
	CMP COUNTER_FEN_A,5
	JNB FENA_COUNTER_RESET1
	INC COUNTER_FEN_A
	JMP ADD1_COUNTER_END
FENA_COUNTER_RESET1:
	MOV COUNTER_FEN_A,0 
	JMP ADD1_COUNTER_END
MIAO_COUNTER_ADD1:					;分
	CMP COUNTER_MIAO_B,9
	JNB MIAOB_COUNTER_RESET1
	INC COUNTER_MIAO_B
	JMP ADD1_COUNTER_END
MIAOB_COUNTER_RESET1:
	MOV COUNTER_MIAO_B,0
	CMP COUNTER_MIAO_A,5
	JNB MIAOA_COUNTER_RESET1
	INC COUNTER_MIAO_A
	JMP ADD1_COUNTER_END
MIAOA_COUNTER_RESET1:
	MOV COUNTER_MIAO_A,0 
	JMP ADD1_COUNTER_END	
ADD1_COUNTER_END:
	RET
ADD1_COUNTER ENDP
	
;计时闹钟减一
SUB1_COUNTER	PROC	NEAR
	CMP GLINT_COUNTER_FLAG,0		;时-1
	JZ SHI_COUNTER_SUB1
	CMP GLINT_COUNTER_FLAG,1		;分-1
	JZ FEN_COUNTER_SUB1
	CMP GLINT_COUNTER_FLAG,2		;秒-1
	JZ MIAO_COUNTER_SUB1
SHI_COUNTER_SUB1:					;时
	CMP COUNTER_SHI_B,0
	JNA SHIB_COUNTER_RESET2
	DEC COUNTER_SHI_B
	JMP SUB1_COUNTER_END
SHIB_COUNTER_RESET2:
	MOV COUNTER_SHI_B,3
	CMP COUNTER_SHI_A,0
	JNA SHIA_COUNTER_RESET2
	DEC COUNTER_FEN_A
	JMP SUB1_COUNTER_END
SHIA_COUNTER_RESET2:
	MOV COUNTER_SHI_A,2
	JMP SUB1_COUNTER_END
FEN_COUNTER_SUB1:					;分
	CMP COUNTER_FEN_B,0
	JNA FENB_COUNTER_RESET2
	DEC COUNTER_FEN_B
	JMP SUB1_COUNTER_END
FENB_COUNTER_RESET2:
	MOV COUNTER_FEN_B,9
	CMP COUNTER_FEN_A,0
	JNA FENA_COUNTER_RESET2
	DEC COUNTER_FEN_A
	JMP SUB1_COUNTER_END
FENA_COUNTER_RESET2:
	MOV COUNTER_FEN_A,5
	JMP SUB1_COUNTER_END
MIAO_COUNTER_SUB1:					;秒
	CMP ALARM_MIAO_B,0
	JNA MIAOB_COUNTER_RESET2
	DEC COUNTER_MIAO_B
	JMP SUB1_COUNTER_END
MIAOB_COUNTER_RESET2:
	MOV COUNTER_MIAO_B,9
	CMP COUNTER_MIAO_A,0
	JNA MIAOA_COUNTER_RESET2
	DEC COUNTER_MIAO_A
	JMP SUB1_COUNTER_END
MIAOA_COUNTER_RESET2:
	MOV COUNTER_MIAO_A,5
	JMP SUB1_COUNTER_END	
SUB1_COUNTER_END:
	RET
SUB1_COUNTER ENDP
	
;----------定时闹钟--------------；
;判断闹钟时间是否到，并鸣叫
ALARM_CLOCK_CALL	PROC 	NEAR
	PUSH DX
	MOV DL,SHI_A
	CMP DL,ALARM_SHI_A			;现在时间是否和闹钟时间相同
	JNZ ALARM_CLOCK_CALL_END
	MOV DL,SHI_B
	CMP DL,ALARM_SHI_B
	JNZ ALARM_CLOCK_CALL_END
	MOV DL,FEN_A
	CMP DL,ALARM_FEN_A
	JNZ ALARM_CLOCK_CALL_END
	MOV DL,FEN_B
	CMP DL,ALARM_FEN_B
	JNZ ALARM_CLOCK_CALL_END
	MOV DL,MIAO_A
	CMP DL,ALARM_MIAO_A
	JNZ ALARM_CLOCK_CALL_END
	MOV DL,MIAO_B
	CMP DL,ALARM_MIAO_B 
	JNZ ALARM_CLOCK_CALL_END
ALARM_CALL:
	MOV DX,PORTB
	MOV AL,01H
	OUT DX,AL
	CALL DELAY_S
ALARM_CLOCK_CALL_END:
	POP DX
	RET
ALARM_CLOCK_CALL ENDP

;改变闹钟时间
ALARM_CLOCK_CHANGE	PROC	NEAR
JUDGE_ALARM:
	CALL DISPLAY_ALARM		;显示闹钟时间
	CALL GLINT_ALARM		;闪烁
	CALL DELAY_L
	CALL JUDGE1S			;修改闹钟的时钟同时时钟继续走
	CALL JUDGE_ALARM_MODIFY_KEY	;再次判断是否按下按键
	CMP AL,MODIFY_FLAG		;闹钟修改键
	JZ MODIFY_ALARM
	CMP AL,ADD1_FLAG		;闹钟加一键
	JZ ADD1_ALARM
	CMP AL,SUB1_FLAG		;闹钟减一键
	JZ SUB1_ALARM
	CMP AL,ENTER_FLAG		;闹钟确定键
	JZ ALARM_CLOCK_CHANGE_END
	JMP JUDGE_ALARM
MODIFY_ALARM:				;改变时-分-秒闪烁的位置
	INC GLINT_ALARM_FLAG
	CMP GLINT_ALARM_FLAG,3
	JNZ GLINT_ALARM_RESET
	MOV GLINT_ALARM_FLAG,0
GLINT_ALARM_RESET:
	CALL GLINT_ALARM
	JMP JUDGE_ALARM
ALARM_CLOCK_CHANGE_END:
	RET
ALARM_CLOCK_CHANGE ENDP

;----------计时闹钟--------------；
;计时闹钟是否为0，并鸣叫
COUNTER_CLOCK_CALL	PROC	NEAR
	CMP COUNTER_SHI_A,0				;倒计时是否为0
	JNZ COUNTER_CLOCK_CALL_END
	CMP COUNTER_SHI_B,0
	JNZ COUNTER_CLOCK_CALL_END
	CMP COUNTER_FEN_A,0
	JNZ COUNTER_CLOCK_CALL_END
	CMP COUNTER_FEN_B,0
	JNZ COUNTER_CLOCK_CALL_END
	CMP COUNTER_MIAO_A,0
	JNZ COUNTER_CLOCK_CALL_END
	CMP COUNTER_MIAO_B,0
	JNZ COUNTER_CLOCK_CALL_END
COUNTER_CALL:
	MOV DX,PORTB
	MOV AL,01H
	OUT DX,AL
	CALL DELAY_S
	MOV COUNTER_FLAG,0
COUNTER_CLOCK_CALL_END:
	RET
COUNTER_CLOCK_CALL ENDP
	

;改变计时闹钟的值
COUNTER_CLOCK_CHANGE	PROC	NEAR
JUDGE_COUNTER:
	CALL DISPLAY_COUNTER	;显示计时闹钟倒计时时间
	CALL GLINT_COUNTER		;闪烁
	CALL DELAY_L
	CALL JUDGE1S			;修改闹钟的时钟同时时钟继续走
	
	CALL JUDGE_COUNTER_MODIFY_KEY
	
	CMP AL,MODIFY_FLAG		;闹钟修改键
	JZ MODIFY_COUNTER
	CMP AL,ADD1_FLAG		;闹钟加一键
	JZ ADD1_COUNTER
	CMP AL,SUB1_FLAG		;闹钟减一键
	JZ SUB1_COUNTER
	CMP AL,ENTER_FLAG		;闹钟确定键
	JZ COUNTER_CLOCK_CHANGE_END
	JMP JUDGE_COUNTER
MODIFY_COUNTER:				;改变时-分-秒闪烁的位置
	INC GLINT_COUNTER_FLAG
	CMP GLINT_COUNTER_FLAG,3
	JNZ GLINT_COUNTER_RESET
	MOV GLINT_COUNTER_FLAG,0
GLINT_COUNTER_RESET:
	CALL GLINT_COUNTER
	JMP JUDGE_COUNTER
COUNTER_CLOCK_CHANGE_END:
	MOV COUNTER_FLAG,1
	RET
COUNTER_CLOCK_CHANGE ENDP

;短延时                                                                                                                                                                                                                   
DELAY_S	PROC   NEAR
	PUSH CX
	PUSH AX
	MOV CX,10			
LP_S:	MOV AL,5
LP1_S:	DEC AL
	CMP AL,0
	JNE LP1_S
	LOOP LP_s
QUIT_S: POP AX
	POP CX
	RET
DELAY_S ENDP 

;长延时                                                                                                                                                                                                                       
DELAY_L	PROC   NEAR
	PUSH CX
	PUSH AX
	MOV CX,50		
LP_L:	MOV AL,10
LP1_L:	DEC AL
	CMP AL,0
	JNE LP1_L
	LOOP LP_L	
QUIT_L: POP AX
	POP CX
	RET
DELAY_L ENDP 	
	
CODE ENDS	
   END	START
