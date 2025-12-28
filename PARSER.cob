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
           01 LO-DYNAMIC-FILE         PIC X(256).
           01 LO-EOF                  PIC X VALUE "N".
           01 LO-POINTER              PIC 9(4) VALUE 1.
           01 LO-TRIMMED-CHARS        PIC X(80).
           01 LO-ARRAY-INDEX          PIC 9(4) VALUE 1.
           01 LO-LINE-INDEX           PIC 9(4) VALUE 1.
           01 LO-LINE-LENGTH          PIC 9(4) VALUE 1.
           01 LO-TOKEN-INDEX          PIC 9(4) VALUE 1.
           01 LO-TOKEN                PIC X(80).
           01 LO-STOP-CHAR            PIC X(1) VALUE SPACE.
           01 LO-TEMP-VAR1            PIC X(256).
           01 LO-TEMP-NUM1            PIC 9(3).
       LINKAGE SECTION. 
           01 LI-CMD-ARG              PIC X(256).
           01 LI-AST.
               05 LI-AST-NODES OCCURS 10000 TIMES.
                   10 LI-AST-NODE         PIC X(80).
               

       PROCEDURE DIVISION USING LI-CMD-ARG LI-AST.
      *PROCEDURE DIVISION.

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
                MOVE "N" TO LO-EOF
                MOVE 1 TO LO-POINTER
           END-READ

      *CHECK TO SEE IF THE LINE IS A COMMENT OR NOT
           IF WS-CHARS(7:1) <> "*" AND LO-EOF <> "Y"
      *
               MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-CHARS)) TO 
               LO-LINE-LENGTH
               MOVE 1 TO LO-LINE-INDEX
               MOVE 1 TO LO-TOKEN-INDEX
               MOVE SPACE TO LO-TOKEN
               MOVE SPACE TO LO-STOP-CHAR
      *        DISPLAY WS-CHARS

               PERFORM UNTIL LO-LINE-INDEX > LO-LINE-LENGTH
                  MOVE FUNCTION TRIM(WS-CHARS) TO 
                  LO-TRIMMED-CHARS
                  
                  IF LO-TRIMMED-CHARS(LO-LINE-INDEX:1) =
                  LO-STOP-CHAR
                  
                   IF LO-STOP-CHAR <> SPACE
                    MOVE LO-STOP-CHAR TO LO-TOKEN(LO-TOKEN-INDEX:1)
                   END-IF

                   PERFORM SAVE-TOKEN-PARA
                  
                  ELSE
                  
                   IF LO-TRIMMED-CHARS(LO-LINE-INDEX:1) = '"'
                   AND LO-STOP-CHAR = SPACE
                       MOVE '"' TO LO-STOP-CHAR
                   END-IF
                  
                   IF LO-TRIMMED-CHARS(LO-LINE-INDEX:1) = "'"
                   AND LO-STOP-CHAR = SPACE
                       MOVE "'" TO LO-STOP-CHAR
                   END-IF
                   
                   MOVE LO-TRIMMED-CHARS(LO-LINE-INDEX:1) TO 
                   LO-TOKEN(LO-TOKEN-INDEX:1)
                   ADD 1 TO LO-TOKEN-INDEX

                  END-IF

                  ADD 1 TO LO-LINE-INDEX
               
               END-PERFORM

               PERFORM SAVE-TOKEN-PARA

           END-IF
           
       END-PERFORM.
       
       CLOSE INPUTFILE.
       
       SAVE-TOKEN-PARA.
       IF FUNCTION LENGTH(FUNCTION TRIM(LO-TOKEN)) > 0
      *    DISPLAY LO-TOKEN " AND " LO-EOF
           COMPUTE LO-TEMP-NUM1 = 
           FUNCTION LENGTH(FUNCTION TRIM(LO-TOKEN))
      *    USING THE LENGTH CHECK TO SEE IF IT ENDS WITH A PERIOD
           IF LO-TOKEN(LO-TEMP-NUM1:1) = "."
      *      CUT OUT THE LAST CHARACTER
             MOVE LO-TOKEN(1 : LO-TEMP-NUM1 - 1) 
             TO LO-TOKEN
           END-IF
           MOVE LO-TOKEN TO LI-AST-NODE(LO-ARRAY-INDEX)
           ADD 1 TO LO-ARRAY-INDEX
           MOVE 1 TO LO-TOKEN-INDEX
           MOVE SPACE TO LO-TOKEN
           MOVE SPACE TO LO-STOP-CHAR
       END-IF.

       DISPLAY-ARRAY-PARA.
       MOVE 1 TO LO-TEMP-NUM1.
       MOVE "START" TO LO-TEMP-VAR1.
       PERFORM UNTIL LO-TEMP-VAR1 = SPACES
       MOVE LI-AST-NODE(LO-TEMP-NUM1) TO LO-TEMP-VAR1
       ADD 1 TO LO-TEMP-NUM1
       DISPLAY LO-TEMP-VAR1
       END-PERFORM.

       END PROGRAM PARSER.

