CFLAGS= -Wall -ggdb --pedantic
PROJDIRS := .

all: calc3

calc3: compiler.c calc3.h calc3.y calc3.l
	@bison -d --verbose calc3.y
	@flex -o calc3.yy.c calc3.l
	@gcc calc3.yy.c calc3.tab.c -o calc3 -lfl

clean:
	@$(RM) -f calc
	@$(RM) -f *.yy.c 
	@$(RM) -f *.tab.* 

