       IDENTIFICATION DIVISION.
       PROGRAM-ID. POPULATE_VARS.
       AUTHOR. Luke Attard.
       DATE-WRITTEN. 12/3/2025.

       DATA DIVISION.
       
       LOCAL-STORAGE SECTION.
           01 LO-INDEX                 PIC 9(4) VALUE 1.
           01 LO-CURR-READ             PIC X(80).
           01 LO-VAR-TYPE              PIC X(80).
           01 LO-VARIABLE-INDEX        PIC 9(16).
           01 LO-TYPE-INDICATOR            PIC X(80).
           01 LO-TYPE-SIZE            PIC X(80).

           01 LO-TEMP-NUM1             PIC 9(16).

       LINKAGE SECTION.            
           01 LI-AST.
               05 LI-AST-NODES OCCURS 10000 TIMES.
                   10 LI-AST-NODE         PIC X(80).

           01 LI-VARIABLES.
               05 LI-VARS OCCURS 100 TIMES.
                   10 LI-VAR-NAME      PIC X(80).
                   10 LI-VAR-TYPE      PIC X(80).
                   10 LI-VAR-SIZE      PIC 9(9).

           01 LI-PROCEDURE-DIV-INDEX   PIC 9(16).         

       PROCEDURE DIVISION USING BY REFERENCE LI-AST LI-VARIABLES
       LI-PROCEDURE-DIV-INDEX.
      *INDEX ACTS AS INDEX
       MOVE 1 TO LO-INDEX.

      *NUM1 KEEPS TRACK OF VARIABLE INDEX
       MOVE 1 TO LO-VARIABLE-INDEX.

       PERFORM UNTIL LO-CURR-READ = "STOP"
      *    READ FROM ARRAY
           MOVE LI-AST-NODE(LO-INDEX) TO LO-CURR-READ

      *    IF A PICTURE CLAUSE IS FOUND SAVE THE VARIABLE 
           IF LI-AST-NODE(LO-INDEX) = "PIC"
               MOVE LI-AST-NODE(LO-INDEX - 1) 
               TO LI-VAR-NAME(LO-VARIABLE-INDEX)
               MOVE LI-AST-NODE(LO-INDEX + 1) 
               TO LO-VAR-TYPE
               
               UNSTRING LO-VAR-TYPE DELIMITED BY "("
                   INTO LO-TYPE-INDICATOR, LO-TYPE-SIZE
                   ON OVERFLOW DISPLAY "ISSUE PARSING " LO-VAR-TYPE
               END-UNSTRING
               
               COMPUTE LO-TEMP-NUM1 = FUNCTION LENGTH(LO-TYPE-INDICATOR)
               IF LO-TYPE-INDICATOR(LO-TEMP-NUM1 : 1) = "("
                   MOVE LO-TYPE-INDICATOR(1 : LO-TEMP-NUM1 - 1) TO
                   LO-TYPE-INDICATOR
               END-IF 

               COMPUTE LO-TEMP-NUM1 = FUNCTION LENGTH(LO-TYPE-SIZE)
               IF LO-TYPE-SIZE(LO-TEMP-NUM1 : 1) = ")"
                   MOVE LO-TYPE-SIZE(1 : LO-TEMP-NUM1 - 1) TO
                   LO-TYPE-SIZE
               END-IF 

               MOVE LO-TYPE-INDICATOR TO LI-VAR-TYPE(LO-VARIABLE-INDEX)
               MOVE LO-TYPE-SIZE TO LI-VAR-SIZE(LO-VARIABLE-INDEX)

      *        ADD TO THE VARIABLE INDEX
               ADD 1 TO LO-VARIABLE-INDEX
           END-IF

           IF LI-AST-NODE(LO-INDEX) = "PROCEDURE" 
               IF LI-AST-NODE(LO-INDEX + 1) = "DIVISION" OR 
               LI-AST-NODE(LO-INDEX + 1) = "DIVISION."
      *        IF WE FIND PROCEDURE DIVISION WE CAN STOP, SAVE THE INDEX
                   MOVE "STOP" TO LO-CURR-READ
                   ADD 2 TO LO-INDEX
                   MOVE LO-INDEX TO LI-PROCEDURE-DIV-INDEX
               END-IF
           END-IF
           ADD 1 TO LO-INDEX
       END-PERFORM.

       EXIT PROGRAM.

       END PROGRAM POPULATE_VARS.
