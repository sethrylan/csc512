CFLAGS= -Wall -ggdb
PROJDIRS := .
TESTDIR := ./test
TESTFILES := $(shell find $(TESTDIR) -type f -name "*.input")

all: calc calc2 pseudo

pseudo: pseudo.tab.c pseudo.yy.c
	@gcc -o pseudo pseudo.tab.c

pseudo.tab.c: pseudo.y pseudo.yy.c
	@bison --verbose pseudo.y

pseudo.yy.c: pseudo.l pseudo.tab.h
	@flex -o pseudo.yy.c pseudo.l

pseudo.tab.h: pseudo.y
	@bison -d --verbose pseudo.y

calc: calc.y calc.l
	@bison -d --verbose calc.y
	@flex -o calc.yy.c calc.l
	@gcc calc.yy.c calc.tab.c -o calc -lfl	

calc2: scan.c calc.y
	@bison -d --verbose calc.y
	@gcc scan.c calc.tab.c -o calc2 -lfl

clean:
	@$(RM) -f calc calc2 pseudo
	@$(RM) -f *.yy.c 
	@$(RM) -f *.tab.* 
	@$(RM) -f *.output
	@$(RM) -f test/*.output

test: all testfiles
	-@rc=0; count=0; \
	for input_file in $(TESTFILES); do \
		testname=`basename $$input_file .input`; \
		output_file=$(TESTDIR)/$$testname.output; \
		expected_file=$(TESTDIR)/$$testname.expected; \
		echo " TESTING $$testname"; \
		./pseudo < $$input_file 2> $$output_file; \
		diff $$expected_file $$output_file > /dev/null || (echo -ne "\r  ....FAILED. See $$testname.output for failures." >&2 && false);  \
		rc=`expr $$rc + $$?`; count=`expr $$count + 1`;\
	done; \
	echo; echo " Tests run: $$count,  Failures: $$rc"

testfiles: $(TESTFILES)
