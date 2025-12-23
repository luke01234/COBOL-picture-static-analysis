# Makefile for cobol_tetris

# Compiler options
COBC = cobc
COBFLAGS = -x

# Source files
COBOL_SOURCES = PROVER.cob PARSER.cob FIND_VAR.cob POPULATE_VARS.cob

# Output executable
EXECUTABLE = PROVER

all: compile 

compile: $(COBOL_SOURCES)
	$(COBC) $(COBFLAGS) $(COBOL_SOURCES)

clean:
	rm -f $(EXECUTABLE)
