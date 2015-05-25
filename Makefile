CC = gcc
CFLAGS = -Wall
LDFLAGS = -Wall -lfl
EXEC = comp

all: $(EXEC) clean

$(EXEC): $(EXEC).o lex.yy.o table_symboles.o
	$(CC) -o $@ $^ $(LDFLAGS)

$(EXEC).c: $(EXEC).y
	bison -d -o $(EXEC).c $(EXEC).y

$(EXEC).h: $(EXEC).c

lex.yy.c: $(EXEC).lex $(EXEC).h
	flex $(EXEC).lex

table_symboles.o: table_symboles.c table_symboles.h
	$(CC) -o $@ -c $< $(CFLAGS)

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f *.o lex.yy.c $(EXEC).[ch]

