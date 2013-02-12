CFLAGS= -Wall -ggdb --pedantic
PROJDIRS := .
#TESTDIR := ./test
#TESTFILES := $(shell find $(TESTDIR) -type f -name "*.input")
CALCTESTDIR := ./calc_test
CALCTESTFILES := $(shell find $(CALCTESTDIR) -type f -name "*.input")
JASMIN_DIR := ./jasmin_files

all: calc pseudo

test: testcalc

pseudo: pseudo.tab.c lex.yy.c
	gcc -o pseudo pseudo.tab.c

pseudo.tab.c: pseudo.y lex.yy.c
	bison pseudo.y

lex.yy.c: pseudo.l pseudo.tab.h
	flex pseudo.l

pseudo.tab.h: pseudo.y
	bison -d pseudo.y

calc: scan.c calc.c calc.h
	@gcc scan.c calc.c -o calc -lfl

clean:
	@$(RM) -f calc pseudo
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


install:
	csh -c "cp ~mueller/classes/codeopt/ub2/pseudo0.y pseudo.y"
	csh -c "cp ~mueller/classes/codeopt/ub2/pseudo0.l pseudo.l"
	csh -c "cp ~mueller/classes/codeopt/ub2/hello.java ."
	csh -c "cp ~mueller/classes/codeopt/ub2/test.psd ."
	csh -c "ln -s ~mueller/classes/codeopt/jasmin ~/jasmin"
	csh -c "ln -s ~/jasmin/bin/jasmin ."
	csh -c "ln -s ~mueller/classes/codeopt/D-java/D-Java ."
	csh -c "ln -s ~mueller/classes/codeopt/ub2/Keyboard.* ."

jasmin:
	javac $(JASMIN_DIR)/Keyboard.java 
	mv $(JASMIN_DIR)/Keyboard.class .
	unzip $(JASMIN_DIR)/jasmin-2.4.zip -d $(JASMIN_DIR)
	dos2unix $(JASMIN_DIR)/jasmin-2.4/build.sh > $(JASMIN_DIR)/jasmin-2.4/build2.sh
	sh $(JASMIN_DIR)/jasmin-2.4/build2.sh all
	ln -s $(JASMIN_DIR)/jasmin-2.4/jasmin.jar .

rmjasmin:
	@$(RM) -fr $(JASMIN_DIR)/jasmin-2.4 $(JASMIN_DIR)/jasmin.jar
	@$(RM) Keyboard.class
	@unlink jasmin.jar

	
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
