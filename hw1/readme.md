### CSC512 Homework 1 ###

## Build Instructions ##

```
make
```

## Run Instuctions ##

Three executables produced:
	1. calc - a simple calculator with a Flex-generated lexical scanner
	2. calc2 - a simple calcultor with a handwritten lexical scanner
	3. psuedo
	
calc and calc2 can be used in interpretive-mode and exitted with ^C; pseudo expects EOF to end.

	
## Valid Test Input ##

VAR a,b:REAL;c:INT[42];
BEGIN
c:=thx[1138]*INT(10);
a:=-1.0+0.20/0.1;
IF b
	>
1 AND b<>b OR b=b THEN WRITE(a); ELSE READ(a); ENDIF;
a:=110/10;
END
===================
VAR
BEGIN
END
===================
BEGIN
END
===================
BEGIN
PROC procName() BEGIN END ENDPROC;
PROC betterProc(IN in:INT, OUT out:INT, INOUT inout:INT, REF r:REAL) BEGIN END ENDPROC;
procName(no, arguments, here);
betterProc(really, arguments);
END
===================
BEGIN
a := ----10;
b := +-+-+--10;
END
===================
BEGIN
WHILE a=b DO
	REPEAT
		a:=c;
		UNTIL a<>b
	ENDREPEAT;
	FOR i:=5 MOD 1 TO 10 DIV 2 DO ENDFOR;
	PARFOR ii:=iii TO 5*5+2 PRIVATE x,y,z REDUCE - xx,yy,zz DO 
		WRITE(ii);
	ENDPARFOR;
ENDWHILE;
END


## Invalid Test Input ##

a:=-1.0+2.0;
IF a THEN WRITE(a) ENDIF;
IF a>0 THEN WRITE(a) ENDIF;
a:=1;
a-;
test scanner #;


VAR a,b:REAL;
BEGIN
a:=-1.0+0.20;
IF b>1 THEN WRITE(PRIVATE); ENDIF;
a:=110;
END


