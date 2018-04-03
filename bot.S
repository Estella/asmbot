#include <asm/unistd.h>

#define AF_INET		2
#define SOCK_STREAM	1
#define SYS_SOCKET	1
#define SYS_CONNECT	3

/*

#define IRCD_ADDRESS	0x520586c2		// amsterdam.nl.eu.undernet.org (194.134.5.82)
#define IRCD_ADDRESS	0x63879fc3		// oslo.no.eu
#define IRCD_ADDRESS	((54) | (221 << 8) | (207 << 16) | (100 << 24)) //irc.freenet.org (54.221.207.100)

*/
#define IRCD_ADDRESS	((195) | (148 << 8) | (124 << 16) | (79 << 24)) //rajaniemi.freenode.net (195.148.124.79)

#define Sock		%esi
#define Pingone		%ebp

.global _start
_start:
	enter	$1000,$0

	xorl	%ebp,%ebp		// Pingone

	push	%ebp			// 0
	incl	%ebp
	push	%ebp			// SOCK_STREAM = 1
	movl	%ebp,%ebx		// SYS_SOCKET = 1
	incl	%ebp
	push	%ebp			// AF_INET = 2
	movl	%esp,%ecx
	push	$__NR_socketcall
	popl	%eax
	int	$0x80
	movl	%eax,Sock

	push	$IRCD_ADDRESS
	push	$0x0b1a0002		// port + AF_INET
	movl	%esp,%eax		// struct sockaddr_in

	push	$16
	push	%eax
	push	Sock
	movl	%esp,%ecx		// socketcall args

	push	$SYS_CONNECT
	popl	%ebx
	push	$__NR_socketcall
	popl	%eax
	int	$0x80

	movl	$Usernick,%ecx
	.byte	0x6a, UsernickLength	// 2-byte `pushl $UsernickLength'

writestuff:
	popl	%edx
	movl	Sock,%ebx
	push	$__NR_write
	popl	%eax
	int	$0x80

inputstart:
	xorl	%edi,%edi

inputloop:
	push	$1
	popl	%edx
	leal	(%esp,%edi),%ecx
	movl	Sock,%ebx
	push	$__NR_read
	popl	%eax
	int	$0x80

	testl	%eax,%eax
	jnz	noexit

	incl	%eax
	int	$0x80

noexit:

	cmpb	$13,(%esp,%edi)
	je	inputloop

	cmpb	$10,(%esp,%edi)
	je	parseline

	incl	%edi
	jmp	inputloop

parseline:
	xorl	%ebx,%ebx

pingloop:
	cmpl	%ebx,%edi
	je	inputstart

	movb	Ping1(%ebx),%al
	testb	%al,%al
	jz	pingmatch

	cmpb	(%esp,%ebx),%al
	je	pingnext

	addb	$0x20,%al
	cmpb	(%esp,%ebx),%al
	jne	inputstart

pingnext:
	incl	%ebx
	jmp	pingloop

pingmatch:
	movb	$'O',1(%esp)

	leal	1(%edi),%edx
	movl	%esp,%ecx
	movl	Sock,%ebx
	push	$__NR_write
	popl	%eax
	int	$0x80

	testl	%ebp,%ebp		// Pingone
	jz	inputstart

	xorl	%ebp,%ebp

	movl	$Join,%ecx
	.byte	0x6a, JoinLength	// 2-byte `pushl $JoinLength'
	jmp	writestuff

Usernick:
	.ascii	"USER asmbot1 x x :Asmbot\nNICK asmbot1\n"
.equ	UsernickLength, (.-Usernick)

Join:
	.ascii	"JOIN #amdx\n"
.equ	JoinLength, (.-Join)

Ping1:
	.ascii	"PING \0"

