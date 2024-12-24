OUT      = tcc
TESTFILE = test.c
SCANNER  = scanner.l
PARSER   = parser.y

CC       = g++
OBJ      = lex.yy.o y.tab.o
TESTOUT  = $(basename $(TESTFILE)).asm
OUTFILES = lex.yy.c y.tab.c y.tab.h y.output $(OUT)

CFLAGS   = $(shell pkg-config --cflags glib-2.0) -std=c++17
LDFLAGS  = $(shell pkg-config --libs glib-2.0)

.PHONY: build test simulate clean

build: $(OUT)

test: $(TESTOUT)

simulate: $(TESTOUT)
	python pysim.py $< -a

clean:
	rm -f *.o $(OUTFILES)

$(TESTOUT): $(TESTFILE) $(OUT)
	./$(OUT) < $< > $@

$(OUT): $(OBJ)
	$(CC) -o $(OUT) $(OBJ) $(LDFLAGS)

lex.yy.c: $(SCANNER) y.tab.c
	flex $<

y.tab.c: $(PARSER)
	bison -vdty $<

lex.yy.o: lex.yy.c
	$(CC) -c -o $@ $< $(CFLAGS)

y.tab.o: y.tab.c
	$(CC) -c -o $@ $< $(CFLAGS)