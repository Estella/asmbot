
CC =		gcc

ASMBOT =	asmbot

.PHONY:		all clean

all:		asmbot

clean:
		rm -f $(ASMBOT) bot_s.o

$(ASMBOT):	bot_s.o
		$(CC) -s -m32 -o $(ASMBOT) bot_s.o -nostdlib
		objcopy -R .note -R .comment -R .data -R .bss $(ASMBOT)

bot_s.o:	bot.S
		gcc -m32 -c bot.S -o bot_s.o

