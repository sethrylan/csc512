CFLAGS= -Wall -g

all: calc 

calc: calc.y calc.1
	bison -d --verbose calc.y
	flex -o calc.yy.c calc.1
	gcc calc.yy.c calc.tab.c -o calc	

calc2: scan.c calc2.y
	bison -d --verbose calc2.y
	gcc scan.c calc2.tab.c -o calc2

clean:
	rm -f calc calc2
	rm -f lex.yy.c calc.yy.c calc2.yy.c
	rm -f calc.tab.c calc.tab.h calc2.tab.c calc2.tab.h
	rm -f calc.output calc2.output

