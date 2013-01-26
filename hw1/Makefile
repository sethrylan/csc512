CFLAGS= -Wall -ggdb

all: calc calc2 pseudo

pseudo: pseudo.tab.c pseudo.yy.c
	gcc -o pseudo pseudo.tab.c

pseudo.tab.c: pseudo.y pseudo.yy.c
	bison --verbose pseudo.y

pseudo.yy.c: pseudo.l pseudo.tab.h
	flex -o pseudo.yy.c pseudo.l

pseudo.tab.h: pseudo.y
	bison -d --verbose pseudo.y

calc: calc.y calc.l
	bison -d --verbose calc.y
	flex -o calc.yy.c calc.l
	gcc calc.yy.c calc.tab.c -o calc -lfl	

calc2: scan.c calc.y
	bison -d --verbose calc.y
	gcc scan.c calc.tab.c -o calc2 -lfl

clean:
	rm -f calc calc2 pseudo
	rm -f *.yy.c 
	rm -f *.tab.* 
	rm -f *.output

