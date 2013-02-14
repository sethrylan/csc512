default: c-backend

c-backend:
	@bison -y -d calc3.y
	@flex calc3.l
	@gcc -c y.tab.c lex.yy.c
	@gcc y.tab.o lex.yy.o calc3c.c -o calc3c

clean:
	@$(RM) calc3c lex.yy.* y.tab.*
	@$(RM) output*

test: c-backend
	@./calc3c < input1 > output1	
	@diff output1 expected1
	@./calc3c < input2 > output2
	@diff output2 expected2
	@./calc3c < input3 > output3
	@diff output3 expected3

rmbakfiles:
	@$(RM) -f ./*~

all: c-backend	
