CFLAGS= -Wall -ggdb --pedantic
PROJDIRS := .
#TESTDIR := ./test
#TESTFILES := $(shell find $(TESTDIR) -type f -name "*.input")
CALCTESTDIR := ./calc_test
CALCTESTFILES := $(shell find $(CALCTESTDIR) -type f -name "*.input")

all: calc

test: testcalc

calc: scan.c calc.c calc.h
	@gcc scan.c calc.c -o calc -lfl

clean:
	@$(RM) -f calc calc2 pseudo
	@$(RM) -f *.yy.c 
	@$(RM) -f *.tab.* 
	@$(RM) -f *.output
	@$(RM) -f $(CALCTESTDIR)/*.output 

testcalc: all calctestfiles
	-@rc=0; count=0; \
	echo "======Testing calc======"; \
	for input_file in $(CALCTESTFILES); do \
		testname=`basename $$input_file .input`; \
		output_file=$(CALCTESTDIR)/$$testname.output; \
		expected_file=$(CALCTESTDIR)/$$testname.expected; \
		echo " TESTING $$testname"; \
		./calc < $$input_file > $$output_file 2>> $$output_file; \
		diff $$expected_file $$output_file > /dev/null || (echo -ne "\r  ....FAILED. See $$testname.output for failures." >&2 && false); \
		rc=`expr $$rc + $$?`; count=`expr $$count + 1`; \
	done; \
	echo; echo " Tests run: $$count,  Failures: $$rc"


calctestfiles: $(CALCTESTFILES)

#test: all testfiles
#	-@rc=0; count=0; \
#	for input_file in $(TESTFILES); do \
#		testname=`basename $$input_file .input`; \
#		output_file=$(TESTDIR)/$$testname.output; \
#		expected_file=$(TESTDIR)/$$testname.expected; \
#		echo " TESTING $$testname"; \
#		./pseudo < $$input_file 2> $$output_file; \
#		diff $$expected_file $$output_file > /dev/null || (echo -ne "\r  ....FAILED. See $$testname.output for failures." >&2 && false);  \
#		rc=`expr $$rc + $$?`; count=`expr $$count + 1`;\
#	done; \
#	echo; echo " Tests run: $$count,  Failures: $$rc"

#testfiles: $(TESTFILES)
