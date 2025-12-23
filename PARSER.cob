       IDENTIFICATION DIVISION.
       PROGRAM-ID. PARSER.
       AUTHOR. Luke Attard.
       DATE-WRITTEN. 12/3/2025.

       ENVIRONMENT DIVISION. 
          INPUT-OUTPUT SECTION.
             FILE-CONTROL.
             SELECT INPUTFILE ASSIGN TO LO-DYNAMIC-FILE
                ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
       FILE SECTION.
           FD INPUTFILE.
           01 INPUTFILE-RECORD.
              05 WS-CHARS PIC X(256).
 
       LOCAL-STORAGE SECTION.
           01 LO-DYNAMIC-FILE             PIC X(256).
           01 LO-EOF                   PIC X VALUE "N".
           01 LO-TOKEN                 PIC X(80).
           01 LO-POINTER               PIC 9(4) VALUE 1.
           01 LO-INDEX                 PIC 9(4) VALUE 1.
           01 LO-DONE                  PIC X VALUE "N".
           01 LO-TEMP-VAR1             PIC X(256).
           01 LO-TEMP-NUM1             PIC 9(3).
       LINKAGE SECTION. 
           01 LI-CMD-ARG                  PIC X(256).
           01 LI-AST.
               05 LI-AST-NODES OCCURS 10000 TIMES.
                   10 LI-AST-NODE         PIC X(80).
               

       PROCEDURE DIVISION USING LI-CMD-ARG LI-AST.

      *Read command-line argument (filename)
       PERFORM READ-FILE-PARA.
      *PERFORM DISPLAY-ARRAY-PARA.

      *STOP RUN. TURNS OUT THIS IS A BAD IDEA, USE EXIT PROGRAM INSTEAD
       EXIT PROGRAM.
       
       
       READ-FILE-PARA.
      *TRIM FILE NAME AND MOVE IT TO DYNAMIC FILE
       MOVE FUNCTION TRIM(LI-CMD-ARG) TO LO-DYNAMIC-FILE.

       OPEN INPUT INPUTFILE.

       PERFORM UNTIL LO-EOF = "Y"
      
      *READ FILE LINE BY LINE
      
           READ INPUTFILE INTO WS-CHARS
                AT END     
                MOVE "Y" TO LO-EOF
                NOT AT END 
                MOVE "N" TO LO-DONE
                MOVE 1 TO LO-POINTER
           END-READ

      *CHECK TO SEE IF THE LINE IS A COMMENT OR NOT
           IF WS-CHARS(7:1) <> "*"
      *READ EACH LINE AND SPLIT THEM UP BY PERIODS
                PERFORM UNTIL LO-DONE = "Y"
                   UNSTRING WS-CHARS
                       DELIMITED BY SPACE
                       INTO LO-TOKEN
                       WITH POINTER LO-POINTER
                       NOT ON OVERFLOW MOVE "Y" TO LO-DONE
                   END-UNSTRING
      *            DISPLAY WS-TOKEN

      *ADD EACH TOKEN TO THE "AST"
                   IF LO-TOKEN NOT = SPACE
      *                SANITIZE THE TOKENS BEFORE SAVING THEM
                       MOVE FUNCTION TRIM(LO-TOKEN) TO LO-TOKEN
                       MOVE FUNCTION UPPER-CASE(LO-TOKEN) TO LO-TOKEN
                       
      *                REMOVE TRAILING PERIODS
                       COMPUTE LO-TEMP-NUM1 = 
                       FUNCTION LENGTH(FUNCTION TRIM(LO-TOKEN))
      *                USING THE LENGTH CHECK TO SEE IF IT ENDS WITH A PERIOD
                       IF LO-TOKEN(LO-TEMP-NUM1:1) = "."
      *                    CUT OUT THE LAST CHARACTER
                           MOVE LO-TOKEN(1 : LO-TEMP-NUM1 - 1) 
                           TO LO-TOKEN
                       END-IF

                       MOVE LO-TOKEN TO LI-AST-NODE(LO-INDEX)
                       ADD 1 TO LO-INDEX
                   END-IF
                END-PERFORM
           END-IF
       END-PERFORM.
       
       CLOSE INPUTFILE.

       DISPLAY-ARRAY-PARA.
       MOVE 1 TO LO-TEMP-NUM1.
       MOVE "START" TO LO-TEMP-VAR1.
       PERFORM UNTIL LO-TEMP-VAR1 = SPACES
       MOVE LI-AST-NODE(LO-TEMP-NUM1) TO LO-TEMP-VAR1
       ADD 1 TO LO-TEMP-NUM1
       DISPLAY LO-TEMP-VAR1
       END-PERFORM.

       END PROGRAM PARSER.
