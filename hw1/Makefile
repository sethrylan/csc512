CFLAGS= -Wall -ggdb

all: calc calc2

calc: calc.y calc.l
	bison -d --verbose calc.y
	flex -o calc.yy.c calc.l
	gcc calc.yy.c calc.tab.c -o calc -lfl	

calc2: scan.c calc.y
	bison -d --verbose calc.y
	gcc scan.c calc.tab.c -o calc2 -lfl

clean:
	rm -f calc calc2
	rm -f lex.yy.c calc.yy.c
	rm -f calc.tab.c calc.tab.h
	rm -f calc.output calc2.output

