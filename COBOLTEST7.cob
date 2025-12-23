121312*PARSER IGNORES THIS
       IDENTIFICATION DIVISION.
       PROGRAM-ID. COMPUTES.
       AUTHOR. Luke Attard.
       DATE-WRITTEN. 12/5/2025.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-ARRAY.
           05 WS-ARRAY-ITEM OCCURS 20 TIMES.
               10 WS-ARRAY-NUM                 PIC 9(10).       
       01  WS-VAR1             PIC 9(1) VALUE 1.
       01  WS-VAR2             PIC 9(2) VALUE 36.
       01  WS-VAR3             PIC 9(3) VALUE 100.
       01  WS-VAR4             PIC 9(3) VALUE 200.
       01  WS-VAR5             PIC 9(2) VALUE 20.

       PROCEDURE DIVISION.
      *PARSER SHOULD IGNORE THIS
       COMPUTE WS-VAR4 = WS-VAR1 + WS-VAR2 * WS-VAR3.

       COMPUTE WS-VAR5 = 30 + WS-VAR2 * WS-VAR3 / WS-ARRAY-NUM(1).
       
       STOP RUN.
