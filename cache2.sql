SET TERM ^ ;
ALTER PROCEDURE USPPREPAREGRIDFIELDSNOCOUNTCUST (
    IN_USERKEY Varchar(36),
    IN_GRIDDATASOURCE Varchar(200),
    IN_REPAIRLISTGRIDDATASOURCES Varchar(200) )
RETURNS (
    CREATEDATE Varchar(30) )
AS
/*******************************************************************
**SELECT p.CREATEDATE
FROM USPPREPAREGRIDFIELDSNOCOUNTCUST('353743451427512407', '', 'uspGetRVList') p

select * from TEMPGRIDFIELD;
*******************************************************************************
**  Change History
*******************************************************************************
**Robin Lu	    2017/01/04	n/a.        for US174309--VKV Release: fix bug for "verify current maintenance intervals" analysis with "equipment track id" in grid - VKViewer
**Ben Song      2018/02/13  n/a.
**	 Ben Song	   2018/03/02		US298454    VKV:New columns: Previous event's Date Tested and Maint For
********************************************************************/
DECLARE VARIABLE EDITDATE Varchar(10);
DECLARE VARIABLE TemplateID VARCHAR(36);
DECLARE VARIABLE FLevel smallint;
DECLARE VARIABLE POS Integer;
DECLARE VARIABLE ROWCOUNT Integer;
DECLARE VARIABLE SeqIndex1 Integer;
DECLARE VARIABLE SeqIndex2 Integer;
DECLARE VARIABLE EquipType varchar(100);
BEGIN
	CREATEDATE = CAST (CURRENT_TIMESTAMP AS VARCHAR(30));
	EDITDATE = REPLACE(CAST(CURRENT_DATE AS VARCHAR(10)),'-','/');
	
    POS = POSITION(',' IN IN_RepairListGridDataSources);
			
	EXECUTE PROCEDURE UFGETTEMPLATEIDBYUSER(:IN_UserKey) RETURNING_VALUES(:TemplateID);
	
    SELECT FLPLevel FROM VKUser WHERE UserID = :IN_UserKey INTO :FLevel;

	DELETE FROM TEMPGRIDFIELD;

	IF (IN_GridDataSource = 'uspGetNextMaintList' OR IN_GridDataSource = 'uspGetRepairPerfList') THEN
	BEGIN
		SeqIndex1 = 0;
		SeqIndex2 = 10000;
	END
	ELSE
	BEGIN
		SeqIndex1 = 10000;
		SeqIndex2 = 0;
	END

	IF(POS = 0) THEN
	BEGIN
		IF (IN_RepairListGridDataSources = 'uspGetRVList') THEN
		BEGIN
			EquipType = 'RELIEFD';
		END
		ELSE IF(IN_RepairListGridDataSources = 'uspGetCVList') THEN
		BEGIN
			EquipType = 'CV';
		END
		ELSE IF(IN_RepairListGridDataSources = 'uspGetMOVList') THEN
		BEGIN
			EquipType = 'MOV';
		END
		ELSE IF(IN_RepairListGridDataSources = 'uspGetLVList') THEN
		BEGIN
			EquipType = 'LINEV';
		END
		ELSE
		BEGIN
			EquipType = 'RELIEFD';
		END
		--Preapre specific columns for IN_GridDataSource(eg, uspGetRVPressure)
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
				IIF(COALESCE(fde.USERNAME, '') = '', gdf.DISPLAYNAME, fde.USERNAME) AS USERNAME,
				COALESCE(fde.FieldNumber, 9999) AS FIELDNUM,
				gdf."VALUE",
				:SeqIndex1 + gdf.SEQNO AS SEQNO,
				(CASE WHEN FLP.CanView = 0 THEN 0 ELSE 1 END) AS VISIBLE,
				gdf.FIELDTYPE,
				gdf.DATATABLE,
				:CREATEDATE
		FROM	GRIDDEFAULTFIELD gdf
		LEFT JOIN	FIELDDEFINITION fde  ON (fde.TEMPLATEID = :TemplateID
										 AND fde.DATATABLE = :EquipType
										 AND fde.DATAFIELD = gdf.FIELDNAME)
		LEFT JOIN   FLP ON (FLP.FLPLEVEL = :FLevel 
						AND FLP.FieldNumber = fde.FieldNumber)
		WHERE	gdf.GRIDDATASOURCE = :IN_GridDataSource
		AND		gdf.QUERYTYPE = 'SELECT'
		AND		gdf."SHOW" = 'T'
		AND		gdf.FIELDNAME <> 'EQUIPTYPE'
		ORDER BY SEQNO;

		SELECT	COUNT(*)
		FROM	GRIDDISPLAYFIELD
		WHERE	USERKEY = :IN_UserKey
		AND		GRIDDATASOURCE = :IN_RepairListGridDataSources
		INTO	:ROWCOUNT;
	
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
			WHERE	GRIDDATASOURCE = :IN_RepairListGridDataSources
			AND		QUERYTYPE = 'SELECT'
			AND		"SHOW" = 'T'
			AND		SEQNO > 0;
		END

		--Prepare specific columns for IN_RepairListGridDataSource (main grid columns)
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
				IIF(COALESCE(fde.USERNAME, '') = '', gde.DISPLAYNAME, fde.USERNAME) AS USERNAME,
				COALESCE(gdf.FIELDNUM, 9999) AS FIELDNUM,
				gdf.FIELDWIDTH, 
				:SeqIndex2 + gdf.SEQNO AS SEQNO, 
				(CASE WHEN FLP.CanView = 0 THEN 0 ELSE 1 END) AS VISIBLE,
				gde.FIELDTYPE,
				gdf.DATATABLE,
				:CREATEDATE
		FROM	GRIDDISPLAYFIELD gdf
		LEFT JOIN	GRIDDEFAULTFIELD gde ON (gde.GRIDDATASOURCE = gdf.GRIDDATASOURCE
										 AND gde.QUERYTYPE = 'SELECT'
										 AND gde.FIELDNAME = gdf.FIELDNAME)
		LEFT JOIN	FIELDDEFINITION fde ON (fde.TEMPLATEID = :TemplateID
										AND fde.FIELDNUMBER = gdf.FIELDNUM)
		LEFT JOIN   FLP ON (FLP.FLPLEVEL = :FLevel AND FLP.FieldNumber = fde.FieldNumber)	
		WHERE	gdf.USERKEY = :IN_UserKey
		AND		gdf.GRIDDATASOURCE = :IN_RepairListGridDataSources
		--	Robin Lu	    2017/01/04	n/a.        for US174309--VKV Release: fix bug for "verify current maintenance intervals" analysis with "equipment track id" in grid - VKViewer
		AND		gdf.FIELDNAME NOT IN ('TODOCOUNT','ARCOUNT','GENERICCOUNT','IMAGECOUNT','PARTCOUNT','PARTNOTGOODCOUNT','PARTONORDERCOUNT',
		'PARTREPLACEDCOUNT','PARTTOREPLACECOUNT','EVENTCOUNT','VALVESIZE','NEXTMAINDATE_YYYY','NEXTMAINDATE_YYMM','NEXTTESTDATE_YYYY',
		'NEXTTESTDATE_YYMM','DATETESTED_YYYY','DATETESTED_YYMM','DATERECEIVED_YYYY','DATERECEIVED_YYMM','DATETESTEDEFFECTIVE','SINCETESTED',
		'PASTDUE','MONTHSGAP','TILLDUE', 'PRETEST_AVERAGE', 'FINALTEST_AVERAGE', 'MONTHGAPPREVNPDATE','MONTHGAPPREVTESTNPDATE','COMMENTPREVIOUSEVENT',
		'PARTCOUNTPREVIOUSEVENT','PRENEXTMAINDATE','PRENEXTTESTDATE','MTHSGAPPREEVTNXTMAINTEST','MTHSGAPPREEVTNXTTESTTEST','PREMAINTFOR','PREDATETESTED')
		AND	NOT EXISTS	(SELECT	*
						 FROM	TEMPGRIDFIELD tgf
						 WHERE	tgf.FIELDNAME = gdf.FIELDNAME  
						 AND	tgf.CREATEDATE = :CREATEDATE)
		ORDER BY SEQNO;
	END
	ELSE
	BEGIN
		SELECT	case SELECTEDVALVETYPE when 0 then 'RELIEFD' when 1 then 'CV' when 4 then 'MOV' when 5 then 'LINEV' end
		FROM	USERPREFERENCE
		WHERE	USERKEY = :IN_UserKey
		INTO	:EquipType;

		EquipType = COALESCE(EquipType, 'RELIEFD');

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
				IIF(COALESCE(fde.USERNAME, '') = '', gdf.DISPLAYNAME, fde.USERNAME) AS USERNAME,
				COALESCE(fde.FieldNumber, 9999) AS FIELDNUM,
				gdf."VALUE",
				:SeqIndex1 + gdf.SEQNO AS SEQNO, 
				(CASE WHEN FLP.CanView = 0 THEN 0 ELSE 1 END) AS VISIBLE,
				gdf.FIELDTYPE,
				gdf.DATATABLE,
				:CREATEDATE
		FROM	GRIDDEFAULTFIELD gdf
		LEFT JOIN	FIELDDEFINITION fde  ON (fde.TEMPLATEID = :TemplateID
										 AND fde.DATATABLE = :EquipType
										 AND fde.DATAFIELD = gdf.FIELDNAME)
		LEFT JOIN   FLP ON (FLP.FLPLEVEL = :FLevel 
						AND FLP.FieldNumber = fde.FieldNumber)	
		WHERE	gdf.GRIDDATASOURCE = :IN_GridDataSource
		AND		gdf.QUERYTYPE = 'SELECT'
		AND		gdf."SHOW" = 'T'		
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
				IIF(COALESCE(fde.USERNAME, '') = '', gde.DISPLAYNAME, fde.USERNAME) AS USERNAME,
				COALESCE(gdf.FIELDNUM, 9999) AS FIELDNUM,
				gdf.FIELDWIDTH, 
				:SeqIndex2 + gdf.SEQNO AS SEQNO, 
				(CASE WHEN FLP.CanView = 0 THEN 0 ELSE 1 END) AS VISIBLE,
				gde.FIELDTYPE,
				gdf.DATATABLE,
				:CREATEDATE
		FROM	GRIDDISPLAYFIELD gdf
		LEFT JOIN	GRIDDEFAULTFIELD gde ON (gde.GRIDDATASOURCE = gdf.GRIDDATASOURCE
										 AND gde.QUERYTYPE = 'SELECT'
										 AND gde.DATATABLE = gdf.DATATABLE
										 AND gde.FIELDNAME = gdf.FIELDNAME)
		LEFT JOIN	FIELDDEFINITION fde ON (fde.TEMPLATEID = :TemplateID
										AND fde.FIELDNUMBER = gdf.FIELDNUM)
		LEFT JOIN   FLP ON (FLP.FLPLEVEL = :FLevel AND FLP.FieldNumber = fde.FieldNumber)	
		WHERE	gdf.USERKEY = :IN_UserKey
		AND		:IN_RepairListGridDataSources containing (gdf.GRIDDATASOURCE)
		AND		gdf.FIELDNAME  IN ('TAGNUMBER','UNIT','SERIAL','EQUIPLOCN','STATUS','JOBNUMBER','MODELNUMBER','MANUFACTURER','RISK','DATETESTED','NEXTMAINDATE','NEXTTESTDATE')
		AND	NOT EXISTS	(SELECT	*
						 FROM	TEMPGRIDFIELD tgf
						 WHERE	tgf.FIELDNAME = gdf.FIELDNAME--Common fields, ignore DATATABLE
						 AND	tgf.CREATEDATE = :CREATEDATE)
		ORDER BY SEQNO;

	END
	
	UPDATE	TEMPGRIDFIELD tgf
	SET		USERNAME = COALESCE((SELECT	'AR_' || fde.USERNAME
								 FROM	FIELDDEFINITION fde
								 WHERE	fde.TEMPLATEID = :TemplateID
								 AND	fde.FIELDNUMBER = tgf.FIELDNUM), tgf.USERNAME)
	WHERE	CREATEDATE = :CREATEDATE
	AND		tgf.FIELDNAME BETWEEN 'AR_' AND 'AR`';
 
END^
SET TERM ; ^ 

