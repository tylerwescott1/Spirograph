; *****************************************************************
;  Name: Tyler Wescott
;  NSHE_ID: 5006959108
;  Section: 1004
;  Assignment: 10
;  Description: Take in command line args and draw an output to openGL 

; -----
;  Function: getRadii
;	Gets, checks, converts, and returns command line arguments.

;  Function: drawSpiro()
;	Plots spirograph formulas

; ---------------------------------------------------------

;	MACROS (if any) GO HERE

; ---------------------------------------------------------

section  .data

; -----
;  Define standard constants.

TRUE		equ	1
FALSE		equ	0

SUCCESS		equ	0			; successful operation
NOSUCCESS	equ	1

STDIN		equ	0			; standard input
STDOUT		equ	1			; standard output
STDERR		equ	2			; standard error

SYS_read	equ	0			; code for read
SYS_write	equ	1			; code for write
SYS_open	equ	2			; code for file open
SYS_close	equ	3			; code for file close
SYS_fork	equ	57			; code for fork
SYS_exit	equ	60			; code for terminate
SYS_creat	equ	85			; code for file open/create
SYS_time	equ	201			; code for get time

LF		equ	10
SPACE		equ	" "
NULL		equ	0
ESC		equ	27

; -----
;  OpenGL constants

GL_COLOR_BUFFER_BIT	equ	16384
GL_POINTS		equ	0
GL_POLYGON		equ	9
GL_PROJECTION		equ	5889

GLUT_RGB		equ	0
GLUT_SINGLE		equ	0

; -----
;  Define program specific constants.

R1_MIN		equ	0
R1_MAX		equ	250			; 250(10) = 1054(6)

R2_MIN		equ	1			; 1(10) = 1(13)
R2_MAX		equ	250			; 250(10) = 1054(6)

OP_MIN		equ	1			; 1(10) = 1(13)
OP_MAX		equ	250			; 250(10) = 1054(6)

SP_MIN		equ	1			; 1(10) = 1(13)
SP_MAX		equ	100			; 100(10) = 244(6)

X_OFFSET	equ	320
Y_OFFSET	equ	240

; -----
;  Variables for getRadii procedure.

errUsage	db	"Usage:  ./spiro -r1 <senary number> "
		db	"-r2 <senary number> -op <senary number> "
		db	"-sp <senary number> -cl <b/g/r/y/p/w>"
		db	LF, NULL
errBadCL	db	"Error, invalid or incomplete command line arguments."
		db	LF, NULL

errR1sp		db	"Error, radius 1 specifier incorrect."
		db	LF, NULL
errR1value	db	"Error, radius 1 value must be between 0 and 1054(6)."
		db	LF, NULL

errR2sp		db	"Error, radius 2 specifier incorrect."
		db	LF, NULL
errR2value	db	"Error, radius 2 value must be between 1 and 1054(6)."
		db	LF, NULL

errOPsp		db	"Error, offset position specifier incorrect."
		db	LF, NULL
errOPvalue	db	"Error, offset position value must be between 1 and 1054(6)."
		db	LF, NULL

errSPsp		db	"Error, speed specifier incorrect."
		db	LF, NULL
errSPvalue	db	"Error, speed value must be between 1 and 244(6)."
		db	LF, NULL

errCLsp		db	"Error, color specifier incorrect."
		db	LF, NULL
errCLvalue	db	"Error, color value must be b, g, r, p, or w. "
		db	LF, NULL

ddSix 		dd 	6

; -----
;  Variables for spirograph routine.

fltOne		dd	1.0
fltZero		dd	0.0
fltTmp1		dd	0.0
fltTmp2		dd	0.0

t		dd	0.0			; loop variablejmp colorSet
s		dd	1.0			; phase variable
tStep		dd	0.005			; t step
sStep		dd	0.0			; s step
x		dd	0			; current x
y		dd	0			; current y

r1		dd	0.0			; radius 1 (float)
r2		dd	0.0			; radius 2 (float)
ofp		dd	0.0			; offset position (float)
radii		dd	0.0			; tmp location for (radius1+radius2)

scale		dd	5000.0			; speed scale
limit		dd	360.0			; for loop limit
iterations	dd	0			; set to 360.0/tStep

red		db	0			; 0-255
green		db	0			; 0-255
blue		db	0			; 0-255

; ------------------------------------------------------------

section  .text

; -----
;  External references for openGL routines.

extern	glutInit, glutInitDisplayMode, glutInitWindowSize, glutInitWindowPosition
extern	glutCreateWindow, glutMainLoop
extern	glutDisplayFunc, glutIdleFunc, glutReshapeFunc, glutKeyboardFunc
extern	glutSwapBuffers, gluPerspective, glutPostRedisplay
extern	glClearColor, glClearDepth, glDepthFunc, glEnable, glShadeModel
extern	glClear, glLoadIdentity, glMatrixMode, glViewport
extern	glTranslatef, glRotatef, glBegin, glEnd, glVertex3f, glColor3f
extern	glVertex2f, glVertex2i, glColor3ub, glOrtho, glFlush, glVertex2d

extern	cosf, sinf

; ******************************************************************
;  Function getRadii()
;	Gets radius 1, radius 2, offset positionm and rottaion
;	speedvalues and color code letter from the command line.

;	Performs error checking, converts ASCII/senary string
;	to integer.  Required command line format (fixed order):
;	  "-r1 <senary numberl> -r2 <senary number> -op <senary number> 
;			-sp <senary number> -cl <color>"

; HLL
;	stat = getRadii(argc, argv, &radius1, &radius2, &offPos,
;						&speed, &color);

; -----
;  Arguments:
;	- ARGC
;	- ARGV
;	- radius 1, double-word, address
;	- radius 2, double-word, address
;	- offset Position, double-word, address
;	- speed, double-word, address
;	- circle color, byte, address

;read and check the command line arguments (r1, r2, op, sp, and cl)
;read each arg, convert ASCII/Tridecimal string to int, verify ranges
;range for r1 is 0 and 1054(base 6) inclusive
;range for sp is 1 to 244(base 6)
;allowed colors values (cl) are r, g, b, p, y, w. Lowercase only
;if all args are correct, return the values (via reference) and return to main with TRUE
;if there are any errors, display appropriate error message and return to main with FALSE

;	YOUR CODE GOES HERE
global getRadii
getRadii:
	;rsi = argv (address)
	;rdi = ARGC
	;rdx = radius1 (address)
	;rcx = radius2 (address)
	;r8 = offPos (address)
	;r9 = speed (address)
	;arg7 = color (address) 	rbp + 16

	push rbp
	mov rbp, rsp
	push rbx
	push r11
	push r12
	push r13
	push r14
	push r15

	mov rax, 0		;holds bytes of arguments to compare
	mov rbx, 0		;counter
	mov r11, rdx	;holds rdx
	mov r12, 0		;stores current argument
	mov r13, 0		;temp var used in multiple calculations
	mov r14, 0		;counter to move in proper byte
	mov r15, 0		;temp var used in multiple calculations


	;compare argument count with 1 for improper usage
	cmp rdi, 1
	je argCountIsOne

	cmp rdi, 11
	jne improperArgCount	;if arg count isnt 1 and not 11, jump to error handle

	;checking arg 2 here (-r1)
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;check if 1st char is the same
	mov r14, 0
	mov al, byte[r12 + r14]
	mov r13b, '-'
	inc r14
	cmp al, r13b
	jne r1CharError
	mov al, byte[r12 + r14]	;2nd char
	mov r13b, 'r'
	inc r14
	cmp al, r13b
	jne r1CharError
	mov al, byte[r12 + r14]	;3rc char
	mov r13b, '1'
	inc r14
	cmp al, r13b
	jne r1CharError
	mov al, byte[r12 + r14] ;too many chars
	cmp al, NULL
	jne r1CharError
	;if all chars match, continue

	;next, we check the range of arg 3
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;convert it to base 10
	mov r14, 0
	mov r15, 0

	startProcessARG3:
	mov rax, 0
	mov r13, 0

	movzx eax, byte[r12 + r14]
	inc r14						;if error check necessary, it go here from prev assignment
	
	;error check necessary.
	cmp eax, '0'
	jb r1RangeError
	cmp eax, '5'
	ja r1RangeError

	movzx r13d, byte[r12 + r14]
	cmp r13d, 0
	je endConvertLoopARG3
	cmp eax, 32
	je startProcessARG3
	sub rax, 30h
	add r15, rax
	mov rax, r15
	mul dword[ddSix]
	mov r15, 0
	mov r15, rax
	jmp startProcessARG3

	endConvertLoopARG3:
	sub rax, 30h
	add r15, rax	;r15 has r1 as a decimal value

	;check if out of range min
	cmp r15, R1_MIN
	jb r1RangeError
	;check if out of range max
	cmp r15, R1_MAX
	ja r1RangeError

	;otherwise, arg 3 is fine and in range
	mov rdx, r11
	mov dword[rdx], r15d

	;check arg 4
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;same process as earlier
	;check if 1st char is the same
	mov r14, 0
	mov al, byte[r12 + r14]
	mov r13b, '-'
	inc r14
	cmp al, r13b
	jne r2CharError
	mov al, byte[r12 + r14]	;2nd char
	mov r13b, 'r'
	inc r14
	cmp al, r13b
	jne r2CharError
	mov al, byte[r12 + r14]	;3rc char
	mov r13b, '2'				;except we check for a 2 here instead
	inc r14
	cmp al, r13b
	jne r2CharError
	mov al, byte[r12 + r14] ;too many chars
	cmp al, NULL
	jne r2CharError
	;if all chars match, continue

	;check arg 5
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;convert it to base 10
	mov r14, 0
	mov r15, 0

	startProcessARG5:
	mov rax, 0
	mov r13, 0

	movzx eax, byte[r12 + r14]
	inc r14						;if error check necessary, it go here from prev assignment
	
	;error check necessary.
	cmp eax, '0'
	jb r2RangeError
	cmp eax, '5'
	ja r2RangeError

	movzx r13d, byte[r12 + r14]
	cmp r13d, 0
	je endConvertLoopARG5
	cmp eax, 32
	je startProcessARG5
	sub rax, 30h
	add r15, rax
	mov rax, r15
	mul dword[ddSix]
	mov r15, 0
	mov r15, rax
	jmp startProcessARG5

	endConvertLoopARG5:
	sub rax, 30h
	add r15, rax	;r15 has r2 as a decimal value

	;check if out of range min
	cmp r15, R2_MIN
	jb r2RangeError
	;check if out of range max
	cmp r15, R2_MAX
	ja r2RangeError

	;otherwise, arg 5 is fine and in range
	mov dword[ecx], r15d

	;check arg 6
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;same process as earlier
	;check if 1st char is the same
	mov r14, 0
	mov al, byte[r12 + r14]
	mov r15, 0
	mov r15b, '-'
	inc r14
	cmp al, r15b
	jne opCharError
	mov al, byte[r12 + r14]	;2nd char
	mov r15b, 'o'			;'o'
	inc r14
	cmp al, r15b
	jne opCharError
	mov al, byte[r12 + r14]	;3rc char
	mov r15b, 'p'			;'p'
	inc r14
	cmp al, r15b
	jne opCharError
	mov al, byte[r12 + r14] ;too many chars
	cmp al, NULL
	jne opCharError
	;if all chars match, continue

	;check arg 7
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;convert it to base 10
	mov r14, 0
	mov r15, 0

	startProcessARG7:
	mov rax, 0
	mov r13, 0

	movzx eax, byte[r12 + r14]
	inc r14						;if error check necessary, it go here from prev assignment
	
	;error check necessary.
	cmp eax, '0'
	jb opRangeError
	cmp eax, '5'
	ja opRangeError

	movzx r13d, byte[r12 + r14]
	cmp r13d, 0
	je endConvertLoopARG7
	cmp eax, 32
	je startProcessARG7
	sub rax, 30h
	add r15, rax
	mov rax, r15
	mul dword[ddSix]
	mov r15, 0
	mov r15, rax
	jmp startProcessARG7

	endConvertLoopARG7:
	sub rax, 30h
	add r15, rax	;r15 has op as a decimal value

	;check if out of range min
	cmp r15, OP_MIN
	jb opRangeError
	;check if out of range max
	cmp r15, OP_MAX
	ja opRangeError

	;otherwise, arg 7 is fine and in range
	mov dword[r8], r15d 

	;check arg 8
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;same process as earlier
	;check if 1st char is the same
	mov r14, 0
	mov al, byte[r12 + r14]
	mov r15, 0
	mov r15b, '-'
	inc r14
	cmp al, r15b
	jne spCharError
	mov al, byte[r12 + r14]	;2nd char
	mov r15b, 's'			;'s'
	inc r14
	cmp al, r15b
	jne spCharError
	mov al, byte[r12 + r14]	;3rc char
	mov r15b, 'p'			;'p'
	inc r14
	cmp al, r15b
	jne spCharError
	mov al, byte[r12 + r14] ;too many chars
	cmp al, NULL
	jne spCharError
	;if all chars match, continue

	;check arg 9
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;convert it to base 10
	mov r14, 0
	mov r15, 0

	startProcessARG9:
	mov rax, 0
	mov r13, 0

	movzx eax, byte[r12 + r14]
	inc r14						;if error check necessary, it go here from prev assignment
	
	;error check necessary.
	cmp eax, '0'
	jb spRangeError
	cmp eax, '5'
	ja spRangeError

	movzx r13d, byte[r12 + r14]
	cmp r13d, 0
	je endConvertLoopARG9
	cmp eax, 32
	je startProcessARG9
	sub rax, 30h
	add r15, rax
	mov rax, r15
	mul dword[ddSix]
	mov r15, 0
	mov r15, rax
	jmp startProcessARG9

	endConvertLoopARG9:
	sub rax, 30h
	add r15, rax	;r15 has sp as a decimal value

	;check if out of range min
	cmp r15, SP_MIN
	jb spRangeError
	;check if out of range max
	cmp r15, SP_MAX
	ja spRangeError

	;otherwise, arg 7 is fine and in range
	mov dword[r9], r15d 

	;check arg 10
	inc rbx
	mov r12, qword[rsi + rbx * 8]

	;same process as earlier
	;check if 1st char is the same
	mov r14, 0
	mov al, byte[r12 + r14]
	mov r15, 0
	mov r15b, '-'
	inc r14
	cmp al, r15b
	jne clCharError
	mov al, byte[r12 + r14]	;2nd char
	mov r15b, 'c'			;'c'
	inc r14
	cmp al, r15b
	jne clCharError
	mov al, byte[r12 + r14]	;3rc char
	mov r15b, 'l'			;'l'
	inc r14
	cmp al, r15b
	jne clCharError
	mov al, byte[r12 + r14] ;too many chars
	cmp al, NULL
	jne clCharError
	;if all chars match, continue

	;check arg 11
	inc rbx
	mov r12, qword[rsi + rbx * 8]
	mov r13, 0
	mov r13b, byte[r12]

	;check if the char is right
	mov rax, 0
	mov al, 'b'	;'b'
	cmp al, r13b
	je setclColor

	mov rax, 0
	mov al, 'g'	;'g'
	cmp al, r13b
	je setclColor

	mov rax, 0
	mov al, 'r'	;'r'
	cmp al, r13b
	je setclColor

	mov rax, 0
	mov al, 'y'	;'y'
	cmp al, r13b
	je setclColor

	mov rax, 0
	mov al, 'p'	;'p'
	cmp al, r13b
	je setclColor

	mov rax, 0
	mov al, 'w'	;'w'
	cmp al, r13b
	je setclColor

	;if arg 11 wasnt a proper letter for a color
	jmp clColorError

	setclColor:
	mov r12, qword[rbp + 16]
	mov byte[r12], al

	;char is right for arg 11 and all tests passed
	mov rax, 0
	mov eax, TRUE
	jmp endFunction

	argCountIsOne:
	mov rdi, errUsage
	call printString
	mov rax, FALSE
	jmp endFunction

	improperArgCount:
	mov rdi, errBadCL
	call printString
	mov rax, FALSE
	jmp endFunction

	r1CharError:
	mov rdi, errR1sp
	call printString
	mov rax, FALSE
	jmp endFunction

	r1RangeError:
	mov rdi, errR1value
	call printString
	mov rax, FALSE
	jmp endFunction

	r2CharError:
	mov rdi, errR2sp
	call printString
	mov rax, FALSE
	jmp endFunction

	r2RangeError:
	mov rdi, errR2value
	call printString
	mov rax, FALSE
	jmp endFunction

	opCharError:
	mov rdi, errOPsp
	call printString
	mov rax, FALSE
	jmp endFunction

	opRangeError:
	mov rdi, errOPvalue
	call printString
	mov rax, FALSE
	jmp endFunction

	spCharError:
	mov rdi, errSPsp
	call printString
	mov rax, FALSE
	jmp endFunction

	spRangeError:
	mov rdi, errSPvalue
	call printString
	mov rax, FALSE
	jmp endFunction

	clCharError:
	mov rdi, errCLsp
	call printString
	mov rax, FALSE
	jmp endFunction

	clColorError:
	mov rdi, errCLvalue
	call printString
	mov rax, FALSE
	jmp endFunction
	
	endFunction:

	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	mov rsp, rbp
	pop rbp

	ret



; ******************************************************************
;  Spirograph Plotting Function.

; -----
;  Color Code Conversion:
;	'r' -> red=255, green=0, blue=0
;	'g' -> red=0, green=255, blue=0
;	'b' -> red=0, green=0, blue=255
;	'p' -> red=255, green=0, blue=255
;	'y' -> red=255 green=255, blue=0
;	'w' -> red=255, green=255, blue=255
;  Note, set color before plot loop.

; -----
;  The loop is from 0.0 to 360.0 by tStep, can calculate
;  the number if iterations via:  iterations = 360.0 / tStep
;  This eliminates needing a float compare (a hassle).

; -----
;  Basic flow:
;	Set openGL drawing initializations
;	Loop initializations
;		Set draw color (i.e., glColor3ub)
;		Convert integer values to float for calculations
;		set 'sStep' variable
;		set 'iterations' variable
;	Plot the following spirograph equations:
;	     for (t=0.0; t<360.0; t+=step) {
;	         radii = (r1+r2)
;	         x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
;	         y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))
;	         t += tStep
;	         plot point (x, y)
;	     }
;	Close openGL plotting (i.e., glEnd and glFlush)
;	Update s for next call (s += sStep)
;	Ensure openGL knows to call again (i.e., glutPostRedisplay)

; -----
;  The animation is accomplished by plotting a static
;	image, exiting the routine, and replotting a new
;	slightly different image.  The 's' variable controls
;	the phase or animation.

; -----
;  Global variables accessed
;	There are defined and set in the main, accessed herein by
;	name as per the below declarations.

common	radius1		1:4		; radius 1, dword, integer value
common	radius2		1:4		; radius 2, dword, integer value
common	offPos		1:4		; offset position, dword, integer value
common	speed		1:4		; rortation speed, dword, integer value
common	color		1:1		; color code letter, byte, ASCII value

global drawSpiro
drawSpiro:
	push	r12

; -----
;  Prepare for drawing
	; glClear(GL_COLOR_BUFFER_BIT);
	mov	rdi, GL_COLOR_BUFFER_BIT
	call	glClear

	; glBegin();
	mov	rdi, GL_POINTS
	call	glBegin

; -----
;  Set draw color(r,g,b)
;	Convert color letter to color values
;	Note, only legal color letters should be
;		passed to this procedure
;	Note, color values should be store in local
;		variables red, green, and blue

;	YOUR CODE GOES HERE
mov r12, 0
movzx r12, byte[color]

;	'r' -> red=255, green=0, blue=0
;	'g' -> red=0, green=255, blue=0
;	'b' -> red=0, green=0, blue=255
;	'p' -> red=255, green=0, blue=255
;	'y' -> red=255 green=255, blue=0
;	'w' -> red=255, green=255, blue=255

cmp r12, 'r'
je setColorRed

cmp r12, 'g'
je setColorGreen

cmp r12, 'b'
je setColorBlue

cmp r12, 'p'
je setColorPurple

cmp r12, 'y'
je setColorYellow

cmp r12, 'w'
je setColorWhite

jmp endDrawSpiro

setColorRed:
mov dword[red], 255
jmp colorSet

setColorGreen:
mov dword[green], 255
jmp colorSet

setColorBlue:
mov dword[blue], 255
jmp colorSet

setColorPurple:
mov dword[red], 255
mov dword[blue], 255
jmp colorSet

setColorYellow:
mov dword[red], 255
mov dword[green], 255
jmp colorSet

setColorWhite:
mov dword[red], 255
mov dword[green], 255
mov dword[blue], 255
jmp colorSet

colorSet:	;color has been set, continue.
mov edi, dword[red]
mov esi, dword[green]
mov edx, dword[blue]
call glColor3ub

; -----
;  Loop initializations and main plotting loop

;	YOUR CODE GOES HERE

;convert radius1, radius2 offPos from int to float

cvtsi2ss xmm0, dword[radius1]
movss dword[r1], xmm0

cvtsi2ss xmm0, dword[radius2]
movss dword[r2], xmm0

cvtsi2ss xmm0, dword[offPos]
movss dword[ofp], xmm0

;		set 'sStep' variable
cvtsi2ss xmm0, dword[speed]
divss xmm0, dword[scale]
movss dword[sStep], xmm0

;		set 'iterations' variable
cvtsi2ss xmm0, dword[limit]
divss xmm0, dword[tStep]
movss dword[iterations], xmm0


;	Plot the following spirograph equations:
;	     for (t=0.0; t<360.0; t+=step) {
;	         radii = (r1+r2)
;	         x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
;	         y = (radii * sin(t)) + (offPos * sin(radii * ((t+s)/r2)))
;	         t += tStep
;	         plot point (x, y)
;	     }

movss xmm0, dword[fltZero]
movss dword[t], xmm0	;t = 0.0

startForLoop:
movss xmm1, dword[t]
ucomiss xmm1, dword[limit]	;compare t < 360.0
jae endForLoop				;if t >= 360.0, end for loop
;otherwise, continue for loop
;x calculation
movss xmm0, dword[r1]
addss xmm0, dword[r2]
movss dword[radii], xmm0
;(t+s)
movss xmm0, dword[t]
addss xmm0, dword[s]
; ((t+s)/r2)
divss xmm0, dword[r2]
;(radii * ((t+s)/r2))
mulss xmm0, dword[radii]
;cos(radii * ((t+s)/r2))
call cosf
;(offPos * cos(radii * ((t+s)/r2)))
mulss xmm0, dword[ofp]
;store result of this in a temp var
movss dword[fltTmp1], xmm0
;cos(t)
movss xmm0, dword[t]
call cosf
;(radii * cos(t))
mulss xmm0, dword[radii]
;(radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
addss xmm0, dword[fltTmp1]
;x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
movss dword[x], xmm0

;y calculation
movss xmm0, dword[r1]
addss xmm0, dword[r2]
movss dword[radii], xmm0
;(t+s)
movss xmm0, dword[t]
addss xmm0, dword[s]
; ((t+s)/r2)
divss xmm0, dword[r2]
;(radii * ((t+s)/r2))
mulss xmm0, dword[radii]
;cos(radii * ((t+s)/r2))
call sinf
;(offPos * sin(radii * ((t+s)/r2)))
mulss xmm0, dword[ofp]
;store result of this in a temp var
movss dword[fltTmp1], xmm0
;cos(t)
movss xmm0, dword[t]
call sinf
;(radii * sin(t))
mulss xmm0, dword[radii]
;(radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
addss xmm0, dword[fltTmp1]
;x = (radii * cos(t)) + (offPos * cos(radii * ((t+s)/r2)))
movss dword[y], xmm0

;t += tStep
movss xmm0, dword[t]
addss xmm0, dword[tStep]
movss dword[t], xmm0

;plot point (x, y)
movss xmm0, dword[x]
movss xmm1, dword[y]
call glVertex2f

jmp startForLoop
endForLoop:

; -----
;  Plotting done.

	call	glEnd
	call	glFlush

; -----
;  Update s for next call.

;	YOUR CODE GOES HERE
;Update s for next call (s += sStep)
movss xmm0, dword[s]
addss xmm0, dword[sStep]
movss dword[s], xmm0

; -----
;  Ensure openGL knows to call again

	call	glutPostRedisplay

	endDrawSpiro:

	pop	r12

	ret

; ******************************************************************
;  Generic function to display a string to the screen.
;  String must be NULL terminated.

;  Algorithm:
;	Count characters in string (excluding NULL)
;	Use syscall to output characters

;  Arguments:
;	- address, string
;  Returns:
;	nothing

global	printString
printString:

; -----
;  Count characters in string.

	mov	rbx, rdi			; str addr
	mov	rdx, 0
strCountLoop:
	cmp	byte [rbx], NULL
	je	strCountDone
	inc	rbx
	inc	rdx
	jmp	strCountLoop
strCountDone:

	cmp	rdx, 0
	je	prtDone

; -----
;  Call OS to output string.

	mov	rax, SYS_write			; system code for write()
	mov	rsi, rdi			; address of characters to write
	mov	rdi, STDOUT			; file descriptor for standard in
						; EDX=count to write, set above
	syscall					; system call

; -----
;  String printed, return to calling routine.

prtDone:
	ret

; ******************************************************************

