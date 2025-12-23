121312*PARSER IGNORES THIS
       IDENTIFICATION DIVISION.
       PROGRAM-ID. STRING-TYPE-ERRORS.
       AUTHOR. Luke Attard.
       DATE-WRITTEN. 12/5/2025.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.

       01  WS-ARRAY.
           05 WS-ARRAY-ITEM OCCURS 20 TIMES.
               10 WS-ARRAY-NUM                 PIC 9(10).       
       01  WS-VAR1             PIC 9(1) VALUE 1.
       01  WS-VAR2             PIC A(2) VALUE 36.
       01  WS-VAR3             PIC X(10) VALUE 100.


       PROCEDURE DIVISION.
      *PARSER SHOULD IGNORE THIS
       MOVE WS-VAR2 TO WS-VAR1.
       MOVE WS-VAR3 TO WS-VAR2.
       
       STOP RUN.
