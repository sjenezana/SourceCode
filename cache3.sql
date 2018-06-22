-- =============================================
-- Upgrade DB Version vkc2.1.4.sql
-- =============================================
--------------------------------------------------------
--  DDL for Table
--------------------------------------------------------
/ 
 
--------------------------------------------------------
--  DDL for Trigger
--------------------------------------------------------
/
--------------------------------------------------------
--  DDL for Function
--------------------------------------------------------
 
/
create or replace TYPE        "SPLITSTRINGROW_uni_TYPE"
AS OBJECT (
  ID           NUMBER(5),
  TOKEN  nVARCHAR2(2000)
);
/

create or replace TYPE        "SPLITSTRINGTABLE_uni"
IS TABLE OF SplitStringRow_uni_Type;
/ 

CREATE OR replace FUNCTION Ufsplitstring_nclob (instring IN NCLOB, 
                                          delim    IN CHAR, 
                                          keepcrlf CHAR := 'F') 
RETURN SPLITSTRINGTABLE_uni 
AS 
/* 
SELECT p.* 
FROM UFSPLITSTRING('A;BCD;EFG', ';') p 
*/ 
  /****************************************************************************** 
  **  File:        ufSplitString.sql 
  **  Description: Split @INSTRING via @DELIM 
  **  Returns:      
  **  Params:      @INSTRING 
  **               @DELIM 
  ******************************************************************************* 
  **  Change History 
  ******************************************************************************* 
  **  Author          Date        TFS      Description 
  **  Tony.Cai      2010/4/27    n/a      Original. 
  **  Marco Cao    2015/01/06    YES    Convert it to oracle 
  **  Marco Cao    2017/06/27    YES    Add a param to keep CR LF 
  **  Ben Song     2018/06/15      Convert to nvarchar2 
   
   
  select * FROM  TABLE(UFSPLITSTRING('other3|t - rh7|fghj - hg7|df - sg3|s - s14|bvg - kj7|', '|')) p;
  *******************************************************************************/ 
  cr         CHAR(1); 
  lf         CHAR(1); 
  pos        NUMBER(5); 
  id         NUMBER(5); 
  i1         NUMBER(5); 
  i2         NUMBER(5); 
  token      NVARCHAR2(2000); 
  v_instring NCLOB; 
  v_table    SPLITSTRINGTABLE_uni := SPLITSTRINGTABLE_uni(); 
BEGIN 
    cr := Chr(10); 

    lf := Chr(13); 

    id := 0; 

    v_instring := instring; 

    IF ( v_instring IS NOT NULL 
         AND Length(v_instring) > 0 ) THEN 
      v_instring := v_instring 
                    || delim; 

      pos := Instr(v_instring, delim); 

      WHILE ( pos <> 0 ) LOOP 
          token := Trim(Substr(v_instring, 1, pos - 1)); 

          IF keepcrlf = 'F' THEN 
            token := Replace(token, cr, ''); 

            token := Replace(token, lf, ''); 
          END IF; 

          IF pos - Length(v_instring) = 0 THEN 
            pos := 0; 
          ELSE 
            v_instring := Substr(v_instring, pos - Length(v_instring)); 

            pos := Instr(v_instring, delim); 
          END IF; 

          IF( token IS NOT NULL ) THEN 
            id := id + 1; 

            v_table.extend; 

            V_table(v_table.last) := NEW Splitstringrow_uni_type(id, token); 
          END IF; 
      END LOOP; 
    END IF; 

    RETURN v_table; 
END ;

/
drop type "SPLITSTRINGTABLE";
/

CREATE OR REPLACE TYPE SplitStringRow_Type AS OBJECT (
  ID           NUMBER(5),
  TOKEN  VARCHAR2(2000)
);
commit;
/
CREATE OR REPLACE TYPE SplitStringTable IS TABLE OF SplitStringRow_Type;
commit;
/
create or replace FUNCTION UFSPLITSTRING (
    INSTRING IN CLOB,
    DELIM IN CHAR,
	KEEPCRLF CHAR :='F')
RETURN SplitStringTable
AS
/*
SELECT p.*
FROM UFSPLITSTRING('A;BCD;EFG', ';') p
*/
/******************************************************************************
**  File:        ufSplitString.sql
**  Description: Split @INSTRING via @DELIM
**  Returns:     
**  Params:      @INSTRING
**               @DELIM
*******************************************************************************
**  Change History
*******************************************************************************
**	Author	        Date				TFS	    Description
**	Tony.Cai	    2010/4/27		n/a  		Original.
**	Marco Cao    2015/01/06		YES		Convert it to oracle
**	Marco Cao    2017/06/27		YES		Add a param to keep CR LF
*******************************************************************************/
	 CR CHAR(1);
	 LF CHAR(1);
	 POS NUMBER(5);
	 ID           NUMBER(5);
   	 i1           NUMBER(5);
     	 i2           NUMBER(5);
	 TOKEN  VARCHAR2(2000);
   v_INSTRING CLOB;
	 v_Table SplitStringTable := SplitStringTable();
BEGIN
	CR := CHR(10);
	LF := CHR(13);
	ID := 0;
  v_INSTRING := INSTRING;
  
	IF (v_INSTRING IS NOT NULL AND LENGTH(v_INSTRING) > 0) THEN
		v_INSTRING := v_INSTRING || DELIM;
		POS := INSTR(v_INSTRING, DELIM);

		WHILE (POS <> 0) 
		LOOP
			TOKEN := TRIM(SUBSTR(v_INSTRING, 1, POS - 1));

			IF KEEPCRLF = 'F' THEN
				TOKEN := REPLACE(TOKEN, CR, '');
				TOKEN := REPLACE(TOKEN, LF, '');
			END IF;

      IF POS-LENGTH(V_INSTRING) = 0 THEN
        POS := 0;
      ELSE  
        v_INSTRING := SUBSTR(v_INSTRING, POS-LENGTH(v_INSTRING));
        POS := INSTR(v_INSTRING, DELIM);
			END IF;
      
			IF(TOKEN IS NOT NULL) THEN
				ID := ID + 1;
				v_Table.extend;
				v_Table(v_Table.last) := new SplitStringRow_Type(ID, TOKEN);
			END IF;
		END LOOP;
	END	IF;
	
	RETURN v_Table;

END UFSPLITSTRING;
/
--------------------------------------------------------
--  DDL for Procedure
-------------------------------------------------------- 
/