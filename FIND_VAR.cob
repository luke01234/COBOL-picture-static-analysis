       IDENTIFICATION DIVISION.
       PROGRAM-ID. FIND_VAR.
       AUTHOR. Luke Attard.
       DATE-WRITTEN. 12/3/2025.

       DATA DIVISION.
       
       LOCAL-STORAGE SECTION.
           01 LO-INDEX                 PIC 9(4) VALUE 1.
           01 LO-TEMP-VAR1             PIC X(80).
           01 LO-TEMP-VAR2             PIC X(80).
           01 LO-TEMP-NUM1             PIC 9(3).

       LINKAGE SECTION. 
           01 LI-SEARCH-VAR            PIC X(80).

           01 LI-VARIABLES.
               05 LI-VARS OCCURS 100 TIMES.
                   10 LI-VAR-NAME      PIC X(80).
                   10 LI-VAR-TYPE      PIC X(80).
                   10 LI-VAR-SIZE      PIC 9(9).

           01 LI-INDEX-OUTPUT          PIC 9(16).
               

       PROCEDURE DIVISION USING BY REFERENCE LI-SEARCH-VAR LI-VARIABLES 
       LI-INDEX-OUTPUT.
      *THIS IS A HELPER FUNCTION TO FIND THE INDEX OF A VARIABLE AND
      *RETURN IT

       MOVE LI-VAR-NAME(LO-INDEX) TO LO-TEMP-VAR1.
       MOVE 0 TO LI-INDEX-OUTPUT.

       UNSTRING LI-SEARCH-VAR DELIMITED BY "("
           INTO LO-TEMP-VAR2
       END-UNSTRING.

       COMPUTE LO-TEMP-NUM1 = FUNCTION LENGTH(LO-TEMP-VAR2).
       
       IF LO-TEMP-VAR2 <> LI-SEARCH-VAR
           MOVE LO-TEMP-VAR2(1 : LO-TEMP-NUM1 - 1) TO LI-SEARCH-VAR
       END-IF.

       PERFORM UNTIL LO-TEMP-VAR1 = SPACE
           IF LO-TEMP-VAR1 = LI-SEARCH-VAR
               MOVE LO-INDEX TO LI-INDEX-OUTPUT
               MOVE SPACE TO LO-TEMP-VAR1
           END-IF

           ADD 1 TO LO-INDEX
           MOVE LI-VAR-NAME(LO-INDEX) TO LO-TEMP-VAR1
       END-PERFORM.
       
       EXIT PROGRAM.

       END PROGRAM FIND_VAR.
