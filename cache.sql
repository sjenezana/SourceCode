SET TERM ^ ;
CREATE OR ALTER PROCEDURE USPGETUNITFIELDVALUELISTINGRID (
    IN_USERKEY Varchar(36),
    IN_GRIDDATASOURCE Varchar(100),
    IN_FILTERCLAUSE Varchar(20000) DEFAULT NULL )
RETURNS (
    UNIT Varchar(400) )
AS
/*
SELECT p.*
FROM uspGetUnitFieldValueListInGrid('142300911629454832', 'uspGetRVList', NULL) p
*/

/******************************************************************************
**  File:        uspGetUnitFieldValueListInGrid.sql
**  Description: Returns unit List via @UserKey & @GridDataSource
**  Returns:     
**  Params:      @UserID - The logged on users number
*******************************************************************************
**  Change History
*******************************************************************************
**	Author	        Date				TFS	    Description
**	Marco Cao	    2014/08/07	n/a  		Original.
**	Marco Cao    2016/09/27		Add USELEAKED
**	Jerry chen   2017/11/02		US257523	VKV: general analyze needs to inform user of filter and allow "all owners/plants"
**	Jerry chen   2018/02/01		US285207	VKV: pretest % of cdtp column (and pretest leaked % cdtp column) have bug when set pressure changed
*******************************************************************************/
DECLARE VARIABLE CREATEDATE VARCHAR(30); 
	DECLARE VARIABLE EDITDATE Varchar(10);
	DECLARE VARIABLE TableName VARCHAR(100);
	DECLARE VARIABLE SQL VARCHAR(20000);
	DECLARE VARIABLE OwnerPlantFilter VARCHAR(20000);
	DECLARE VARIABLE FilterClause2 VARCHAR(20000);
	DECLARE VARIABLE FilterClause3 VARCHAR(20000);
	DECLARE VARIABLE FilterClause4 VARCHAR(20000);
	DECLARE VARIABLE FilterClause5 VARCHAR(2000);
	DECLARE VARIABLE LimitSQL VARCHAR(20000);
	DECLARE VARIABLE FilterSQL VARCHAR(20000);
	
	DECLARE VARIABLE EquipKey VARCHAR(36);
	DECLARE VARIABLE OnlyShowMR		CHAR(1);
	DECLARE VARIABLE RepairKey		VARCHAR(36);
	DECLARE VARIABLE PartsReplaced	CHAR(1);
	DECLARE VARIABLE PartsToReplace	CHAR(1);
	DECLARE VARIABLE PartsOnOrder	CHAR(1);
	DECLARE VARIABLE PartsNotGood	CHAR(1);
	DECLARE VARIABLE ComingDueType	INT;
	DECLARE VARIABLE IncludePastDue	CHAR(1);
	DECLARE VARIABLE UsingField		VARCHAR(100);
	DECLARE VARIABLE DateFrom		VARCHAR(10);
	DECLARE VARIABLE DateTo			VARCHAR(10);
	DECLARE VARIABLE AndOr			VARCHAR(10); 
	DECLARE VARIABLE Image			CHAR(1);
	DECLARE VARIABLE Generic		CHAR(1);
	DECLARE VARIABLE ToDo			CHAR(1);
	DECLARE VARIABLE InPart			CHAR(1);
	DECLARE VARIABLE InAR			CHAR(1);
	DECLARE VARIABLE InWeld			CHAR(1);
	DECLARE VARIABLE InPositioner	CHAR(1);
	DECLARE VARIABLE InLocation		CHAR(1);
	DECLARE VARIABLE InGeneric		CHAR(1);
	DECLARE VARIABLE ComingDueFrom	VARCHAR(10);
	DECLARE VARIABLE ComingDueTo	VARCHAR(10);
	DECLARE VARIABLE TempSQL		Varchar(20000);
	DECLARE VARIABLE SelectedColumns VARCHAR(20000);
	DECLARE VARIABLE OwnerNameColumn VARCHAR(500);
	DECLARE VARIABLE PlantLocationColumn VARCHAR(500);
	DECLARE VARIABLE PlantAreaColumn VARCHAR(500);
	DECLARE VARIABLE ImgCountColumn VARCHAR(500);
	DECLARE VARIABLE GenCountColumn VARCHAR(500);
	DECLARE VARIABLE ARCountColumn VARCHAR(500);
	DECLARE VARIABLE ToDoCountColumn VARCHAR(500);
	DECLARE VARIABLE PartCountColumn VARCHAR(500);
	DECLARE VARIABLE PartReplacedCountColumn VARCHAR(500);
	DECLARE VARIABLE PartToPlaceCountColumn VARCHAR(500);
	DECLARE VARIABLE PartOnOrderCountColumn VARCHAR(500);
	DECLARE VARIABLE PartNotGoodCountColumn VARCHAR(1500);
	DECLARE VARIABLE EventCountColumn VARCHAR(500);
	DECLARE VARIABLE InvisibleVKVSql VARCHAR(1000);
BEGIN	
	CREATEDATE = CAST(CURRENT_TIMESTAMP AS VARCHAR(30));
	EDITDATE = REPLACE(CAST(CURRENT_DATE AS VARCHAR(10)),'-','/');
    FilterClause2 = '';
	FilterClause3 = '';
	FilterClause4 = '';
	InvisibleVKVSql = '';
	select p.EXPRESSION from uspAppendInvisibleToFilter(:InvisibleVKVSql,:IN_USERKEY,'InvisibleInVKV','') p into :InvisibleVKVSql;

	SELECT	DATATABLE
	FROM	GRIDDATASOURCE
	WHERE	GRIDDATASOURCE = :IN_GridDataSource
	INTO	:TableName;

	OwnerNameColumn = '(SELECT OWNERNAME FROM OWNERS t WHERE t.UNIQUEKEY = r.OWNERKEY)';
	PlantLocationColumn = '(SELECT LOCATION FROM PLANTS t WHERE t.UNIQUEKEY = r.PLANTKEY)';
	PlantAreaColumn = '(SELECT AREA FROM PLANTS t WHERE t.UNIQUEKEY = r.PLANTKEY)';
	ImgCountColumn = '(SELECT COUNT(*) FROM IMAGES t WHERE ((t.REPAIRENTRYKEY = r.UNIQUEKEY AND t.TRACKSIMAGE = ''F'') OR (t.EQUIPTRACKKEY = r.EQUIPMENTKEY AND t.TRACKSIMAGE = ''T''))' || InvisibleVKVSql || ') IMAGECOUNT';
	GenCountColumn = '(SELECT COUNT(*) FROM GENERIC t WHERE ((t.REPAIRENTRYKEY = r.UNIQUEKEY AND t.OWNEDBY = ''Repair'') OR (t.EQUIPTRACKKEY = r.EQUIPMENTKEY AND t.OWNEDBY = ''Track''))' || InvisibleVKVSql || ') GENERICCOUNT';
	ARCountColumn = '(SELECT COUNT(*) FROM AR t WHERE t.EQUIPTRACKKEY = r.EQUIPMENTKEY' || InvisibleVKVSql || ') ARCOUNT';
	ToDoCountColumn = '(SELECT COUNT(*) FROM TODOLIST t WHERE t.EQUIPTRACKKEY = r.EQUIPMENTKEY' || InvisibleVKVSql || ') TODOCOUNT';
	PartCountColumn = '(SELECT COUNT(*) FROM PARTS t WHERE t.REPAIRENTRYKEY = r.UNIQUEKEY' || InvisibleVKVSql || ') PARTCOUNT';
	PartReplacedCountColumn = '(SELECT COUNT(*) FROM PARTS t WHERE t.REPAIRENTRYKEY = r.UNIQUEKEY AND WORKPERFORMED CONTAINING ''REPLACE''' || InvisibleVKVSql || ') PARTREPLACEDCOUNT';
	PartToPlaceCountColumn = '(SELECT COUNT(*) FROM PARTS t WHERE t.REPAIRENTRYKEY = r.UNIQUEKEY AND (RECOMMENDATION CONTAINING ''REPLACE'' OR RECOMMENDATION CONTAINING ''NEXT'' OR RECSPARE = ''T'')' || InvisibleVKVSql || ') PARTTOREPLACECOUNT';
	PartOnOrderCountColumn = '(SELECT COUNT(*) FROM PARTS t WHERE t.REPAIRENTRYKEY = r.UNIQUEKEY AND PartOnOrder = ''T''' || InvisibleVKVSql || ') PARTONORDERCOUNT';
	PartNotGoodCountColumn = '(SELECT COUNT(*) FROM PARTS t WHERE t.REPAIRENTRYKEY = r.UNIQUEKEY AND (WorkPerformed Containing ''replace'' or Recommendation Containing ''replace'' or Recommendation Containing ''next'' or Recommendation Containing ''spare'' or RecSpare =''T'')' || InvisibleVKVSql || ') PARTNOTGOODCOUNT';
    EventCountColumn = '(SELECT COUNT(*) FROM ' || TableName || ' t WHERE t.EQUIPMENTKEY = r.EQUIPMENTKEY) EVENTCOUNT';
	
	IF (IN_FilterClause IS NULL) THEN
	BEGIN
		IN_FilterClause = '';
	END
	
	SELECT	OnlyShowMR,
			RepairKey,
			PartsReplaced,
			PartsToReplace,
			PartsOnOrder,
			PartsNotGood,
			ComingDueType,
			IncludePastDue,
			UsingField,
			DateFrom,
			DateTo, 
			AndOr,
			Image,
			Generic,
			ToDo,
			InPart,
			InAR,
			InWeld,
			InPositioner,
			InLocation,
			InGeneric
	FROM	(SELECT	MAX(CASE FILTERNAME WHEN 'cmbMRType' THEN CASE FILTERVALUE WHEN 0 THEN 'T' ELSE NULL END ELSE NULL END) AS OnlyShowMR,
					MAX(CASE FILTERNAME WHEN 'cmbMRType' THEN CASE FILTERVALUE WHEN 2 THEN FILTERSQLVALUE ELSE NULL END ELSE NULL END) AS RepairKey,
					MAX(CASE FILTERNAME WHEN 'chkPartsReplaced' THEN 'T' ELSE NULL END) AS PartsReplaced,
					MAX(CASE FILTERNAME WHEN 'chkPartsToReplace' THEN 'T' ELSE NULL END)  AS PartsToReplace,
					MAX(CASE FILTERNAME WHEN 'chkPartsOnOrder' THEN 'T' ELSE NULL END) AS PartsOnOrder,
					MAX(CASE FILTERNAME WHEN 'chkPartsNotGood' THEN 'T' ELSE NULL END) AS PartsNotGood,	
					MAX(CASE FILTERNAME WHEN 'cmbComingDueType' THEN FILTERVALUE ELSE NULL END) AS ComingDueType,
					MAX(CASE FILTERNAME WHEN 'chkIncludePastDue' THEN 'T' ELSE NULL END) AS IncludePastDue,
					MAX(CASE FILTERNAME WHEN 'cmbUsingField' THEN FILTERVALUE ELSE NULL END) AS UsingField,
					MAX(CASE FILTERNAME WHEN 'txtDateFrom' THEN FILTERVALUE ELSE NULL END) AS DateFrom,
					MAX(CASE FILTERNAME WHEN 'txtDateTo' THEN FILTERVALUE ELSE NULL END) AS DateTo,
					MAX(CASE FILTERNAME WHEN 'rblAndOr' THEN CASE FILTERVALUE WHEN 1 THEN ' OR ' ELSE ' AND ' END ELSE ' AND ' END) AS AndOr,
					MAX(CASE FILTERNAME WHEN 'chkImage' THEN 'T' ELSE NULL END) AS Image,
					MAX(CASE FILTERNAME WHEN 'chkGeneric' THEN 'T' ELSE NULL END) AS Generic,
					MAX(CASE FILTERNAME WHEN 'chkToDo' THEN 'T' ELSE NULL END) AS ToDo,
					MAX(CASE FILTERNAME WHEN 'chkInPart' THEN 'T' ELSE NULL END) AS InPart,
					MAX(CASE FILTERNAME WHEN 'chkInAR' THEN 'T' ELSE NULL END) AS InAR,
					MAX(CASE FILTERNAME WHEN 'chkInWeld' THEN 'T' ELSE NULL END) AS InWeld,
					MAX(CASE FILTERNAME WHEN 'chkInPositioner' THEN 'T' ELSE NULL END) AS InPositioner,
					MAX(CASE FILTERNAME WHEN 'chkInLocation' THEN 'T' ELSE NULL END) AS InLocation,
					MAX(CASE FILTERNAME WHEN 'chkInGeneric' THEN 'T' ELSE NULL END) AS InGeneric
			FROM	GRIDFILTER
			WHERE	USERKEY = :IN_USERKEY
			AND		GRIDDATASOURCE = 'RepairListFilter'
			GROUP BY GRIDDATASOURCE) T
	INTO	:OnlyShowMR, :RepairKey, :PartsReplaced, :PartsToReplace, :PartsOnOrder, :PartsNotGood, :ComingDueType, :IncludePastDue, :UsingField, :DateFrom, :DateTo, 
			:AndOr, :Image, :Generic, :ToDo, :InPart, :InAR, :InWeld, :InPositioner, :InLocation, :InGeneric;
	
	IF (ComingDueType = 0) THEN
	BEGIN
		ComingDueTo = NULL;
	END
	ELSE IF (ComingDueType = 1) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(DAY, MOD(7 - EXTRACT(WEEKDAY FROM CURRENT_DATE), 7), CURRENT_DATE) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 2) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(DAY, MOD(7 - EXTRACT(WEEKDAY FROM CURRENT_DATE), 7) + 7, CURRENT_DATE) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 3) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(MONTH, 1, DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_DATE), CURRENT_DATE)) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 4) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(MONTH, 2, DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_DATE), CURRENT_DATE)) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 5) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(MONTH, 4, DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_DATE), CURRENT_DATE)) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 6) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(MONTH, 7, DATEADD(DAY, -EXTRACT(DAY FROM CURRENT_DATE), CURRENT_DATE)) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 7) THEN
	BEGIN
		ComingDueTo = REPLACE(CAST(DATEADD(YEAR, 1, DATEADD(DAY, -EXTRACT(YEARDAY FROM CURRENT_DATE)-1, CURRENT_DATE)) AS Varchar(10)),'-','/');
	END
	ELSE IF (ComingDueType = 8) THEN
	BEGIN
		ComingDueTo = EditDate;
	END
	ELSE
	BEGIN
		ComingDueTo = NULL;
	END
	
	IF (IncludePastDue = 'T') THEN
	BEGIN
		ComingDueFrom = '1900/01/01';
		IF (ComingDueTo IS NULL) THEN
		BEGIN
			ComingDueTo = EditDate;
		END
	END
	ELSE
	BEGIN
		ComingDueFrom = EditDate;
	END
	
	IF (OnlyShowMR = 'T') THEN
	BEGIN
		FilterClause2 = 'MOSTRECENT = ''T''';
	END
	ELSE IF (RepairKey IS NOT NULL AND RepairKey <> '') THEN
	BEGIN
		SELECT FIRST 1 EQUIPMENTKEY
		FROM	(	SELECT	EQUIPMENTKEY
					FROM	RELIEFD
					WHERE	UNIQUEKEY = :RepairKey
					UNION
					SELECT	EQUIPMENTKEY
					FROM	CV
					WHERE	UNIQUEKEY = :RepairKey
					UNION
					SELECT	EQUIPMENTKEY
					FROM	LINEV
					WHERE	UNIQUEKEY = :RepairKey
					UNION
					SELECT	EQUIPMENTKEY
					FROM	MOV
					WHERE	UNIQUEKEY = :RepairKey)
		INTO	:EquipKey;

		FilterClause2 =  'EQUIPMENTKEY = ''' || COALESCE(EquipKey, '') || '''';
	END

	IF (ComingDueTo IS NOT NULL) THEN
	BEGIN
		FilterClause3 = '(NEXTMAINDATE BETWEEN ''' || ComingDueFrom || ''' AND ''' || ComingDueTo  || ''' OR NEXTTESTDATE BETWEEN ''' || ComingDueFrom || ''' AND ''' || ComingDueTo  || ''')';
	END

	IF (UsingField IS NOT NULL AND UsingField <> '') THEN
	BEGIN
		IF (UsingField = 'SHIPPEDDATE' AND TableName = 'RELIEFD') THEN
		BEGIN
			UsingField = 'ETEXT14';
		END

		FilterClause4 = UsingField || ' BETWEEN ''' || COALESCE(DateFrom, '1900/01/01') || ''' AND ''' || COALESCE(DateTo, '9999/12/30') || '''';		
	END

	IF(FilterClause2 <> '') THEN
	BEGIN
		IF (IN_FilterClause = '') THEN
		BEGIN
			IN_FilterClause = '(' || FilterClause2 || ')';
		END
		ELSE
		BEGIN
			IN_FilterClause = IN_FilterClause || ' AND (' || FilterClause2 || ')';
		END
	END
	
	IF(FilterClause3 <> '') THEN
	BEGIN
		IF (IN_FilterClause = '') THEN
		BEGIN
			IN_FilterClause = '(' || FilterClause3 || ')';
		END
		ELSE
		BEGIN
			IN_FilterClause = IN_FilterClause || ' AND (' || FilterClause3 || ')';
		END
	END

	IF(FilterClause4 <> '') THEN
	BEGIN
		IF (IN_FilterClause = '') THEN
		BEGIN
			IN_FilterClause = '(' || FilterClause4 || ')';
		END
		ELSE
		BEGIN
			IN_FilterClause = IN_FilterClause || ' AND (' || FilterClause4 || ')';
		END
	END

	SELECT	FILTERSQLVALUE
	FROM	GRIDFILTER
	WHERE	USERKEY = :IN_USERKEY
	AND		GRIDDATASOURCE = :IN_GridDataSource
	AND		MOSTRECENT = 'T'
	INTO	:FILTERSQL;
	
	FILTERSQL = REPLACE(FILTERSQL, TableName || '.', 'r.');
	
	EXECUTE PROCEDURE UFFORMATUPPERCOLUMNS (:FILTERSQL) RETURNING_VALUES(:FILTERSQL);
	
	EXECUTE PROCEDURE UFGETPLANTFILTERSTRING (:IN_USERKEY, :FILTERSQL, :IN_FILTERCLAUSE) RETURNING_VALUES(:FILTERSQL);
	
	EXECUTE PROCEDURE ufGetWorkingPlantsClause('OWNERKEY', 'PLANTKEY', IN_UserKey) RETURNING_VALUES(OwnerPlantFilter);
		
	IF (Image = 'T') THEN
	BEGIN
		LimitSQL = 'IMAGECOUNT > 0';
	END
	
	IF (Generic = 'T') THEN
	BEGIN
		IF(LimitSQL <> '') THEN
		BEGIN
			LimitSQL = LimitSQL || AndOr || 'GENERICCOUNT > 0';
		END
		ELSE
		BEGIN
			LimitSQL = 'GENERICCOUNT > 0';
		END
	END
	
	IF (ToDo = 'T') THEN
	BEGIN
		IF(LimitSQL <> '') THEN
		BEGIN
			LimitSQL = LimitSQL || AndOr || 'TODOCOUNT > 0';
		END
		ELSE
		BEGIN
			LimitSQL = 'TODOCOUNT > 0';
		END
	END
	
	IF (PartsReplaced = 'T') THEN
	BEGIN
		IF(LimitSQL <> '') THEN
		BEGIN
			LimitSQL = LimitSQL || AndOr || 'PARTREPLACEDCOUNT > 0';
		END
		ELSE
		BEGIN
			LimitSQL = 'PARTREPLACEDCOUNT > 0';
		END
	END	
	
	IF (PartsToReplace = 'T') THEN
	BEGIN
		IF(LimitSQL <> '') THEN
		BEGIN
			LimitSQL = LimitSQL || AndOr || 'PARTTOREPLACECOUNT > 0';
		END
		ELSE
		BEGIN
			LimitSQL = 'PARTTOREPLACECOUNT > 0';
		END
	END
	
	IF (PartsOnOrder = 'T') THEN
	BEGIN
		IF(LimitSQL <> '') THEN
		BEGIN
			LimitSQL = LimitSQL || AndOr || 'PARTONORDERCOUNT > 0';
		END
		ELSE
		BEGIN
			LimitSQL = 'PARTONORDERCOUNT > 0';
		END
	END

	IF (PartsNotGood = 'T') THEN
	BEGIN
		IF(LimitSQL <> '') THEN
		BEGIN
			LimitSQL = LimitSQL || AndOr || 'PARTNOTGOODCOUNT > 0';
		END
		ELSE
		BEGIN
			LimitSQL = 'PARTNOTGOODCOUNT > 0';
		END
	END
	
	INSERT INTO TEMPGRIDCUSTOMIZEDFIELD ( NUMERATOR,
										  DENOMINATOR,
										  FIELDNAME,
										  FLAGRANGE,
										  FLAGTEXT,
										  DISPLAYLIKE,
										  CREATEDATE)
	SELECT	CASE WHEN USESETPRESS = 'T' AND NUMERATOR='COLDDIFFSET' THEN 'COALESCE((SELECT P.FRESULTCDTP FROM UFGETCORRECTCDTP(SETPRESSURE, COLDDIFFSET, SIZING1,MFGNPCDTP,SIZING4,REQUESTSET,PRNPCDTP,MAINTFOR, VALVESETPRESSCHANGE) P), COLDDIFFSET,SETPRESSURE)' WHEN USELEAKED = 'T' AND NUMERATOR='LEAKEDATPRESS' THEN 'COALESCE(LEAKEDATPRESS,CAST(IIF(ISFLOAT(LEAKED)=1,LEAKED,NULL) AS DECIMAL))'  WHEN NUMERATOR='RESEATPRESS' THEN 'CAST(IIF(ISFLOAT(RESEATPRESS)=1,RESEATPRESS,NULL) AS DECIMAL)' WHEN NUMERATOR='COLDDIFFSET' THEN '(SELECT P.FRESULTCDTP FROM UFGETCORRECTCDTP(SETPRESSURE, COLDDIFFSET, SIZING1,MFGNPCDTP,SIZING4,REQUESTSET,PRNPCDTP,MAINTFOR, VALVESETPRESSCHANGE) P)' ELSE NUMERATOR END AS NUMERATOR,
			CASE WHEN USESETPRESS = 'T' AND DENOMINATOR='COLDDIFFSET' THEN 'COALESCE((SELECT P.FRESULTCDTP FROM UFGETCORRECTCDTP(SETPRESSURE, COLDDIFFSET, SIZING1,MFGNPCDTP,SIZING4,REQUESTSET,PRNPCDTP,MAINTFOR, VALVESETPRESSCHANGE) P), COLDDIFFSET,SETPRESSURE)'  WHEN USELEAKED = 'T' AND DENOMINATOR='LEAKEDATPRESS' THEN 'COALESCE(LEAKEDATPRESS,CAST(IIF(ISFLOAT(LEAKED)=1,LEAKED,NULL) AS DECIMAL))' WHEN DENOMINATOR='RESEATPRESS' THEN 'CAST(IIF(ISFLOAT(RESEATPRESS)=1,RESEATPRESS,NULL) AS DECIMAL)' WHEN DENOMINATOR='COLDDIFFSET' THEN '(SELECT P.FRESULTCDTP FROM UFGETCORRECTCDTP(SETPRESSURE, COLDDIFFSET, SIZING1,MFGNPCDTP,SIZING4,REQUESTSET,PRNPCDTP,MAINTFOR, VALVESETPRESSCHANGE) P)' ELSE DENOMINATOR END AS DENOMINATOR,
			FIELDNAME,
			FLAGRANGE,
			FLAGTEXT,
			DISPLAYLIKE,
			:CREATEDATE
	FROM	GRIDCUSTOMIZEDFIELD
	WHERE	USERKEY = :IN_USERKEY
	AND		GRIDDATASOURCE = :IN_GridDataSource;	
	
	SELECT	LIST(CF, ',')
	FROM	(	SELECT	'IIF(' || DENOMINATOR || '<> 0,IIF(ABS(CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL)*100.00/' || DENOMINATOR|| '-100)>' || FLAGRANGE || ',CAST (CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL) *100.00/' ||  DENOMINATOR || ' AS DECIMAL(10,2)) || ''%' || FLAGTEXT || ''',CAST (CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL)*100.00/' ||  DENOMINATOR || ' AS DECIMAL(10,2)) || ''%''),NULL) ' || FIELDNAME AS CF
                FROM	TEMPGRIDCUSTOMIZEDFIELD
                WHERE	DISPLAYLIKE = 0
                AND		CREATEDATE = :CREATEDATE
                UNION
                SELECT	'IIF(' || DENOMINATOR || '<> 0,IIF(ABS(CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL)*100.00/' ||  DENOMINATOR || '-100)>' || FLAGRANGE || ',CAST (CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL)*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''' || FLAGTEXT || ''',CAST (CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL)*100.00/' ||  DENOMINATOR || ' AS DECIMAL(10,2))),NULL) ' || FIELDNAME AS CF
                FROM	TEMPGRIDCUSTOMIZEDFIELD
                WHERE	DISPLAYLIKE = 1
                AND		CREATEDATE = :CREATEDATE
                UNION
                SELECT	'IIF(' || DENOMINATOR || '<> 0,IIF(ABS(CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR|| ', NULL) AS DECIMAL)*100.0000/' || DENOMINATOR || '-100)>' || FLAGRANGE || ',CAST (CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL) *1.0000/' || DENOMINATOR || ' AS DECIMAL(10,4)) || ''' || FLAGTEXT || ''',CAST (CAST(IIF(ISFLOAT(' || NUMERATOR || ') = 1, ' || NUMERATOR || ', NULL) AS DECIMAL) *1.0000/' || DENOMINATOR || ' AS DECIMAL(10,4))),NULL) ' || FIELDNAME AS CF
                FROM	TEMPGRIDCUSTOMIZEDFIELD
                WHERE	DISPLAYLIKE = 2
                AND		CREATEDATE = :CREATEDATE
				UNION
				SELECT	FIRST 1 'r.IMAGECOUNT'
				FROM    RDB$DATABASE
				WHERE	:Image = 'T'
				UNION
				SELECT	FIRST 1 'r.GENERICCOUNT'
				FROM    RDB$DATABASE
				WHERE	:Generic = 'T'
				UNION
				SELECT	FIRST 1 'r.ARCOUNT'
				FROM    RDB$DATABASE
				WHERE	:InAR = 'T'
				UNION
				SELECT	FIRST 1 'r.TODOCOUNT'
				FROM    RDB$DATABASE
				WHERE	:ToDo = 'T'
				UNION
				SELECT	FIRST 1 'r.PARTREPLACEDCOUNT'
				FROM    RDB$DATABASE
				WHERE	:PartsReplaced = 'T'
				UNION
				SELECT	FIRST 1 'r.PARTTOREPLACECOUNT'
				FROM    RDB$DATABASE
				WHERE	:PartsToReplace = 'T'
				UNION
				SELECT	FIRST 1 'r.PARTONORDERCOUNT'
				FROM    RDB$DATABASE
				WHERE	:PartsOnOrder = 'T'
				UNION
				SELECT	FIRST 1 'r.PARTNOTGOODCOUNT'
				FROM    RDB$DATABASE
				WHERE	:PartsNotGood = 'T'
			)
	INTO	:SelectedColumns;
	
	IF (SelectedColumns IS NOT NULL) THEN
	BEGIN
		SelectedColumns = REPLACE(SelectedColumns, 'r.OWNERNAME', OwnerNameColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.LOCATION', PlantLocationColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.AREA', PlantAreaColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.IMAGECOUNT', ImgCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.GENERICCOUNT', GenCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.ARCOUNT', ARCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.TODOCOUNT', ToDoCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.PARTCOUNT', PartCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.PARTREPLACEDCOUNT', PartReplacedCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.PARTTOREPLACECOUNT', PartToPlaceCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.PARTONORDERCOUNT', PartOnOrderCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.PARTNOTGOODCOUNT', PartNotGoodCountColumn);
		SelectedColumns = REPLACE(SelectedColumns, 'r.EVENTCOUNT', EventCountColumn);
		SQL = 'SELECT DISTINCT IIF(UPPER(UNIT) IS NULL OR UNIT = '''', ''(Blank)'',UPPER(UNIT)) UNIT,' || SelectedColumns || ' FROM ' || TableName || ' r';
	END
	ELSE
	BEGIN
		SQL = 'SELECT DISTINCT IIF(UPPER(UNIT) IS NULL OR UNIT = '''', ''(Blank)'',UPPER(UNIT)) UNIT FROM ' || TableName || ' r';
	END	
	
	IF (FilterSQL <> '') THEN
	BEGIN
		SQL = SQL || ' WHERE ' || FilterSQL;
	END

	IF (LimitSQL <> '') THEN
	BEGIN
		SQL = 'SELECT * FROM (' || SQL || ') WHERE ' || LimitSQL;
	END
	
	SQL = 'SELECT DISTINCT UNIT FROM (' || SQL || ')';

	UNIT = 'All Units';
	SUSPEND;

	FOR	
		EXECUTE STATEMENT :SQL INTO :UNIT
	DO
	SUSPEND;
	
END^
SET TERM ; ^