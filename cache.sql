	IF (IN_PartsToReplace = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS (SELECT ' ||REPLACE(REPLACE(PartToPlaceCountChrs,'r.','RELIEFD.'),'COUNT(*)','1') || ' FROM DUAL )';
		ELSE
			LimitSQL := ' EXISTS (SELECT ' ||REPLACE(REPLACE(PartToPlaceCountChrs,'r.','RELIEFD.'),'COUNT(*)','1') || ' FROM DUAL )';
		END IF;
	END IF;



	These implicit LOBs come with a number of restrictions beyond those seen with conventional LOBs.
VARCHAR2 and NVARCHAR2 columns with a declared size greater than 4000 bytes are considered extended data types.
RAW columns with a declared size greater than 2000 bytes are considered extended data types.
All extended data types (see the previous two definitions) are stored out-of-line in LOB segments.
You have no manual control over these LOB segments. Their management is totally internal.
The LOB segments will always be stored in the same tablespace as the associated table.
LOBs stored in Automatic Segment Space Management (ASSM) tablespaces are stored as SecureFiles. Those stored in non-ASSM tablespaces are stored as BasicFiles.
All normal LOB restrictions apply.