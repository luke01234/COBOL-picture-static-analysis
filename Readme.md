# COBOL Static Type & Data Transfer Aanlyzer

## What is this?

This is a small static analysis tool for the COBOL language that I made for a class project.

The project was open ended and I had some experience with COBOL and a few frustrations.
At least with the compiler I use **GnuCOBOL (the translation compiler)** there are very few protections on data transfer.
COBOL’s `PICTURE` clauses allow you to define variables with very specific constraints, such as:

- 3-digit integers  
- 5-character alphabetic strings  
- 10-character alphanumeric strings  
- Signed 20-digit integers 

However, the language does **not warn you** when you perform risky data transfers.

### Why this matters

FSome examples of silent failures in COBOL:

- Moving data from a **larger source** variable to a **smaller sink** variable causes **truncation and data loss**
- Moving a **signed** value into an **unsigned** variable can also cause **data loss**

This frustration was the perfect inspiration for my static analysis class final project. 

---

## Project Goal

The goal of this tool was to build a tool that:

- Tracks a subset of **COBOL data transfer logic**
- Keeps a record of variables defined in a program
- Detects **potential data truncation or loss**
- Warns the user if potential errors are found

And of course, this would have to be written **in COBOL itself**.

This repository contains that tool.

---

## How it works and what it does.

The tool is split into three main COBOL programs:

### `PARSER.cob`

Responsible for parsing COBOL programs.

- Called by `PROVER.cob`
- Breaks the source program into **tokens**, line by line
- Tokens are:
  - Individual COBOL clauses (e.g. `MOVE`, `ADD`, `VAR1`)
  - Or complete literals (stored as a single token)
- Tokens are stored in a table

---

### `POPULATE_VARS.cob`

Responsible for identifying variables.

- Called by `PROVER.cob`
- Uses the parsed token table
- Builds a variable table containing:
  - Variable names
  - Variable types
  - Variable sizes
- Parses from the **DATA DIVISION** to the **PROCEDURE DIVISION**

---

### `PROVER.cob`

The **main program**.

Responsible for taking user input on which file to type check, and actually performing static analysis logic. 
It works by reading the procedure division for data allocation clauses. 

Supported clauses include:

```cobol
MOVE       VAR1 TO VAR2
ADD        VAR1 TO VAR2
SUBTRACT   VAR1 FROM VAR2
MULTIPLY   VAR1 BY VAR2
COMPUTE    VAR1 = VAR2 + VAR3 - VAR4 
```

## Safety Conditions for Data Transfer

In all of these cases, for data transfer to be **completely safe**, a couple things must be ensured. 

### 1. Type Compatibility

The first requirement is a basic **type check** between the data source and the data sink.

Example:

```cobol
MOVE VAR1 TO VAR2
```

If ``VAR1`` is a signed integer and ``VAR2`` is unsigned, there is a possibility that data transfer will lead to data loss/truncation

### 2. Size Compatibility

The second requirement is that the **size of the source must not exceed the size of the sink.**

**Unsafe example**

```cobol
01 VAR1 PIC 9(10)
01 VAR2 PIC 9(5) 
MOVE VAR1 TO VAR2
```

Here, ``VAR1`` can hold more digits than ``VAR2``. Creating a dangerous data transfer in which **truncation and data loss** are possible. The analyzer flags this operataion.

**Safe example**
```cobol
01 VAR1 PIC 9(5)
01 VAR2 PIC 9(10) 
MOVE VAR1 TO VAR2
```
In this case, the sink variable is larger than the source, and is thus safe. The analyzer identifies t his and does not flag the size mismatch as it does not pose a risk.

## How to use this tool?

To use this tool, either:
- Compile it yourself using the provided Makefile
- Download a precompiled binary from the releases
  - (Note Precompiled binaries are created for Linux environments.)

Once you have the ``Prover`` binary, run it from the terminal and pass the COBOL file you want to analyze as the first argument:

```bash
./PROVER <file-to-analyze>.cob
```

## Example Test Runs

### TEST 1

```bash
$ ./PROVER COBOLTEST1.cob
THIS PROGRAM IS TYPE SATISFIED.
```

### TEST 2

```bash
$ ./PROVER COBOLTEST2.cob
UNSAFE ACTION: MOVE WS-VAR3 TO WS-VAR1
TYPE: 9 SIZE: 000000003 -> TYPE: 9 SIZE: 000000001
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: MOVE WS-VAR3 TO WS-VAR4
TYPE: 9 SIZE: 000000003 -> TYPE: Z SIZE: 000000003
TYPE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

THIS PROGRAM IS NOT TYPE SATISFIED.
```

TEST 3

```bash
$ ./PROVER COBOLTEST3.cob
THIS PROGRAM IS TYPE SATISFIED.
```

TEST 4

```bash
$ ./PROVER COBOLTEST4.cob
UNSAFE ACTION: ADD WS-VAR1 TO WS-VAR2
TYPE: 9 SIZE: 000000010 -> TYPE: 9 SIZE: 000000002
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: SUBTRACT WS-VAR1 FROM WS-VAR2
TYPE: 9 SIZE: 000000010 -> TYPE: 9 SIZE: 000000002
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: MULTIPLY WS-VAR3 BY WS-VAR4
TYPE: 9 SIZE: 000000003 -> TYPE: 9 SIZE: 000000002
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

THIS PROGRAM IS NOT TYPE SATISFIED.
```

TEST 5

```bash
$ ./PROVER COBOLTEST5.cob
THIS PROGRAM IS TYPE SATISFIED.
```

TEST 6

```bash
$ ./PROVER COBOLTEST6.cob
UNSAFE ACTION: MOVE WS-INDEX TO WS-ARRAY-NUM
TYPE: S9 SIZE: 000000003 -> TYPE: 9 SIZE: 000000010
TYPE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

THIS PROGRAM IS NOT TYPE SATISFIED.
```

TEST 7

```bash
$ ./PROVER COBOLTEST7.cob
LITERAL IN COMPUTE
UNSAFE ACTION: COMPUTE WS-VAR5 UTILIZING VARIABLE WS-VAR3 OF MISMATCHED SIZE
TYPE: 9 SIZE: 000000002 <- TYPE: 9 SIZE: 000000003
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: COMPUTE WS-VAR5 UTILIZING VARIABLE WS-ARRAY-NUM OF MISMATCHED SIZE
TYPE: 9 SIZE: 000000002 <- TYPE: 9 SIZE: 000000010
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

THIS PROGRAM IS NOT TYPE SATISFIED.
```

TEST 8

```bash
$ ./PROVER COBOLTEST8.cob
UNSAFE ACTION: MOVE WS-VAR2 TO WS-VAR1
TYPE: A SIZE: 000000002 -> TYPE: 9 SIZE: 000000001
TYPE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: MOVE WS-VAR2 TO WS-VAR1
TYPE: A SIZE: 000000002 -> TYPE: 9 SIZE: 000000001
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: MOVE WS-VAR3 TO WS-VAR2
TYPE: X SIZE: 000000010 -> TYPE: A SIZE: 000000002
TYPE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

UNSAFE ACTION: MOVE WS-VAR3 TO WS-VAR2
TYPE: X SIZE: 000000010 -> TYPE: A SIZE: 000000002
SIZE MISMATCH, POSSIBLE DATA LOSS/TRUNCATION.

THIS PROGRAM IS NOT TYPE SATISFIED.
```

TEST 9

```bash
$ ./PROVER COBOLTEST9.cob
THIS PROGRAM IS TYPE SATISFIED.
```
