CC = gcc
DBG = yes
ifeq ($(DBG), no)
	CFLAGS = -g -Wall
endif
LDFLAGS = -lfl
EXEC = tcompil
SDIR = ./src/

all: $(EXEC) clean

$(EXEC): $(EXEC).o lex.yy.o table_symboles.o
	$(CC) -o $@ $^ $(LDFLAGS)

$(EXEC).c: $(SDIR)$(EXEC).y
	bison -d -o $(EXEC).c $(SDIR)$(EXEC).y

$(EXEC).h: $(EXEC).c

lex.yy.c: $(SDIR)$(EXEC).lex $(EXEC).h
	flex $(SDIR)$(EXEC).lex

table_symboles.o: $(SDIR)table_symboles.c $(SDIR)table_symboles.h
	$(CC) -o $@ -c $< $(CFLAGS) -I$(SDIR)

%.o: %.c
	$(CC) -o $@ -c $< $(CFLAGS) -I$(SDIR)

clean:
	rm -f *.o lex.yy.c $(EXEC).[ch]

