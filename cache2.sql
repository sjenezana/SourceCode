SET TERM ^ ;
ALTER PROCEDURE USPGETGRIDFIELD (
    IN_USERKEY Varchar(36),
    IN_GRIDDATASOURCE Varchar(100) DEFAULT NULL,
    IN_QUERYTYPE Varchar(10) DEFAULT NULL,
    IN_SHOWCDMEAS Char(1) DEFAULT 'T',
    IN_SHOWCDMFG Char(1) DEFAULT 'T',
    IN_SHOWCDSHIPPED Char(1) DEFAULT 'T',
    IN_SHOWCOST Char(1) DEFAULT 'T',
    IN_INCLUDECUSFIELDS Char(1) DEFAULT 'T',
    IN_MRTYPE Varchar(100) DEFAULT NULL )
RETURNS (
    RETMULDATASETS Char(1),
    SELECTSQL Varchar(10000),
    SORTTSQL Varchar(10000),
    FILTERSQL Varchar(10000),
    COUNTSQL Varchar(10000) )
AS
DECLARE VARIABLE CREATEDATE VARCHAR(30);
DECLARE VARIABLE EDITDATE Varchar(10);
DECLARE VARIABLE ROWCOUNT Integer;
DECLARE VARIABLE TemplateID VARCHAR(36);
DECLARE VARIABLE FixedFieldCount Integer;
DECLARE VARIABLE LeftFieldCount Integer;
DECLARE VARIABLE FLevel Smallint;
DECLARE VARIABLE tmpIGNOREINVISIBLEINVKV Char(1);
DECLARE VARIABLE EquipType varchar(100);
DECLARE VARIABLE EquipTypeAndValve varchar(100);

BEGIN
	CREATEDATE = CAST (CURRENT_TIMESTAMP AS VARCHAR(30));
	EDITDATE = REPLACE(CAST(CURRENT_DATE AS VARCHAR(10)),'-','/');
	RetMulDataSets = 'T';
	FixedFieldCount = 0;
	LeftFieldCount = 0;
	
	
	select a.IGNOREINVISIBLEINVKV from vkuser a where a.USERID=:IN_UserKey into :tmpIGNOREINVISIBLEINVKV;
	EXECUTE PROCEDURE UFGETTEMPLATEIDBYUSER(:IN_UserKey) RETURNING_VALUES(:TemplateID);
	
	SELECT	COUNT(*)
	FROM	GRIDDISPLAYFIELD
	WHERE	USERKEY = :IN_UserKey
	AND		GRIDDATASOURCE = :IN_GridDataSource
	INTO	:ROWCOUNT;

    --for 'display valve's columns in Part page'
	IF(IN_GridDataSource = 'uspGetParts' OR IN_GridDataSource = 'uspGetARs' OR IN_GridDataSource = 'uspGetWelds' OR IN_GridDataSource = 'uspGetPositioners' OR IN_GridDataSource = 'uspGetGenerics' OR IN_GridDataSource = 'uspGetToDoList') THEN 
		BEGIN
			SELECT  CASE SELECTEDVALVETYPE 
						WHEN 0 THEN :IN_GridDataSource || 'ReliefD' 
						WHEN 1 THEN :IN_GridDataSource || 'CV' 
						WHEN 4 THEN :IN_GridDataSource || 'MOV' 
						WHEN 5 THEN :IN_GridDataSource || 'LINEV'
						ELSE :IN_GridDataSource || 'ReliefD' 
					END
			
			FROM    USERPREFERENCE
			WHERE	USERKEY = :IN_UserKey
			INTO	:EquipTypeAndValve ;
		END		

	IF (IN_GridDataSource = 'uspGetRVList') THEN
	BEGIN
		EquipType = 'RELIEFD';
	END
	ELSE IF(IN_GridDataSource = 'uspGetCVList') THEN
	BEGIN
		EquipType = 'CV';
	END
	ELSE IF(IN_GridDataSource = 'uspGetMOVList') THEN
	BEGIN
		EquipType = 'MOV';
	END
	ELSE IF(IN_GridDataSource = 'uspGetLVList') THEN
	BEGIN
		EquipType = 'LINEV';
	END
	ELSE
	BEGIN
		SELECT  CASE SELECTEDVALVETYPE 
					WHEN 0 THEN 'RELIEFD' 
					WHEN 1 THEN 'CV' 
					WHEN 4 THEN 'MOV' 
					WHEN 5 THEN 'LINEV'
					ELSE 'RELIEFD'
				END		
		FROM    USERPREFERENCE
		WHERE	USERKEY = :IN_UserKey
		INTO	EquipType;
	END
	
	IF (ROWCOUNT = 0) THEN
	BEGIN
		INSERT INTO GRIDDISPLAYFIELD
			(
					USERKEY,
					GRIDDATASOURCE,
					DATATABLE,
					FIELDNAME,
					FIELDNUM,
					FIELDWIDTH,
					SEQNO,
					CREATEDATE,
					EDITDATE
			)
		SELECT	:IN_UserKey,
				GRIDDATASOURCE,
				DATATABLE,
				FIELDNAME,
				FIELDNUM,
				"VALUE",
				SEQNO,
				:EditDate AS CreateDate,				
				:EditDate AS EditDate
		FROM	GRIDDEFAULTFIELD
		WHERE	GRIDDATASOURCE = :IN_GridDataSource
		AND		QUERYTYPE = 'SELECT'
		AND		"SHOW" = 'T'
		AND		SEQNO > 0;
	END
	
	IF (IN_MRTYPE IS NULL OR IN_MRTYPE ='') then
	begin
        SELECT	COUNT(*)
        FROM	GRIDSORTFIELD
        WHERE	USERKEY = :IN_UserKey
        AND		GRIDDATASOURCE = :IN_GridDataSource
        INTO	:ROWCOUNT;
        
        -- Imports default sort fields
        IF (ROWCOUNT = 0) THEN
        BEGIN
            INSERT INTO GRIDSORTFIELD
                (
                        USERKEY,
                        GRIDDATASOURCE,
                        FIELDNAME,
                        ORDERVALUE,
                        SEQNO,
                        CREATEDATE,
                        EDITDATE
                )
            SELECT	:IN_UserKey,
                    GRIDDATASOURCE,
                    FIELDNAME,
                    "VALUE",
                    SEQNO,
                    :EditDate AS CreateDate,				
                    :EditDate AS EditDate
            FROM	GRIDDEFAULTFIELD
            WHERE	GRIDDATASOURCE = :IN_GridDataSource
            AND		QUERYTYPE = 'SORT'
            AND		"SHOW" = 'T'
            AND		SEQNO > -1;
        END
	end
	ELSE 
	begin
        SELECT	COUNT(*)
        FROM	GRIDSORTFIELD
        WHERE	USERKEY = :IN_UserKey
        AND		GRIDDATASOURCE = (:IN_GridDataSource||'ONEEQUIPMENT')
        INTO	:ROWCOUNT;
        
        -- Imports default sort fields
        IF (ROWCOUNT = 0) THEN
        BEGIN
            INSERT INTO GRIDSORTFIELD
                (
                        USERKEY,
                        GRIDDATASOURCE,
                        FIELDNAME,
                        ORDERVALUE,
                        SEQNO,
                        CREATEDATE,
                        EDITDATE
                )
            SELECT	:IN_UserKey,
                    (GRIDDATASOURCE||'ONEEQUIPMENT'),
                    FIELDNAME,
                    "VALUE",
                    SEQNO,
                    :EditDate AS CreateDate,				
                    :EditDate AS EditDate
            FROM	GRIDDEFAULTFIELD
            WHERE	GRIDDATASOURCE = :IN_GridDataSource
            AND		QUERYTYPE = 'SORT'
            AND		"SHOW" = 'T'
            AND		SEQNO > -1
			AND FIELDNAME IN ('MOSTRECENT','DATETESTEDEFFECTIVE');
        END
	end
	
	
	
	
	
    SELECT FLPLevel FROM VKUser WHERE UserID = :IN_UserKey INTO :FLevel;

	INSERT INTO TEMPGRIDFIELD(  FIELDNAME,
								 USERNAME,
								 FIELDNUM,
								 FIELDWIDTH,
								 SEQNO,
								 VISIBLE,
								 FIELDTYPE,
								 DATATABLE,
								 CREATEDATE)
	SELECT	gdf.FIELDNAME,
			--COALESCE(fde.USERNAME, gde.DISPLAYNAME) AS USERNAME,
			CASE gdf.FIELDNAME WHEN  'COMMENTPREVIOUSEVENT' 
			 THEN REPLACE('Comment - Previous Event','Comment',(select f.USERNAME from FIELDDEFINITION f 
			where f.TEMPLATEID = :TemplateID AND f.FIELDNUMBER = 
			(CASE :IN_GridDataSource
			WHEN 'uspGetCVList' THEN 252
			WHEN 'uspGetRVList' THEN 96
			WHEN 'uspGetMOVList' THEN 1216
			WHEN 'uspGetLVList' THEN 1529 END)
			)) 
			else
			COALESCE(fde.USERNAME, gde.DISPLAYNAME)
			end AS USERNAME,
			COALESCE(gdf.FIELDNUM, 9999) AS FIELDNUM,
			gdf.FIELDWIDTH, 
			gdf.SEQNO, 
			1 AS VISIBLE,
			gde.FIELDTYPE,
			gdf.DATATABLE,
			:CREATEDATE
	FROM	GRIDDISPLAYFIELD gdf
	LEFT JOIN	GRIDDEFAULTFIELD gde ON (gde.GRIDDATASOURCE = :IN_GridDataSource
									 AND gde.QUERYTYPE = 'SELECT'
									 AND gde.FIELDNAME = gdf.FIELDNAME)
	LEFT JOIN	FIELDDEFINITION fde ON (fde.TEMPLATEID = :TemplateID
									AND fde.FIELDNUMBER = gdf.FIELDNUM)
	LEFT JOIN   FLP ON (FLP.FLPLEVEL = :FLevel AND FLP.FieldNumber = fde.FieldNumber)	
	WHERE	gdf.USERKEY = :IN_UserKey
    AND		(
				gdf.GRIDDATASOURCE = :IN_GridDataSource 
				OR  
				( (:IN_GridDataSource = 'uspGetParts' OR :IN_GridDataSource = 'uspGetARs' OR :IN_GridDataSource = 'uspGetWelds' OR :IN_GridDataSource = 'uspGetPositioners' OR :IN_GridDataSource = 'uspGetGenerics' OR :IN_GridDataSource = 'uspGetToDoList') AND gdf.GRIDDATASOURCE = :EquipTypeAndValve)
			)
	AND		(:IN_QueryType IS NULL OR :IN_QueryType = 'SELECT')
	AND		((FLP.CanView = 1 OR FLP.CanView IS NULL) AND (fde.VISIBLE = 'T' OR fde.VISIBLE IS NULL))
	AND     ((gdf.FIELDNAME NOT LIKE 'CDMEAS%' AND :IN_SHOWCDMEAS = 'F') OR :IN_SHOWCDMEAS = 'T')
	AND     ((gdf.FIELDNAME NOT LIKE 'CDMFG%' AND :IN_SHOWCDMFG = 'F') OR :IN_SHOWCDMFG = 'T')
	AND     ((gdf.FIELDNAME NOT LIKE 'CDSHIP%' AND :IN_SHOWCDSHIPPED = 'F') OR :IN_SHOWCDSHIPPED = 'T')
	AND     ((gdf.FIELDNAME NOT IN ('PARTSCOST', 'MISCCOST', 'LABORCOST', 'HANDLINGCOST', 'TOTALCOST', 'PRICE', 'EXTPRICE', 'COST', 'EXTCOST') AND :IN_SHOWCOST = 'F') OR :IN_SHOWCOST = 'T')
	ORDER BY SEQNO;
	
	INSERT INTO TEMPGRIDFIELD(  FIELDNAME,
								 USERNAME,
								 FIELDNUM,
								 FIELDWIDTH,
								 SEQNO,
								 VISIBLE,
								 FIELDTYPE,
								 DATATABLE,
								 CREATEDATE)
	SELECT	gdf.FIELDNAME,
			--COALESCE(fde.USERNAME, gdf.DISPLAYNAME) AS USERNAME,
			CASE gdf.FIELDNAME WHEN  'COMMENTPREVIOUSEVENT' 
			 THEN REPLACE('Comment - Previous Event','Comment',(select f.USERNAME from FIELDDEFINITION f 
			where f.TEMPLATEID = :TemplateID AND f.FIELDNUMBER = 
			(CASE :IN_GridDataSource
			WHEN 'uspGetCVList' THEN 252
			WHEN 'uspGetRVList' THEN 96
			WHEN 'uspGetMOVList' THEN 1216
			WHEN 'uspGetLVList' THEN 1529 END)
			)) 
			else
			COALESCE(fde.USERNAME, gdf.DISPLAYNAME)
			end AS USERNAME,
			COALESCE(gdf.FIELDNUM, 9999) AS FIELDNUM,
			gdf."VALUE",
			0 AS SEQNO,
			0 AS VISIBLE,
			gdf.FIELDTYPE,
			gdf.DATATABLE,
			:CREATEDATE
	FROM	GRIDDEFAULTFIELD gdf
	LEFT JOIN	FIELDDEFINITION fde ON (fde.TEMPLATEID = :TemplateID
									AND fde.FIELDNUMBER = gdf.FIELDNUM)
	LEFT JOIN   FLP ON (FLP.FLPLEVEL = :FLevel AND FLP.FieldNumber = fde.FieldNumber)
	WHERE	(
				gdf.GRIDDATASOURCE = :IN_GridDataSource 
				OR  
				((:IN_GridDataSource = 'uspGetParts' OR :IN_GridDataSource = 'uspGetARs' OR :IN_GridDataSource = 'uspGetWelds' OR :IN_GridDataSource = 'uspGetPositioners' OR :IN_GridDataSource = 'uspGetGenerics' OR :IN_GridDataSource = 'uspGetToDoList') AND gdf.GRIDDATASOURCE = :EquipTypeAndValve)
			)
	AND		gdf.QUERYTYPE = 'SELECT'
	AND		(:IN_QueryType IS NULL OR :IN_QueryType = 'SELECT')
	AND		((FLP.CanView = 1 OR FLP.CanView IS NULL) AND (fde.VISIBLE = 'T' OR fde.VISIBLE IS NULL))
	AND     ((gdf.FIELDNAME NOT LIKE 'CDMEAS%' AND :IN_SHOWCDMEAS = 'F') OR :IN_SHOWCDMEAS = 'T')
	AND     ((gdf.FIELDNAME NOT LIKE 'CDMFG%' AND :IN_SHOWCDMFG = 'F') OR :IN_SHOWCDMFG = 'T')
	AND     ((gdf.FIELDNAME NOT LIKE 'CDSHIP%' AND :IN_SHOWCDSHIPPED = 'F') OR :IN_SHOWCDSHIPPED = 'T')
	AND     ((gdf.FIELDNAME NOT IN ('PARTSCOST', 'MISCCOST', 'LABORCOST', 'HANDLINGCOST', 'TOTALCOST', 'PRICE', 'EXTPRICE', 'COST', 'EXTCOST') AND :IN_SHOWCOST = 'F') OR :IN_SHOWCOST = 'T')
	AND		gdf."SHOW" = 'T'	
	and     ((:tmpIGNOREINVISIBLEINVKV='T') or (:tmpIGNOREINVISIBLEINVKV <> 'T' and gdf.FIELDNAME<>'INVISIBLEINVKV'))
	AND	NOT EXISTS	(SELECT	*
					 FROM	GRIDDISPLAYFIELD gdi
					 WHERE	gdi.USERKEY = :IN_UserKey
					 AND	gdi.GRIDDATASOURCE = gdf.GRIDDATASOURCE
					 AND	gdi.FIELDNAME = gdf.FIELDNAME);
					 
	IF (IN_IncludeCusFields = 'T') THEN
	BEGIN
		INSERT INTO TEMPGRIDFIELD(  FIELDNAME,
									 USERNAME,
									 FIELDNUM,
									 FIELDWIDTH,
									 SEQNO,
									 VISIBLE,
									 FIELDTYPE,
									 CREATEDATE)
		SELECT	gcf.FIELDNAME,
				gcf.FIELDCAPTION,
				9999 AS FIELDNUM,
				150 AS FIELDWIDTH,
				0 AS SEQNO,
				0 AS VISIBLE,
				'' AS FIELDTYPE,
				:CREATEDATE
		FROM	GRIDCUSTOMIZEDFIELD gcf
		WHERE	gcf.USERKEY = :IN_UserKey
		AND		gcf.GRIDDATASOURCE = :IN_GridDataSource
		AND		(:IN_QueryType IS NULL OR :IN_QueryType = 'SELECT')
		AND	NOT EXISTS	(SELECT	*
						 FROM	GRIDDISPLAYFIELD gdf
						 WHERE	gdf.USERKEY = gcf.USERKEY
						 AND	gdf.GRIDDATASOURCE = gcf.GRIDDATASOURCE
						 AND	gdf.FIELDNAME = gcf.FIELDNAME);
	END
	ELSE
	BEGIN
		DELETE
		FROM	TEMPGRIDFIELD tgf
		WHERE	CREATEDATE = :CREATEDATE
		AND		(FIELDNAME = 'CALCULATEDDATE'
		OR		EXISTS	(SELECT	*
						 FROM	GRIDCUSTOMIZEDFIELD gcf
						 WHERE	gcf.USERKEY = :IN_UserKey
						 AND	gcf.GRIDDATASOURCE = :IN_GridDataSource
						 AND	gcf.FIELDNAME = tgf.FIELDNAME));
	END
	
	IF (IN_GridDataSource = 'uspGetRVList') THEN
	BEGIN
		DELETE
		FROM	TEMPGRIDFIELD tgf
		WHERE	CREATEDATE = :CREATEDATE
		AND		FIELDNAME = 'VALVESIZE'
		AND		2 <> (	SELECT	COUNT(*)
						FROM	TEMPGRIDFIELD
						WHERE	CREATEDATE = :CREATEDATE
						AND		FIELDNAME IN ('INLETSIZE', 'OUTLETSIZE')
						AND		USERNAME <> '');
	END

	UPDATE	TEMPGRIDFIELD tgf
	SET		USERNAME = COALESCE((SELECT	'AR_' || fde.USERNAME
								 FROM	FIELDDEFINITION fde
								 WHERE	fde.TEMPLATEID = :TemplateID
								 AND	fde.FIELDNUMBER = tgf.FIELDNUM), tgf.USERNAME)
	WHERE	CREATEDATE = :CREATEDATE
	AND		tgf.FIELDNAME BETWEEN 'AR_' AND 'AR`';
	
	UPDATE	TEMPGRIDFIELD tgf
	SET		USERNAME = COALESCE((SELECT	gcf.FIELDCAPTION
								 FROM	GRIDCUSTOMIZEDFIELD gcf
								 WHERE	gcf.USERKEY = :IN_UserKey
								 AND	gcf.GRIDDATASOURCE = :IN_GridDataSource
								 AND	gcf.FIELDNAME = tgf.FIELDNAME), tgf.USERNAME)
	WHERE	CREATEDATE = :CREATEDATE;

	UPDATE	TEMPGRIDFIELD tgf
	SET		USERNAME = COALESCE((SELECT	fde.USERNAME
								 FROM	FIELDDEFINITION fde
								 JOIN   FLP ON (FLP.FLPLEVEL = :FLevel 
											AND FLP.FieldNumber = fde.FieldNumber)
								 WHERE	fde.TEMPLATEID = :TemplateID
								 AND	fde.DATATABLE = :EquipType
								 AND	fde.DATAFIELD = 'TAGNUMBER'
								 AND	(FLP.CanView = 1 OR FLP.CanView IS NULL) 
								 AND	(fde.VISIBLE = 'T' OR fde.VISIBLE IS NULL)), '')
	WHERE	CREATEDATE = :CREATEDATE
	AND		FIELDNAME = 'TAGNUMBER';	

	UPDATE	TEMPGRIDFIELD tgf
	SET		USERNAME = USERNAME || '-Year'
	WHERE	CREATEDATE = :CREATEDATE
	AND		FIELDNAME IN ('DATETESTED_YYYY', 'DATERECEIVED_YYYY', 'NEXTMAINDATE_YYYY', 'NEXTTESTDATE_YYYY');

	UPDATE	TEMPGRIDFIELD tgf
	SET		USERNAME = USERNAME || '-YY/MM'
	WHERE	CREATEDATE = :CREATEDATE
	AND		FIELDNAME IN ('DATETESTED_YYMM', 'DATERECEIVED_YYMM', 'NEXTMAINDATE_YYMM', 'NEXTTESTDATE_YYMM');
	
	SELECT	FIXEDFIELDCOUNT
	FROM	GRIDDATASOURCE
	WHERE   GRIDDATASOURCE = :IN_GridDataSource
	INTO	:FixedFieldCount;
	
	SELECT	"COUNT"
	FROM	GRIDLEFTFIELD
	WHERE	USERKEY = :IN_UserKey
	AND		GRIDDATASOURCE = :IN_GridDataSource
	INTO	:LeftFieldCount;
		

    IF(IN_GridDataSource = 'uspGetParts' OR IN_GridDataSource = 'uspGetARs' OR IN_GridDataSource = 'uspGetWelds' OR IN_GridDataSource = 'uspGetPositioners' OR IN_GridDataSource = 'uspGetGenerics' OR IN_GridDataSource = 'uspGetToDoList') THEN
        BEGIN
              SELECTSQL = 'SELECT A.* FROM 
          (SELECT	distinct FIELDNAME,FIELDNUM,
                USERNAME,USERNAME AS USERNAME_FORORDERINLAST,
                FIELDWIDTH,SEQNO,VISIBLE, FIELDTYPE, DATATABLE FROM TEMPGRIDFIELD WHERE (USERNAME IS NOT NULL OR USERNAME <> ''AR_'') AND upper(DATATABLE) NOT IN ('''|| EquipType ||''') AND CREATEDATE=''' || CREATEDATE || ''' ORDER BY VISIBLE DESC,SEQNO,UPPER(USERNAME)) A
                union ALL
          SELECT B.* FROM 
          (
                SELECT	distinct FIELDNAME,FIELDNUM,
                CASE DATATABLE WHEN ''ReliefD'' THEN USERNAME||''*'' 
                WHEN ''CV'' THEN USERNAME||''*'' 
                WHEN ''LINEV'' THEN USERNAME||''*'' 
                WHEN ''MOV'' THEN USERNAME||''*'' 
                ELSE USERNAME END AS USERNAME,
                CASE DATATABLE WHEN ''ReliefD'' THEN ''_____''||USERNAME
                WHEN ''CV'' THEN ''_____''||USERNAME
                WHEN ''LINEV'' THEN ''_____''||USERNAME 
                WHEN ''MOV'' THEN ''_____''||USERNAME 
                ELSE USERNAME END AS USERNAME_FORORDERINLAST,
                FIELDWIDTH,SEQNO,VISIBLE, FIELDTYPE, DATATABLE FROM TEMPGRIDFIELD WHERE (USERNAME IS NOT NULL OR USERNAME <> ''AR_'') AND upper(DATATABLE) IN ('''|| EquipType ||''') AND CREATEDATE=''' || CREATEDATE || ''' ORDER BY VISIBLE DESC,USERNAME_FORORDERINLAST,USERNAME ASC,SEQNO,UPPER(USERNAME)) B';
            END
      ELSE
          BEGIN
                SELECTSQL = 'SELECT	FIELDNAME,FIELDNUM,
                USERNAME,
                FIELDWIDTH,SEQNO,VISIBLE, FIELDTYPE, DATATABLE FROM TEMPGRIDFIELD WHERE (USERNAME IS NOT NULL OR USERNAME <> ''AR_'') AND CREATEDATE=''' || CREATEDATE || ''' ORDER BY VISIBLE DESC,SEQNO,UPPER(USERNAME)';
          END


	IF (IN_QueryType IS NULL) THEN
	BEGIN
        IF (IN_MRTYPE IS NULL OR IN_MRTYPE ='') then
        begin
            SORTTSQL = 'SELECT g.FIELDNAME, t.USERNAME, ORDERVALUE,g.SEQNO FROM	GRIDSORTFIELD g LEFT JOIN  TEMPGRIDFIELD t ON g.FIELDNAME = t.FIELDNAME	WHERE USERKEY = ''' || IN_UserKey 
            || ''' AND GRIDDATASOURCE = ''' || IN_GridDataSource || ''' AND t.CREATEDATE=''' || CREATEDATE || '''	ORDER BY SEQNO;';
        end
        else
        begin
            SORTTSQL = 'SELECT g.FIELDNAME, t.USERNAME, ORDERVALUE,g.SEQNO FROM	GRIDSORTFIELD g LEFT JOIN  TEMPGRIDFIELD t ON g.FIELDNAME = t.FIELDNAME	WHERE USERKEY = ''' || IN_UserKey 
            || ''' AND GRIDDATASOURCE = ''' || (IN_GridDataSource||'ONEEQUIPMENT') || ''' AND t.CREATEDATE=''' || CREATEDATE || '''	ORDER BY SEQNO;';
        end
		
		FILTERSQL ='SELECT FIRST 1 UNIQUEKEY,FILTERNAME,FILTERVALUE,FILTERSQLVALUE,FILTERTEXT,IIF(MOSTRECENT = ''T'',1,0) AS MOSTRECENT FROM GRIDFILTER WHERE USERKEY = ''' || IN_UserKey || ''' AND GRIDDATASOURCE = ''' || IN_GridDataSource || ''' AND MOSTRECENT = ''T'';';
	END
	ELSE
	BEGIN
         IF (IN_MRTYPE IS NULL OR IN_MRTYPE ='') then
        begin
            SORTTSQL = 'SELECT g.FIELDNAME, t.USERNAME, ORDERVALUE,g.SEQNO FROM	GRIDSORTFIELD g LEFT JOIN  TEMPGRIDFIELD t ON g.FIELDNAME = t.FIELDNAME WHERE	USERKEY = ''' || IN_UserKey 
            || ''' AND GRIDDATASOURCE = ''' || IN_GridDataSource || ''' AND ''' || IN_QueryType || ''' = ''SORT''  AND t.CREATEDATE=''' || CREATEDATE || ''' ORDER BY SEQNO;';
        end
        else
        begin
            SORTTSQL = 'SELECT g.FIELDNAME, t.USERNAME, ORDERVALUE,g.SEQNO FROM	GRIDSORTFIELD g LEFT JOIN  TEMPGRIDFIELD t ON g.FIELDNAME = t.FIELDNAME WHERE	USERKEY = ''' || IN_UserKey 
            || ''' AND GRIDDATASOURCE = ''' || (IN_GridDataSource||'ONEEQUIPMENT') || ''' AND ''' || IN_QueryType || ''' = ''SORT''  AND t.CREATEDATE=''' || CREATEDATE || ''' ORDER BY SEQNO;';
        end
        
		
		FILTERSQL ='SELECT FIRST 1 UNIQUEKEY,FILTERNAME,FILTERVALUE,FILTERSQLVALUE,FILTERTEXT,IIF(MOSTRECENT = ''T'',1,0) AS MOSTRECENT FROM GRIDFILTER WHERE USERKEY = ''' || IN_UserKey 
            || ''' AND GRIDDATASOURCE = ''' || IN_GridDataSource || ''' AND MOSTRECENT = ''T'' AND ''' || IN_QueryType || ''' = ''FILTER'';';
	END	

	COUNTSQL = 'SELECT FIRST 1 ' || FixedFieldCount || ' AS FIXEDFIELDCOUNT,' || LeftFieldCount || ' AS LEFTFIELDCOUNT FROM RDB$DATABASE;';
	
	SUSPEND;	
END^
SET TERM ; ^


GRANT EXECUTE
 ON PROCEDURE USPGETGRIDFIELD TO  SYSDBA;

