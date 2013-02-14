default: c-backend

c-backend:
	bison -y -d calc3.y
	flex calc3.l
	gcc -c y.tab.c lex.yy.c
	gcc y.tab.o lex.yy.o calc3c.c -o calc3c

clean:
	@$(RM) calc3c lex.yy.* y.tab.*

all: c-backend	
