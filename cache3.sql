create or replace PROCEDURE USPGETRVLISTBYUSER (
  IN_USERKEY IN VARCHAR2,    
  IN_ONLYSHOWMR IN CHAR,
  IN_RVKEY IN VARCHAR2 DEFAULT NULL,
  IN_PARTSREPLACED IN CHAR  DEFAULT NULL,
  IN_PARTSTOREPLACE IN CHAR  DEFAULT NULL,
  IN_PARTSONORDER IN CHAR  DEFAULT NULL,
  IN_PARTSNOTGOOD IN CHAR  DEFAULT NULL,
  IN_COMINGDUETYPE IN NUMBER DEFAULT NULL,
  IN_INCLUDEPASTDUE IN CHAR  DEFAULT NULL,
  IN_USINGFIELD IN VARCHAR2 DEFAULT NULL,
  IN_DATEFROM	IN VARCHAR2 DEFAULT NULL,
  IN_DATETO IN VARCHAR2 DEFAULT NULL,
  IN_ANDOR IN VARCHAR2 DEFAULT ' AND ',
  IN_IMAGE IN CHAR DEFAULT NULL,
  IN_GENERIC IN CHAR  DEFAULT NULL,
  IN_AR IN CHAR  DEFAULT NULL,
  IN_TODO IN CHAR  DEFAULT NULL,
  IN_INPART IN CHAR  DEFAULT NULL,
  IN_INAR IN CHAR  DEFAULT NULL,
  IN_INWELD IN CHAR  DEFAULT NULL,
  IN_INPOSITIONER IN CHAR  DEFAULT NULL,
  IN_INLOCATION IN CHAR  DEFAULT NULL,
  IN_INGENERIC IN CHAR  DEFAULT NULL,
  IN_INTODO IN CHAR  DEFAULT NULL,--for todo filter
  IN_FilterClause IN VARCHAR2 DEFAULT NULL,
  IN_Unit IN VARCHAR2 DEFAULT NULL,
  IN_LinkField IN VARCHAR2 DEFAULT NULL,	
	OUT_CURSOR OUT SYS_REFCURSOR)
AS
/******************************************************************************
**  File:        uspGetRVListByUser.sql
**  Description: Returns RV list
**  Returns:     
**  Params:      @UserID - The logged on users number
**               @OwnerKey
**				 @PlantKey
*******************************************************************************
**  Change History
*******************************************************************************
**	Author	        Date	    	    Description
**	Tony.Cai	    2010/05/04  	    Original.
**	Marco Cao		2014/08/07	        Add unit filter
**	Marco Cao       2015/02/17		    Convert it to oracle
**  Jerry Chen      2015/06/15          Modify xxxColumn variable length to 4000 because of buffer too small problem
**  Yukai Ji        2015/12/11          Refine the logic to make it clear 
**	Marco Cao    2016/09/27		Add USELEAKED
**	Marco Cao    2016/10/27		DateTestedEffectiveColumn
**	Jerry Chen		2016/11/03	N/A		US163569: implement the "events with parts filter" in VKC
**	Jerry Chen		2016/11/15	N/A		DE45329: Limit Grid To...: only display the repair which has parts if no part filter is applied
**	Jerry Chen	    2016/12/19		Month Gap between Prev NP last repair date and date tested/date recieved/date created
**	Robin Lu	    2017/3/9		to more better performance
**	Marco Cao    2017/03/10		PartLIFEtimeReplacedCountCol
**	Jerry Chen    2017/03/13	   VKC: generic and to-do "limit grid to" functions need to use the filter of the item too (like parts)
**	Jerry Chen 	2017/03/13		US198981	(copy of) VKC: in the "date filter" button, add "date tested effective comment: The Sql should be like below,
**	Marco Cao    2017/05/09		1=1  AND not (((DATETESTED) is null or length(DATETESTED) = 0))
**	Robin Lu    2017/09/18		add new column:Comment - Previous Event
**	Ben Song     2018/04/24     US284403    VKC: Issue with "# events" column
**	Ben Song     2018/05/17     32733:VKC:New columns: Previous event's Next Maint and Next Test Date

SELECT UNIQUEKEY,TENANTKEY..., --ALL Special Columns
FROM RELIEFD r INNER JOIN (
    SELECT UNIQUEKEY AS UNIQUEKEY2,TENANTKEY AS TENANTKEY2  FROM (
        SELECT UNIQUEKEY,TENANTKEY
        --select Special Columns if these columns are in order by clause 
        FROM RELIEFD r 
        WHERE  TENANTKEY= v_TenantKey
        AND --ReliefD's real column's filter clause; Pressure Analyze Columns and 3 special columns 'OwnerName, Location, Area''s filter clause             
        ORDER BY 'Columns' ) r WHERE  1=1    
    (1)--AND --ALL Special Columns' filter clause(except Owner Name, Location, Area;but include columns like ARCount,VALVESIZE)
    AND rownum < 5001      ) T ON r.UNIQUEKEY =T.UNIQUEKEY2 AND r.TENANTKEY = T.TENANTKEY2 
*******************************************************************************/
	RETMULDATASETS Char(1);
	V_SQL VARCHAR2(30000);
	V_SQL2 CLOB;
	V_BaseColumnsSQL CLOB;
	V_CREATEDATE VARCHAR2(30); 
	EditDate VARCHAR2(10);
	v_GridDataSource VARCHAR2(100);
	DateFilterClause CLOB;
	FilterCtrlClause CLOB;
	LimitSQL CLOB;-- (this variable will store the filter in Limit Grid To ... button.)
	LimitRownumSQL CLOB;
	FilterSQL CLOB;
	EquipKey VARCHAR2(36);
	ComingDueFrom VARCHAR2(10);
	ComingDueTo VARCHAR2(10);
	ImgCountChrs VARCHAR2(4000);
	GenCountChrs VARCHAR2(4000);
	ARCountChrs VARCHAR2(4000);
	ToDoCountChrs VARCHAR2(4000);	
	PartReplacedCountChrs VARCHAR2(4000);
	PartToPlaceCountChrs VARCHAR2(4000);
	PartOnOrderCountChrs VARCHAR2(4000);
	PartNotGoodCountChrs VARCHAR2(4000);
	PartsFilterCountChrs VARCHAR2(4000); 	
	GenericFilterCountChrs VARCHAR2(4000);
	ToDoFilterCountChrs VARCHAR2(4000);
	SelectedSpecialColumns CLOB;
	v_TempFilterString CLOB;
	v_ExistedFieldsFilterClause CLOB;
	v_SpecialColumnsFilterClause CLOB;
	v_Token VARCHAR2(3000);
	v_Token1 VARCHAR2(3000);
	v_PressureAnalyzeFilterClause CLOB;
	v_OtherSpecialFilterClause CLOB;
	SelectedColumns1 CLOB;
	SelectedColumns2 CLOB;--only displayed columns in all pressure analyze columns
	SelectedColumns3 CLOB;--all pressure analyze columns
	OwnerNameColumn VARCHAR2(4000);
	PlantLocationColumn VARCHAR2(4000);
	PlantAreaColumn VARCHAR2(4000);
	ImgCountColumn VARCHAR2(4000);
	GenCountColumn VARCHAR2(4000);
	ARCountColumn VARCHAR2(4000);
	ToDoCountColumn VARCHAR2(4000);
	PartCountColumn VARCHAR2(4000);
	PartReplacedCountColumn VARCHAR2(4000);
	PartLIFEtimeReplacedCountCol VARCHAR2(4000);
	CommentPreviousEventCol VARCHAR2(4000);
	PartToPlaceCountColumn VARCHAR2(4000);
	PartOnOrderCountColumn VARCHAR2(4000);
	PartNotGoodCountColumn VARCHAR2(4000);
	PartsFilterCountColumn VARCHAR2(4000); -- for PARTS filter
	GenericFilterCountColumn VARCHAR2(4000); -- for GENERIC filter
	ToDoFilterCountColumn VARCHAR2(4000); -- for TODO filter
	EventCountColumn VARCHAR2(4000);
	ValveSizeColumn VARCHAR2(4000);
	NextMainDateYYYYColumn VARCHAR2(4000);
	NextMainDateYYMMColumn VARCHAR2(4000);
	NextTestDateYYYYColumn VARCHAR2(4000);
	NextTestDateYYMMColumn VARCHAR2(4000);
	DateTestedYYYYColumn VARCHAR2(4000);
	DateTestedYYMMColumn VARCHAR2(4000);
	DateReceivedYYYYColumn VARCHAR2(4000);
	DateReceivedYYMMColumn VARCHAR2(4000);
	DateTestedEffectiveColumn VARCHAR2(4000);
	InvisibleVKVSql VARCHAR2(1000);
	SinceTestedColumn VARCHAR2(4000);
	PastDueColumn VARCHAR2(4000);
	TillDueColumn VARCHAR2(4000);
	MonthsGapColumn VARCHAR2(4000);
	PRETEST_AVERAGE_Column VARCHAR2(4000);
	FINAL_TEST_AVERAGE_Column VARCHAR2(4000);
	MONTHGAP_PREV_NPDATE_Column VARCHAR2(4000);
	MTHGAP_PREV_TEST_NPDATE_Col VARCHAR2(4000);
	v_TemplateID VARCHAR2(40);
	RowCount NUMBER(10);
	v_TenantKey VARCHAR2(40);	
	v_FilterClause CLOB;
	v_DATEFROM	VARCHAR2(10);
	v_DATETO VARCHAR2(10);
	v_USINGFIELD VARCHAR2(5000);
	v_MaxRowCount Number(10);
	v_PartReplacedSQL VARCHAR2(4000);
	v_PartToBeReplacedSQL VARCHAR2(4000);
	v_GridSortClause VARCHAR2(4000);
	v_SINCETESTED VARCHAR2(4000);
	v_PASTMAINDUE VARCHAR2(4000);
	v_PASTTESTDUE VARCHAR2(4000);
	v_TILLMAINDUE VARCHAR2(4000);
	v_TILLTESTDUE VARCHAR2(4000);
	V_PARTFILTERSQL VARCHAR2(4000);
	V_GENERICFILTERSQL VARCHAR2(4000);
	V_TODOFILTERSQL VARCHAR2(4000);

	v_PartFilter1 VARCHAR2(4000);
	v_PartFilterValue1  VARCHAR2(4000);
	v_PartFilterText1 CLOB;

	v_GenericFilter1 VARCHAR2(4000);
	v_GenericFilterValue1  VARCHAR2(4000);
	v_GenericFilterText1 CLOB;

	v_ToDoFilter1 VARCHAR2(4000);
	v_ToDoFilterValue1  VARCHAR2(4000);
	v_ToDoFilterText1 CLOB;
	v_TempGridSortClause CLOB;
	v_SortColumn CLOB;
	v_EquipType VARCHAR2(10);	
	CalculateDateColumn CLOB;

	PRE_NEXT_MAINDATE_COL VARCHAR(500);
	PRE_NEXT_TESTDATE_COL VARCHAR(500);
	MTHSGAP_PREEVTNXTMAIN_TEST_COL VARCHAR(500);
	MTHSGAP_PREEVTNXTTEST_TEST_COL VARCHAR(500);
BEGIN
  --DBMS_OUTPUT.enable(50000);
 
	v_EquipType := 'RELIEFD';
	V_BaseColumnsSQL := ' UNIQUEKEY,TENANTKEY,PLANTKEY,OWNERKEY,TAGNUMBER EQUIPMENTNAME,MOSTRECENT,DATETESTED,DATERECEIVED,DATECREATE,NEXTTESTDATE,NEXTMAINDATE,EQUIPMENTKEY,TAGNUMBER,LOOPNUMBER,SERIAL,MANUFACTURER,MODELNUMBER,NEXTMAINFREQ,NEXTTESTFREQ,NEXTINSPFREQ,UNIT,JOBNUMBER,MAINTFOR,I2,RISK,STATUS,TRAVELLER ';	
	BEGIN
		SELECT	MAXROWCOUNT + 1 	
		INTO	v_MaxRowCount
		FROM	USERPREFERENCE 
		WHERE	USERKEY = IN_USERKEY;
		EXCEPTION
		WHEN no_data_found THEN
		v_MaxRowCount := 1001;
	END;

	v_PartReplacedSQL := UFGETPARTSFILTERSETTINGS(IN_USERKEY,'PARTSREPLACED');
	v_PartToBeReplacedSQL := UFGETPARTSFILTERSETTINGS(IN_USERKEY,'TOBEREPLACED');
  
	V_CREATEDATE := TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD HH24:MI:SS.FF');
	EDITDATE := TO_CHAR (SYSDATE, 'YYYY/MM/DD');
	v_GridDataSource := 'uspGetRVList';
	LimitSQL := '';
	LimitRownumSQL := ' rownum < '|| v_MaxRowCount;
	RETMULDATASETS := 'T';
	InvisibleVKVSql := '';
	v_DATEFROM := IN_DATEFROM;
	v_DATETO := IN_DATETO;
	v_TemplateID := UFGETTEMPLATEIDBYUSER(IN_USERKEY);
	v_TenantKey := ufGetTenantKeyByUser(IN_USERKEY);
	v_USINGFIELD := IN_USINGFIELD;
	FilterSQL := ' TenantKey ='''||v_TenantKey ||''' ';

	IF(IN_FilterClause IS NULL) THEN
		v_FilterClause := ' 1=1  ';		
	ELSE		
		v_FilterClause := IN_FilterClause;
	END IF;
  
	v_SpecialColumnsFilterClause :=' 1=1 ';
	v_ExistedFieldsFilterClause :=' 1=1 ';
	v_PressureAnalyzeFilterClause := ' 1=1 ';
	v_OtherSpecialFilterClause := ' 1=1 ';
  	v_TempFilterString := v_FilterClause;
		 
		declare
		  CURSOR cur_token_1 IS 
		  SELECT * FROM    TABLE(UFSPLITSTRING(v_TempFilterString, ' AND '));
		  row_token_1 cur_token_1%ROWTYPE;
		  begin
			OPEN cur_token_1;
				  FETCH cur_token_1 INTO row_token_1;
				  WHILE cur_token_1%FOUND
				  LOOP
			begin
				v_Token1 := row_token_1.TOKEN;

				IF(INSTR(v_Token1,'AND (') >0) THEN
          	v_Token1 := SUBSTR(v_Token1,LENGTH('AND (') + 1, LENGTH(v_Token1)-(LENGTH('AND (') + 1));
				 declare
				  CURSOR cur_token IS 
				  SELECT * FROM    TABLE(UFSPLITSTRING(v_Token1, ' And '));
				  row_token cur_token%ROWTYPE;
				  begin
					OPEN cur_token;
						  FETCH cur_token INTO row_token;
						  WHILE cur_token%FOUND
						  LOOP
					begin
						-- v_Token is each head column filter's search clause
					  v_Token := row_token.TOKEN;

					  --deal with pressure analyze columns filter, v_Token is like 'Instr(Upper(CF1000), '%') > 0'
					  IF(INSTR(v_Token,'Upper(CF') > 0) THEN
							 FOR item in 
							 (
									SELECT	
									CASE WHEN USESETPRESS = 'T' AND NUMERATOR='COLDDIFFSET' 
									THEN 'COALESCE(COLDDIFFSET,	SETPRESSURE)' 
									WHEN USELEAKED = 'T' AND NUMERATOR='LEAKEDATPRESS' 
									THEN 'COALESCE(LEAKEDATPRESS,TOFLOAT(LEAKED))' 
									WHEN NUMERATOR='RESEATPRESS' 
									THEN 'CAST(DECODE(ISFLOAT(RESEATPRESS),1,RESEATPRESS,NULL) AS DECIMAL(10,2))' 
									ELSE NUMERATOR 
									END AS NUMERATOR,

									CASE WHEN USESETPRESS = 'T' AND DENOMINATOR='COLDDIFFSET' 
									THEN 'COALESCE(COLDDIFFSET,	SETPRESSURE)' 
									WHEN USELEAKED = 'T' AND DENOMINATOR='LEAKEDATPRESS' 
									THEN 'COALESCE(LEAKEDATPRESS,TOFLOAT(LEAKED))' 
									WHEN DENOMINATOR='RESEATPRESS' 
									THEN 'CAST(DECODE(ISFLOAT(RESEATPRESS),1,RESEATPRESS,NULL) AS DECIMAL(10,2))' 
									ELSE DENOMINATOR 
									END AS DENOMINATOR,
									FIELDNAME,
									FLAGRANGE,
									FLAGTEXT,
									DISPLAYLIKE,
									V_CREATEDATE
									FROM	GRIDCUSTOMIZEDFIELD
									WHERE	USERKEY = IN_USERKEY AND TENANTKEY = v_TenantKey 
									AND		GRIDDATASOURCE = v_GridDataSource
									AND		FIELDNAME <> 'CALCULATEDDATE'
									AND FIELDNAME IN (	SELECT	FIELDNAME
									FROM	GRIDDISPLAYFIELD
									WHERE	USERKEY = IN_USERKEY
									AND TENANTKEY = v_TenantKey 
									AND		GRIDDATASOURCE = v_GridDataSource
									AND		(DATATABLE = 'GRIDCUSTOMIZEDFIELD')
									AND		FIELDNAME <> 'CALCULATEDDATE')
							 )
							LOOP 
								IF (INSTR(v_Token,'Upper('||item.FIELDNAME||')') > 0) THEN
								  BEGIN
									IF(INSTR(v_Token,'And ')>0) THEN
										IF(item.DISPLAYLIKE = 0) THEN
											--replace value like 'CF1000' in 'Instr(Upper(CF1000), '%') > 0'
											v_PressureAnalyzeFilterClause :=v_PressureAnalyzeFilterClause || REPLACE(v_Token,item.FIELDNAME,'DECODE(' || item.DENOMINATOR || ', 0, NULL, DECODE(SIGN(ABS(' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || '-100) - ' || item.FLAGRANGE || '), 1, CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)) || ''%' || item.FLAGTEXT || ''',  CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)) || ''%'')) ')||' ';
										ELSIF(item.DISPLAYLIKE = 1) THEN
											v_PressureAnalyzeFilterClause :=v_PressureAnalyzeFilterClause || REPLACE(v_Token,item.FIELDNAME,'DECODE(' || item.DENOMINATOR || ', 0,NULL, DECODE((ABS(' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || '-100)-' || item.FLAGRANGE || '), 1, CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)) || ''' || item.FLAGTEXT || ''',CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)))) ')||' ';
										ELSIF(item.DISPLAYLIKE = 2) THEN
											v_PressureAnalyzeFilterClause :=v_PressureAnalyzeFilterClause || REPLACE(v_Token,item.FIELDNAME,'DECODE(' || item.DENOMINATOR || ',0,NULL, DECODE((ABS(' || item.NUMERATOR || '*100.0000/' || item.DENOMINATOR || '-100)-' || item.FLAGRANGE || '),1,CAST (' || item.NUMERATOR || '*1.0000/' || item.DENOMINATOR || ' AS DECIMAL(10,4)) || ''' || item.FLAGTEXT || ''',CAST (' || item.NUMERATOR || '*1.0000/' || item.DENOMINATOR || ' AS DECIMAL(10,4)))) ')||' ';								
										END IF;							
									ELSE
										IF(item.DISPLAYLIKE = 0) THEN
											v_PressureAnalyzeFilterClause :=v_PressureAnalyzeFilterClause ||' AND '|| REPLACE(v_Token,item.FIELDNAME,'DECODE(' || item.DENOMINATOR || ', 0, NULL, DECODE(SIGN(ABS(' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || '-100) - ' || item.FLAGRANGE || '), 1, CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)) || ''%' || item.FLAGTEXT || ''',  CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)) || ''%'')) ')||' ';
										ELSIF(item.DISPLAYLIKE = 1) THEN
											v_PressureAnalyzeFilterClause :=v_PressureAnalyzeFilterClause ||' AND '|| REPLACE(v_Token,item.FIELDNAME,'DECODE(' || item.DENOMINATOR || ', 0,NULL, DECODE((ABS(' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || '-100)-' || item.FLAGRANGE || '), 1, CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)) || ''' || item.FLAGTEXT || ''',CAST (' || item.NUMERATOR || '*100.00/' || item.DENOMINATOR || ' AS DECIMAL(10,2)))) ')||' ';
										ELSIF(item.DISPLAYLIKE = 2) THEN
											v_PressureAnalyzeFilterClause :=v_PressureAnalyzeFilterClause ||' AND '|| REPLACE(v_Token,item.FIELDNAME,'DECODE(' || item.DENOMINATOR || ',0,NULL, DECODE((ABS(' || item.NUMERATOR || '*100.0000/' || item.DENOMINATOR || '-100)-' || item.FLAGRANGE || '),1,CAST (' || item.NUMERATOR || '*1.0000/' || item.DENOMINATOR || ' AS DECIMAL(10,4)) || ''' || item.FLAGTEXT || ''',CAST (' || item.NUMERATOR || '*1.0000/' || item.DENOMINATOR || ' AS DECIMAL(10,4)))) ')||' ';								
										END IF;			
									END IF;							

									EXIT;

								  END;
								END IF;
							END LOOP;
					 --deal with search condition like '(Upper(GENERICCOUNT) = 0.0)'
					 ELSE
						BEGIN
						  IF(INSTR(v_Token,'GENERICCOUNT') > 0 
							  OR INSTR(v_Token,'IMAGECOUNT') > 0 
							  OR INSTR(v_Token,'ARCOUNT') > 0 
							  OR INSTR(v_Token,'TODOCOUNT') > 0 
							  OR INSTR(v_Token,'PARTCOUNT') > 0 
							  OR INSTR(v_Token,'PARTREPLACEDCOUNT') > 0 
							  OR INSTR(v_Token,'PARTTOREPLACECOUNT') > 0 
							  OR INSTR(v_Token,'PARTONORDERCOUNT') > 0 
							  OR INSTR(v_Token,'PARTNOTGOODCOUNT') > 0 
							  OR INSTR(v_Token,'PARTLIFETIMEREPLACEDCOUNT') > 0 
							  OR INSTR(v_Token,'COMMENTPREVIOUSEVENT') > 0 
							  OR INSTR(v_Token,'MONTHSGAP') > 0 
							  OR INSTR(v_Token,'MONTHGAPPREVNPDATE') > 0
							  OR INSTR(v_Token,'MONTHGAPPREVTESTNPDATE') > 0 
							  OR INSTR(v_Token,'SINCETESTED') > 0 
							  OR INSTR(v_Token,'PASTDUE') > 0 
							  OR INSTR(v_Token,'TILLDUE') > 0					 
							  OR INSTR(v_Token,'DATETESTEDEFFECTIVE') > 0
							  OR INSTR(v_Token,'EVENTCOUNT') > 0
							  OR INSTR(v_Token,'PRETEST_AVERAGE') > 0
							  OR INSTR(v_Token,'FINALTEST_AVERAGE') > 0

							  OR INSTR(v_Token,'VALVESIZE') > 0
							  OR INSTR(v_Token,'NEXTMAINDATE_YYYY') > 0
							  OR INSTR(v_Token,'NEXTMAINDATE_YYMM') > 0
							  OR INSTR(v_Token,'NEXTTESTDATE_YYYY') > 0
							  OR INSTR(v_Token,'NEXTTESTDATE_YYMM') > 0
							  OR INSTR(v_Token,'DATETESTED_YYYY') > 0
							  OR INSTR(v_Token,'DATETESTED_YYMM') > 0
							  OR INSTR(v_Token,'DATERECEIVED_YYYY') > 0
							  OR INSTR(v_Token,'DATERECEIVED_YYMM') > 0
							  OR INSTR(v_Token,'CALCULATEDDATE') > 0
						  ) THEN
							BEGIN
								IF(INSTR(v_Token,'And ')>0) THEN
									v_SpecialColumnsFilterClause := v_SpecialColumnsFilterClause || v_Token||' ';
								ELSE
									v_SpecialColumnsFilterClause := v_SpecialColumnsFilterClause ||' AND '|| v_Token ||' ';
								END IF;

							END;
						  ELSIF(INSTR(v_Token,'OWNERNAME') > 0) THEN
							BEGIN
								IF(INSTR(v_Token,'And ')>0) THEN
									v_OtherSpecialFilterClause := v_OtherSpecialFilterClause || ' AND OWNERKEY IN (SELECT UNIQUEKEY FROM OWNERS WHERE TENANTKEY =''' || v_TenantKey || ''' '||v_Token || ') ';
								ELSE
									v_OtherSpecialFilterClause := v_OtherSpecialFilterClause || ' AND OWNERKEY IN (SELECT UNIQUEKEY FROM OWNERS WHERE TENANTKEY =''' || v_TenantKey || ''' AND '||v_Token || ') ';
								END IF;
						
							END;
						  ELSIF(INSTR(v_Token,'LOCATION') > 0) THEN
							BEGIN
								IF(INSTR(v_Token,'And ')>0) THEN
									v_OtherSpecialFilterClause := v_OtherSpecialFilterClause || ' AND PLANTKEY IN (SELECT UNIQUEKEY FROM PLANTS WHERE TENANTKEY =''' || v_TenantKey || ''' '||v_Token || ') ';
								ELSE
									v_OtherSpecialFilterClause := v_OtherSpecialFilterClause || ' AND PLANTKEY IN (SELECT UNIQUEKEY FROM PLANTS WHERE TENANTKEY =''' || v_TenantKey || ''' AND '||v_Token || ') ';
								END IF;
						
							END;
						  ELSIF(INSTR(v_Token,'AREA') > 0) THEN
							BEGIN
								IF(INSTR(v_Token,'And ')>0) THEN
									v_OtherSpecialFilterClause := v_OtherSpecialFilterClause || ' AND PLANTKEY IN (SELECT UNIQUEKEY FROM PLANTS WHERE TENANTKEY =''' || v_TenantKey || ''' '||v_Token || ') ';
								ELSE
									v_OtherSpecialFilterClause := v_OtherSpecialFilterClause || ' AND PLANTKEY IN (SELECT UNIQUEKEY FROM PLANTS WHERE TENANTKEY =''' || v_TenantKey || ''' AND '||v_Token || ') ';
								END IF;
						
							END;
						  ELSE
							BEGIN
								IF(INSTR(v_Token,'And ')>0) THEN
									v_ExistedFieldsFilterClause := v_ExistedFieldsFilterClause || v_Token||' ';
								ELSE
									v_ExistedFieldsFilterClause := v_ExistedFieldsFilterClause ||' AND '|| '(' || v_Token||') ';
								END IF;
							END;
		
						  END IF;   
						END;
					END IF;       
					end;
					FETCH cur_token INTO row_token;
						  END LOOP;
						  close cur_token;
					
        end;
      ELSE        
          IF(v_Token1 != '1=1' AND v_Token1 IS NOT NULL) THEN 
              v_ExistedFieldsFilterClause := v_ExistedFieldsFilterClause || v_Token1||' ';
          END IF;
      END IF;-- END OF 'IF(INSTR(v_Token1,'AND(') >0) THEN'
				  end;
			FETCH cur_token_1 INTO row_token_1;
				  END LOOP;
				  close cur_token_1;
		  end;
	--END IF;

	v_FilterClause := v_ExistedFieldsFilterClause;
	InvisibleVKVSql := uspAppendInvisibleToFilter(InvisibleVKVSql,IN_USERKEY,'InvisibleInVKV','');
   -- get filtersqlvalue from gridfilter
  BEGIN
		SELECT	TO_CHAR(FILTERSQLVALUE)
		INTO	FilterCtrlClause
		FROM	GRIDFILTER
		WHERE	GRIDDATASOURCE=v_GridDataSource
		AND		USERKEY=IN_USERKEY
		AND		MOSTRECENT ='T' AND TENANTKEY = v_TenantKey;
    EXCEPTION
      WHEN no_data_found
      THEN
      FilterCtrlClause := '';
  END; 
  BEGIN
    SELECT FILTERSQLVALUE INTO V_PARTFILTERSQL FROM GRIDFILTER
    WHERE GRIDDATASOURCE = 'uspGetParts'
    AND MOSTRECENT = 'T' AND USERKEY = IN_USERKEY AND TENANTKEY = v_TenantKey;
    EXCEPTION
            WHEN no_data_found
            THEN
                V_PARTFILTERSQL := NULL;
  END;
  IF(V_PARTFILTERSQL IS NULL) THEN
    V_PARTFILTERSQL := ' 1=1 ';
  END IF;
  BEGIN
    SELECT FILTERSQLVALUE INTO V_GENERICFILTERSQL FROM GRIDFILTER
    WHERE GRIDDATASOURCE = 'uspGetGenerics'
    AND MOSTRECENT = 'T' AND USERKEY = IN_USERKEY AND TENANTKEY = v_TenantKey;
    EXCEPTION
            WHEN no_data_found
            THEN
                V_GENERICFILTERSQL := NULL;
  END;
  IF(V_GENERICFILTERSQL IS NULL) THEN
    V_GENERICFILTERSQL := ' 1=1 ';
  END IF;
  
  BEGIN
    SELECT FILTERSQLVALUE INTO V_TODOFILTERSQL FROM GRIDFILTER
    WHERE GRIDDATASOURCE = 'uspGetToDoList'
    AND MOSTRECENT = 'T' AND USERKEY = IN_USERKEY AND TENANTKEY = v_TenantKey;
    EXCEPTION
            WHEN no_data_found
            THEN
                V_TODOFILTERSQL := NULL;
  END;
  IF(V_TODOFILTERSQL IS NULL) THEN
    V_TODOFILTERSQL := ' 1=1 ';
  END IF;
  
	OwnerNameColumn := '(SELECT OWNERNAME FROM OWNERS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.UNIQUEKEY = r.OWNERKEY) OWNERNAME';
	PlantLocationColumn := '(SELECT LOCATION FROM PLANTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.UNIQUEKEY = r.PLANTKEY) LOCATION';
	PlantAreaColumn := '(SELECT AREA FROM PLANTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.UNIQUEKEY = r.PLANTKEY) AREA';
	ImgCountChrs := '(SELECT COUNT(*) FROM IMAGES t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND ((t.REPAIRENTRYKEY = r.UNIQUEKEY AND t.TRACKSIMAGE = ''F'') OR (t.EQUIPTRACKKEY = r.EQUIPMENTKEY AND t.TRACKSIMAGE = ''T''))' || InvisibleVKVSql || ')';
	ImgCountColumn := ImgCountChrs || ' IMAGECOUNT';
	GenCountChrs := '(SELECT COUNT(*) FROM GENERIC t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND ((t.REPAIRENTRYKEY = r.UNIQUEKEY AND t.OWNEDBY = ''Repair'') OR (t.EQUIPTRACKKEY = r.EQUIPMENTKEY AND t.OWNEDBY = ''Track''))' || InvisibleVKVSql || ')';
	GenCountColumn := GenCountChrs || ' GENERICCOUNT';
	ARCountChrs := '(SELECT COUNT(*) FROM AR t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.EQUIPTRACKKEY = r.EQUIPMENTKEY' || InvisibleVKVSql || ')';
	ARCountColumn := ARCountChrs || ' ARCOUNT';
	ToDoCountChrs := '(SELECT COUNT(*) FROM TODOLIST t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.EQUIPTRACKKEY = r.EQUIPMENTKEY' || InvisibleVKVSql || ')';
	ToDoCountColumn := ToDoCountChrs || ' TODOCOUNT';
	PartCountColumn := '(SELECT COUNT(*) FROM PARTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.REPAIRENTRYKEY = r.UNIQUEKEY' || InvisibleVKVSql || ') PARTCOUNT';
	PartLIFEtimeReplacedCountCol := '(SELECT COUNT(*) FROM PARTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.EQUIPTRACKKEY = r.EQUIPMENTKEY AND (' || v_PartReplacedSQL || ') ' || InvisibleVKVSql || ') PARTLIFETIMEREPLACEDCOUNT';
	PartReplacedCountChrs := '(SELECT COUNT(*) FROM PARTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.REPAIRENTRYKEY = r.UNIQUEKEY AND (' || v_PartReplacedSQL || ') ' || InvisibleVKVSql || ')';
	PartReplacedCountColumn := PartReplacedCountChrs || ' PARTREPLACEDCOUNT';
	PartToPlaceCountChrs := '(SELECT COUNT(*) FROM PARTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.REPAIRENTRYKEY = r.UNIQUEKEY AND (' || v_PartToBeReplacedSQL || ') ' || InvisibleVKVSql || ')';
	PartToPlaceCountColumn := PartToPlaceCountChrs || ' PARTTOREPLACECOUNT';
	PartOnOrderCountChrs := '(SELECT COUNT(*) FROM PARTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.REPAIRENTRYKEY = r.UNIQUEKEY AND PartOnOrder = ''T''' || InvisibleVKVSql || ')';
	PartOnOrderCountColumn := PartOnOrderCountChrs ||' PARTONORDERCOUNT';
	PartNotGoodCountChrs := '(SELECT COUNT(*) FROM PARTS t WHERE t.TENANTKEY = ''' || v_TenantKey || ''' AND t.REPAIRENTRYKEY = r.UNIQUEKEY AND ((INSTR(UPPER(CONDREC), ''REPLACE'')>0 OR NOT( (INSTR(UPPER(CONDREC), ''OK'')=1) OR (INSTR(UPPER(CONDREC), ''FINE'')>0) OR (INSTR(UPPER(CONDREC), ''GOOD'')>0) OR (INSTR(UPPER(CONDREC), ''PERFECT'')>0) OR (INSTR(UPPER(CONDREC), ''ACCEPT'')>0) OR (INSTR(UPPER(CONDREC), ''ACEPT'')>0) OR (INSTR(UPPER(CONDREC), ''CLEAN'')>0) OR (INSTR(UPPER(CONDREC), ''REUSE'')>0) OR (INSTR(UPPER(CONDREC), ''RE-USE'')>0) OR (INSTR(UPPER(CONDREC), ''NEW'')>0) OR (INSTR(UPPER(CONDREC), ''REPLACEM'')>0) OR (INSTR(UPPER(CONDREC), ''GREAT'')>0) OR (INSTR(UPPER(CONDREC), '' OK '')>0)) OR NOT ((INSTR(UPPER(CONDREC1), ''OK'')=1) OR (INSTR(UPPER(CONDREC1), ''FINE'')>0) OR (INSTR(UPPER(CONDREC1), ''GOOD'')>0) OR (INSTR(UPPER(CONDREC1), ''PERFECT'')>0) OR (INSTR(UPPER(CONDREC1), ''ACCEPT'')>0) OR (INSTR(UPPER(CONDREC1), ''ACEPT'')>0) OR (INSTR(UPPER(CONDREC1), ''CLEAN'')>0) OR (INSTR(UPPER(CONDREC1), ''REUSE'')>0) OR (INSTR(UPPER(CONDREC1), ''RE-USE'')>0) OR (INSTR(UPPER(CONDREC1), ''NEW'')>0) OR (INSTR(UPPER(CONDREC1), ''REPLACEM'')>0) OR (INSTR(UPPER(CONDREC1), ''GREAT'')>0) OR (INSTR(UPPER(CONDREC1), '' OK '')>0))) )' || InvisibleVKVSql || ')';
	PartNotGoodCountColumn := PartNotGoodCountChrs ||' PARTNOTGOODCOUNT';
	PartsFilterCountChrs := '(SELECT COUNT(*) FROM PARTS PARTS WHERE PARTS.TENANTKEY = ''' || v_TenantKey || ''' AND PARTS.REPAIRENTRYKEY = r.UNIQUEKEY AND (' || V_PARTFILTERSQL || ') ' || InvisibleVKVSql || ')';
	PartsFilterCountColumn := PartsFilterCountChrs ||' PARTFILTERCOUNT';  
	GenericFilterCountChrs := '(SELECT COUNT(*) FROM GENERIC GENERIC WHERE GENERIC.TENANTKEY = ''' || v_TenantKey || ''' AND GENERIC.REPAIRENTRYKEY = r.UNIQUEKEY AND (' || V_GENERICFILTERSQL || ') ' || InvisibleVKVSql || ')';
	GenericFilterCountColumn := GenericFilterCountChrs || ' GENERICFILTERCOUNT';  
	ToDoFilterCountChrs := '(SELECT COUNT(*) FROM TODOLIST TODOLIST WHERE TODOLIST.TENANTKEY = ''' || v_TenantKey || ''' AND TODOLIST.REPAIRENTRYKEY = r.UNIQUEKEY AND (' || V_TODOFILTERSQL || ') ' || InvisibleVKVSql || ') ';
	ToDoFilterCountColumn := ToDoFilterCountChrs || ' TODOFILTERCOUNT';  
	ValveSizeColumn := '(CASE WHEN INLETSIZE IS NULL AND OUTLETSIZE IS NULL THEN NULL ELSE INLETSIZE || '' '' || DECODE(ORIFDESIGNATION,NULL,''x'',ORIFDESIGNATION) || '' '' || OUTLETSIZE END) VALVESIZE';
	NextMainDateYYYYColumn := 'DECODE(ISDATE(NEXTMAINDATE),1,EXTRACT(YEAR FROM TODATE(NEXTMAINDATE)),'''') NEXTMAINDATE_YYYY';
	NextMainDateYYMMColumn := 'DECODE(ISDATE(NEXTMAINDATE),1,EXTRACT(YEAR FROM TODATE(NEXTMAINDATE)) || ''/'' || EXTRACT(MONTH FROM TODATE(NEXTMAINDATE)),'''') NEXTMAINDATE_YYMM';
	NextTestDateYYYYColumn := 'DECODE(ISDATE(NEXTTESTDATE),1,EXTRACT(YEAR FROM TODATE(NEXTTESTDATE)),'''') NEXTTESTDATE_YYYY';
	NextTestDateYYMMColumn := 'DECODE(ISDATE(NEXTTESTDATE),1,EXTRACT(YEAR FROM TODATE(NEXTTESTDATE)) || ''/'' || EXTRACT(MONTH FROM TODATE(NEXTTESTDATE)),'''') NEXTTESTDATE_YYMM';
	DateTestedYYYYColumn := 'DECODE(ISDATE(DATETESTED),1,EXTRACT(YEAR FROM TODATE(DATETESTED)),'''') DATETESTED_YYYY';
	DateTestedYYMMColumn := 'DECODE(ISDATE(DATETESTED),1,EXTRACT(YEAR FROM TODATE(DATETESTED)) || ''/'' || EXTRACT(MONTH FROM TODATE(DATETESTED)),'''') DATETESTED_YYMM';
	DateReceivedYYYYColumn := 'DECODE(ISDATE(DATERECEIVED),1,EXTRACT(YEAR FROM TODATE(DATERECEIVED)),'''') DATERECEIVED_YYYY';
	DateReceivedYYMMColumn := 'DECODE(ISDATE(DATERECEIVED),1,EXTRACT(YEAR FROM TODATE(DATERECEIVED)) || ''/'' || EXTRACT(MONTH FROM TODATE(DATERECEIVED)),'''') DATERECEIVED_YYMM';
	MonthsGapColumn := 'DECODE((SELECT COUNT(1) FROM RELIEFD WHERE EQUIPMENTKEY = r.EQUIPMENTKEY AND TENANTKEY='''||v_TenantKey||'''),1,''(1 Event)'',	
	DECODE(MOSTRECENT, ''T'', TO_CHAR(TRUNC(DATEDIFF(''DAY'', TODATE ((SELECT DISTINCT MAX(DECODE(ISDATE(DATETESTED),1,DATETESTED,DECODE(ISDATE(DATERECEIVED),1,DATERECEIVED,substr(DATECREATE,1,4)||''/''|| substr(DATECREATE,5,2) ||''/''|| substr(DATECREATE,7,2)))) FROM RELIEFD WHERE TENANTKEY = ''' || v_TenantKey || ''' AND EQUIPMENTKEY = r.EQUIPMENTKEY AND MOSTRECENT <> ''T'' AND ISDATE(DECODE(ISDATE(DATETESTED),1,DATETESTED,DECODE(ISDATE(DATERECEIVED),1,DATERECEIVED,substr(DATECREATE,1,4)||''/''|| substr(DATECREATE,5,2) ||''/''|| substr(DATECREATE,7,2)))) = 1)),
		TODATE ((SELECT DISTINCT MAX(DECODE(ISDATE(DATETESTED),1,DATETESTED,DECODE(ISDATE(DATERECEIVED),1,DATERECEIVED,substr(DATECREATE,1,4)
		||''/''|| substr(DATECREATE,5,2) ||''/''|| substr(DATECREATE,7,2)))) FROM RELIEFD WHERE TENANTKEY = ''' || v_TenantKey || ''' AND EQUIPMENTKEY = r.EQUIPMENTKEY AND MOSTRECENT = ''T''  AND ISDATE(DECODE(ISDATE(DATETESTED),1,DATETESTED,DECODE(ISDATE(DATERECEIVED),1,DATERECEIVED,substr(DATECREATE,1,4)||''/''|| substr(DATECREATE,5,2) ||''/''|| substr(DATECREATE,7,2)))) = 1 )))*10000/304375)), ''(See MR)'')) AS MONTHSGAP ';

	DateTestedEffectiveColumn := 'DECODE(ISDATE(DATETESTED), 0, DECODE(ISDATE(DATERECEIVED),0, SUBSTR(DATECREATE, 1, 4)||''/''|| SUBSTR(DATECREATE, 5, 2) ||''/''|| SUBSTR(DATECREATE, 7, 2), DATERECEIVED), DATETESTED) DATETESTEDEFFECTIVE';	
	PRETEST_AVERAGE_Column := '(ufAverageValue(PREPOPPED, PRETEST2, PRETEST3)) PRETEST_AVERAGE'; 
	FINAL_TEST_AVERAGE_Column :='(ufAverageValue(FINALTESTPRESS, FINALTESTPRESS2, FINALTESTPRESS3)) FINALTEST_AVERAGE'; 
	MONTHGAP_PREV_NPDATE_Column :='(ufGetMonthsGapPrevNPDate(SEALID, DATETESTED, DATERECEIVED, UNIQUEKEY)) MONTHGAPPREVNPDATE';

	MTHGAP_PREV_TEST_NPDATE_Col :='(ufGetMonthsGapPrevNPDate(RDBASEMAT, DATETESTED, DATERECEIVED, UNIQUEKEY)) MONTHGAPPREVTESTNPDATE';
	CommentPreviousEventCol := 'TO_CHAR(UFGETEQUIPPREFIELD(R.UNIQUEKEY,0,''A_COMMENT'')) AS COMMENTPREVIOUSEVENT';
	PRE_NEXT_MAINDATE_COL := 'TO_CHAR(UFGETEQUIPPREFIELD(R.UNIQUEKEY,0,''NEXTMAINDATE'')) AS PRENEXTMAINDATE';
	PRE_NEXT_TESTDATE_COL := 'TO_CHAR(UFGETEQUIPPREFIELD(R.UNIQUEKEY,0,''NEXTTESTDATE'')) AS PRENEXTTESTDATE';
	MTHSGAP_PREEVTNXTMAIN_TEST_COL := 'ceil(DATEDIFF(''DAY'',TODATE(DATETESTED),TODATE(UFGETEQUIPPREFIELD(R.UNIQUEKEY,0,''NEXTMAINDATE'')))*10000/304375 )AS MTHSGAPPREEVTNXTMAINTEST';
	MTHSGAP_PREEVTNXTTEST_TEST_COL := 'ceil(DATEDIFF(''DAY'',TODATE(DATETESTED),TODATE(UFGETEQUIPPREFIELD(R.UNIQUEKEY,0,''NEXTTESTDATE'')))*10000/304375) AS MTHSGAPPREEVTNXTTESTTEST';


	IF(FilterCtrlClause is null) THEN		
		EventCountColumn := '(SELECT COUNT(*) FROM RELIEFD t WHERE  t.TENANTKEY = ''' || v_TenantKey || ''' AND t.EQUIPMENTKEY = r.EQUIPMENTKEY) EVENTCOUNT';
	ELSE
		--display in #Events/Repairs like '3(2)' when Most Recent='F'
		EventCountColumn := '(SELECT COUNT(*) FROM RELIEFD t WHERE  t.TENANTKEY = ''' || v_TenantKey || ''' AND t.EQUIPMENTKEY = r.EQUIPMENTKEY) ||''(''||
		(SELECT COUNT(*) FROM RELIEFD t WHERE  t.TENANTKEY = ''' || v_TenantKey || ''' AND t.EQUIPMENTKEY = r.EQUIPMENTKEY AND 1=1 GROUP BY EQUIPMENTKEY)
		||'')'' EVENTCOUNT';		
	END IF;
	    
	BEGIN
		select a.SQLCALEXP ||' CALCULATEDDATE'
		into CalculateDateColumn
		from GRIDCALCULATIONFIELD a
		where a.USERKEY=IN_USERKEY
		and a.GRIDDATASOURCE=v_GridDataSource
		and a.FIELDNAME='CALCULATEDDATE' AND a.TENANTKEY=v_TenantKey;
	EXCEPTION
		WHEN no_data_found
		THEN
		CalculateDateColumn := NULL;
	END; 	
	--deal with special column head filter
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'GENERICCOUNT',GenCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'IMAGECOUNT',ImgCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'ARCOUNT',ARCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'TODOCOUNT',ToDoCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PARTCOUNT',PartCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PARTLIFETIMEREPLACEDCOUNT',PartLIFEtimeReplacedCountCol,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'COMMENTPREVIOUSEVENT',CommentPreviousEventCol,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);			
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PARTREPLACEDCOUNT',PartReplacedCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PARTTOREPLACECOUNT',PartToPlaceCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PARTONORDERCOUNT',PartOnOrderCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PARTNOTGOODCOUNT',PartNotGoodCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'MONTHSGAP',MonthsGapColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'DATETESTEDEFFECTIVE',DateTestedEffectiveColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'EVENTCOUNT',EventCountColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'NEXTMAINDATE_YYYY',NextMainDateYYYYColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'NEXTMAINDATE_YYMM',NextMainDateYYMMColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'NEXTTESTDATE_YYYY',NextTestDateYYYYColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'NEXTTESTDATE_YYMM',NextTestDateYYMMColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'DATETESTED_YYYY',DateTestedYYYYColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'DATETESTED_YYMM',DateTestedYYMMColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'DATERECEIVED_YYYY',DateReceivedYYYYColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);	
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'DATERECEIVED_YYMM',DateReceivedYYMMColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);

	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'MONTHGAPPREVNPDATE',MONTHGAP_PREV_NPDATE_Column,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);

	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'MONTHGAPPREVTESTNPDATE',MTHGAP_PREV_TEST_NPDATE_Col,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);

	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'PRETEST_AVERAGE',PRETEST_AVERAGE_Column,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'FINALTEST_AVERAGE',FINAL_TEST_AVERAGE_Column,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);	
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'VALVESIZE',ValveSizeColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
		
	SelectedSpecialColumns := ufGetFilterSpecialColumns(NULL,'CALCULATEDDATE',CalculateDateColumn,SelectedSpecialColumns,v_EquipType,v_SpecialColumnsFilterClause,0);
    --RV, Selected Index is 0
    UPDATE	USERPREFERENCE u
    SET		u.SELECTEDVALVETYPE = '0'
    WHERE	u.USERKEY = IN_USERKEY AND u.TENANTKEY = v_TenantKey;
	
	IF (IN_COMINGDUETYPE = 0) THEN
		ComingDueTo := NULL;
	ELSIF (IN_COMINGDUETYPE = 1) THEN
		ComingDueTo := TO_CHAR(SYSDATE+MOD(7 - TO_CHAR(SYSDATE,'D')+1, 7), 'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 2) THEN
		ComingDueTo := TO_CHAR(SYSDATE+MOD(7 - TO_CHAR(SYSDATE,'D')+1, 7)+7, 'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 3) THEN
		ComingDueTo := TO_CHAR(LAST_DAY(SYSDATE), 'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 4) THEN
		ComingDueTo := TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,1)), 'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 5) THEN
		ComingDueTo := TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,3)), 'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 6) THEN
		ComingDueTo := TO_CHAR(LAST_DAY(ADD_MONTHS(SYSDATE,6)), 'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 7) THEN
		ComingDueTo := TO_CHAR(LAST_DAY(ADD_MONTHS(TRUNC(SYSDATE , 'Year'),11)),'YYYY/MM/DD');
	ELSIF (IN_COMINGDUETYPE = 8) THEN
		ComingDueTo := EditDate;
	ELSE
		ComingDueTo := NULL;
	END IF;
	
	IF (IN_INCLUDEPASTDUE = 'T') THEN
		ComingDueFrom := '1900/01/01';
		IF (ComingDueTo IS NULL) THEN
			ComingDueTo := EditDate;
		END IF;
	ELSE
		ComingDueFrom := EditDate;
	END IF;
	
	IF (IN_ONLYSHOWMR = 'T') THEN
		v_FilterClause := v_FilterClause || ' AND MOSTRECENT = ''T''';
	ELSIF (IN_RVKEY IS NOT NULL) THEN
		BEGIN
			SELECT	EQUIPMENTKEY
			INTO	EquipKey
			FROM	RELIEFD
			WHERE	UNIQUEKEY = IN_RVKEY 
			  AND TENANTKEY = v_TenantKey;
			v_FilterClause :=  v_FilterClause || ' AND EQUIPMENTKEY = ''' || EquipKey || '''';
		EXCEPTION
		  WHEN no_data_found
		  THEN
			NULL;
		END; 
	END IF;

	IF (IN_Unit IS NOT NULL AND INSTR(v_FilterClause, 'unit) =') = 0 AND INSTR(v_FilterClause, 'unit =') = 0) THEN
		IF (IN_Unit = '(Blank)') THEN
			v_FilterClause :=  v_FilterClause ||  ' AND (unit IS NULL OR unit ='''') ';
		ELSE
			v_FilterClause :=  v_FilterClause ||  ' AND (UPPER(unit) = ''' || IN_Unit || ''') ';
		END IF;
	END IF;

	IF (ComingDueTo IS NOT NULL) THEN
		FilterSQL := FilterSQL || '  AND (NEXTMAINDATE BETWEEN ''' || ComingDueFrom || ''' AND ''' || ComingDueTo  || ''' OR NEXTTESTDATE BETWEEN ''' || ComingDueFrom || ''' AND ''' || ComingDueTo  || ''')';
	END IF;

	IF (v_USINGFIELD IS NOT NULL  AND (v_DATEFROM  IS NOT NULL OR  v_DATETO IS NOT NULL)) THEN
		IF (v_USINGFIELD = 'SHIPPEDDATE') THEN
			v_USINGFIELD := 'ETEXT14';
		END IF;
		IF (v_USINGFIELD = 'DATETESTEDEFFECTIVEDATE') THEN
			v_USINGFIELD := 'DECODE(ISDATE(DATETESTED), 0, DECODE(ISDATE(DATERECEIVED),0, SUBSTR(DATECREATE, 1, 4)||''/''|| SUBSTR(DATECREATE, 5, 2) ||''/''|| SUBSTR(DATECREATE, 7, 2), DATERECEIVED), DATETESTED) ';
		END IF;
		
		DateFilterClause := v_USINGFIELD || ' BETWEEN ''' || COALESCE(v_DATEFROM, '1900/01/01') || ''' AND ''' || COALESCE(v_DATETO, '9999/12/30') || '''';
		
		FilterSQL := '(' || FilterSQL || ' AND ' || DateFilterClause  || ')';
	ELSE
		v_DateFrom := '';
		v_DATETO := '';
	END IF;
	
	FilterSQL := UFGETPLANTFILTERSTRING (IN_USERKEY, FilterSQL, null);

	IF (IN_Image = 'T') THEN
    IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(ImgCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(ImgCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;
	
	IF (IN_Generic = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(GenCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(GenCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;

	IF (IN_AR = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(ARCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(ARCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;
	
	IF (IN_ToDo = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(ToDoCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(ToDoCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;
  
  IF (IN_INPART = 'T') THEN
  BEGIN
    begin
      select filtervalue, filtersqlvalue, filtertext
      into v_PartFilter1, v_PartFilterValue1, v_PartFilterText1
      from gridfilter 
      where griddatasource='uspGetParts' and userkey = IN_USERKEY and tenantkey = v_TenantKey and mostrecent = 'T';
      EXCEPTION
      WHEN	no_data_found
        THEN	
        begin
            v_PartFilter1 := NULL;
            v_PartFilterValue1 := NULL;
            v_PartFilterText1 := NULL;
         end;
    end;
    if(v_PartFilterValue1 is not null) then
      IF(LimitSQL IS NOT NULL) THEN
        LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(PartsFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      ELSE
        LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(PartsFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      END IF;
    else
      IF(LimitSQL IS NOT NULL) THEN
        LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(PartsFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      ELSE
        LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(PartsFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      END IF;
    end if;
  END;
	END IF;

	IF (IN_PartsReplaced = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(PartReplacedCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(PartReplacedCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;
  IF (IN_INGENERIC = 'T') THEN
  BEGIN
      begin  
          select filtervalue, filtersqlvalue, filtertext
          into v_GenericFilter1, v_GenericFilterValue1, v_GenericFilterText1
          from gridfilter 
          where griddatasource='uspGetGenerics' and userkey = IN_USERKEY and tenantkey = v_TenantKey and mostrecent = 'T';
          EXCEPTION
          WHEN	no_data_found
          THEN	
          begin
              v_GenericFilter1 := NULL;
              v_GenericFilterValue1 := NULL;
              v_GenericFilterText1 := NULL;
              end;
      end;
      IF(LimitSQL IS NOT NULL) THEN
          LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' || REPLACE(REPLACE(GenericFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      ELSE
          LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(GenericFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      END IF;
  END;
  END IF;

  --LIMIT GRID TO TODO FILTER
  IF (IN_INTODO = 'T') THEN
  BEGIN
      begin
          select filtervalue, filtersqlvalue, filtertext
          into v_ToDoFilter1, v_ToDoFilterValue1, v_ToDoFilterText1
          from gridfilter 
          where griddatasource='uspGetToDoList' and userkey = IN_USERKEY and tenantkey = v_TenantKey and mostrecent = 'T';
          EXCEPTION
          WHEN	no_data_found
          THEN	
          begin
              v_ToDoFilter1 := NULL;
              v_ToDoFilterValue1 := NULL;
              v_ToDoFilterText1 := NULL;
              end;
      end;
      IF(LimitSQL IS NOT NULL) THEN
          LimitSQL := LimitSQL || IN_ANDOR  || ' EXISTS ' || REPLACE(REPLACE(ToDoFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      ELSE
          LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(ToDoFilterCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
      END IF;
  END;
  END IF;
	
	IF (IN_PartsToReplace = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(PartToPlaceCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(PartToPlaceCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;
	
	IF (IN_PartsOnOrder = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(PartOnOrderCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(PartOnOrderCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;

	IF (IN_PartsNotGood = 'T') THEN
		IF(LimitSQL IS NOT NULL) THEN
			LimitSQL := LimitSQL || IN_ANDOR || ' EXISTS ' ||REPLACE(REPLACE(PartNotGoodCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		ELSE
			LimitSQL := ' EXISTS ' ||REPLACE(REPLACE(PartNotGoodCountChrs,'r.','RELIEFD.'),'COUNT(*)','1');
		END IF;
	END IF;	

	-- copy the quick filter an query string filter so that they can filter in outside
	IF(LimitSQL IS NOT NULL) THEN
		LimitSQL := v_FilterClause || ' AND (' || LimitSQL || ')';
	ELSE
		LimitSQL := v_FilterClause;
	END IF;

	IF(TRIM(v_OtherSpecialFilterClause) <> '1=1') THEN
		LimitSQL := LimitSQL || ' AND ' || v_OtherSpecialFilterClause;
	END IF;

	IF(TRIM(v_PressureAnalyzeFilterClause) <> '1=1' ) THEN
		LimitSQL := LimitSQL || ' AND ' || v_PressureAnalyzeFilterClause;
	END IF;

	
	IF (FilterCtrlClause IS NOT NULL) THEN
		FilterCtrlClause := REPLACE(FilterCtrlClause, 'RELIEFD.','');

        FilterSQL := '(' || FilterSQL || ') AND (' || FilterCtrlClause || ')';
    END IF;
	
	IF(FilterCtrlClause is not null) THEN		
		--display in #Events/Repairs like '3(2)' when Most Recent='F'
		EventCountColumn := REPLACE(EventCountColumn, '1=1', FilterSQL);
	END IF;

	----------------Handle Column Start--------------------------
	BEGIN
		SELECT	LISTAGG('r.' || FIELDNAME, ',') WITHIN GROUP (ORDER BY FIELDNAME)
		INTO	SelectedColumns1
		FROM	(	SELECT	FIELDNAME
					FROM	GRIDDISPLAYFIELD
					WHERE	USERKEY = IN_USERKEY AND TENANTKEY = v_TenantKey 
					AND		GRIDDATASOURCE = v_GridDataSource
					AND		(DATATABLE <> 'GRIDCUSTOMIZEDFIELD' or FIELDNAME='CALCULATEDDATE')
					AND		FIELDNAME NOT IN ('UNIQUEKEY','MOSTRECENT', 'DATETESTED', 'DATERECEIVED', 'DATECREATE','NEXTTESTDATE', 'NEXTMAINDATE', 'EQUIPMENTKEY', 'TAGNUMBER', 'LOOPNUMBER', 'SERIAL', 'MANUFACTURER', 'MODELNUMBER', 'NEXTMAINFREQ','NEXTTESTFREQ','NEXTINSPFREQ','UNIT','JOBNUMBER','MAINTFOR','I2','RISK','STATUS','TRAVELLER')
					UNION
					SELECT	 'IMAGECOUNT' FROM DUAL WHERE IN_Image = 'T'
					UNION
					SELECT	 'GENERICCOUNT' FROM    DUAL WHERE	IN_GENERIC = 'T'
					UNION
					SELECT	 'ARCOUNT' FROM    DUAL WHERE	IN_AR = 'T'
					UNION
					SELECT	 'TODOCOUNT' FROM    DUAL WHERE	IN_TODO = 'T'
					UNION
					SELECT	 'PARTREPLACEDCOUNT' FROM    DUAL WHERE	IN_PARTSREPLACED = 'T'
					UNION
					SELECT	 'PARTTOREPLACECOUNT' FROM    DUAL WHERE	IN_PARTSTOREPLACE = 'T'
					UNION
					SELECT	 'PARTONORDERCOUNT' FROM    DUAL WHERE	IN_PARTSONORDER = 'T'
					UNION
					SELECT	 'PARTNOTGOODCOUNT' FROM    DUAL WHERE	IN_PARTSNOTGOOD = 'T'
          			UNION
					SELECT	 'PARTFILTERCOUNT' FROM    DUAL WHERE	IN_INPART = 'T'
          			UNION
					SELECT	 'GENERICFILTERCOUNT' FROM    DUAL WHERE	IN_INGENERIC = 'T'
					UNION
					SELECT	 'TODOFILTERCOUNT' FROM    DUAL WHERE	IN_INTODO = 'T'
				);
	    EXCEPTION
		  WHEN no_data_found
		  THEN
		  SelectedColumns1 := '';
		END; 

	INSERT INTO TEMPGRIDCUSTOMIZEDFIELD ( NUMERATOR,
										  DENOMINATOR,
										  FIELDNAME,
										  FLAGRANGE,
										  FLAGTEXT,
										  DISPLAYLIKE,
										  CREATEDATE)
	SELECT	CASE WHEN USESETPRESS = 'T' AND NUMERATOR='COLDDIFFSET' THEN 'COALESCE(COLDDIFFSET,SETPRESSURE)' WHEN USELEAKED = 'T' AND NUMERATOR='LEAKEDATPRESS' THEN 'COALESCE(LEAKEDATPRESS,TOFLOAT(LEAKED))' WHEN NUMERATOR='RESEATPRESS' THEN 'CAST(DECODE(ISFLOAT(RESEATPRESS),1,RESEATPRESS,NULL) AS DECIMAL(10,2))' ELSE NUMERATOR END AS NUMERATOR,
			CASE WHEN USESETPRESS = 'T' AND DENOMINATOR='COLDDIFFSET' THEN 'COALESCE(COLDDIFFSET,SETPRESSURE)' WHEN USELEAKED = 'T' AND DENOMINATOR='LEAKEDATPRESS' THEN 'COALESCE(LEAKEDATPRESS,TOFLOAT(LEAKED))' WHEN DENOMINATOR='RESEATPRESS' THEN 'CAST(DECODE(ISFLOAT(RESEATPRESS),1,RESEATPRESS,NULL) AS DECIMAL(10,2))' ELSE DENOMINATOR END AS DENOMINATOR,
			FIELDNAME,
			FLAGRANGE,
			FLAGTEXT,
			DISPLAYLIKE,
			V_CREATEDATE
	FROM	GRIDCUSTOMIZEDFIELD
	WHERE	USERKEY = IN_USERKEY AND TENANTKEY = v_TenantKey 
	AND		GRIDDATASOURCE = v_GridDataSource
	AND		FIELDNAME <> 'CALCULATEDDATE';
	

	BEGIN
		SELECT	LISTAGG(CF, ',') WITHIN GROUP (ORDER BY CF)  
		INTO	SelectedColumns2
		FROM	(	SELECT	'DECODE(' || DENOMINATOR || ', 0, NULL, DECODE(SIGN(ABS(' || NUMERATOR || '*100.00/' || DENOMINATOR || '-100) - ' || FLAGRANGE || '), 1, CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''%' || FLAGTEXT || ''',  CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''%'')) ' || FIELDNAME AS CF
					FROM	TEMPGRIDCUSTOMIZEDFIELD
					WHERE	DISPLAYLIKE = 0
					AND		CREATEDATE = V_CREATEDATE
					UNION
					SELECT	'DECODE(' || DENOMINATOR || ', 0,NULL, DECODE((ABS(' || NUMERATOR || '*100.00/' || DENOMINATOR || '-100)-' || FLAGRANGE || '), 1, CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''' || FLAGTEXT || ''',CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)))) ' || FIELDNAME AS CF
					FROM	TEMPGRIDCUSTOMIZEDFIELD
					WHERE	DISPLAYLIKE = 1
					AND		CREATEDATE = V_CREATEDATE
					UNION
					SELECT	'DECODE(' || DENOMINATOR || ',0,NULL, DECODE((ABS(' || NUMERATOR || '*100.0000/' || DENOMINATOR || '-100)-' || FLAGRANGE || '),1,CAST (' || NUMERATOR || '*1.0000/' || DENOMINATOR || ' AS DECIMAL(10,4)) || ''' || FLAGTEXT || ''',CAST (' || NUMERATOR || '*1.0000/' || DENOMINATOR || ' AS DECIMAL(10,4)))) ' || FIELDNAME AS CF
					FROM	TEMPGRIDCUSTOMIZEDFIELD
					WHERE	DISPLAYLIKE = 2
					AND		CREATEDATE = V_CREATEDATE
				);

		SELECT	LISTAGG(CF, ',') WITHIN GROUP (ORDER BY CF)  
		INTO	SelectedColumns3
		FROM	(	SELECT	'DECODE(' || DENOMINATOR || ', 0, NULL, DECODE(SIGN(ABS(' || NUMERATOR || '*100.00/' || DENOMINATOR || '-100) - ' || FLAGRANGE || '), 1, CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''%' || FLAGTEXT || ''',  CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''%'')) ' || FIELDNAME AS CF
					FROM	TEMPGRIDCUSTOMIZEDFIELD
					WHERE	DISPLAYLIKE = 0
					AND		CREATEDATE = V_CREATEDATE
					AND FIELDNAME IN (	SELECT	FIELDNAME
					FROM	GRIDDISPLAYFIELD
					WHERE	USERKEY = IN_USERKEY
					AND TENANTKEY = v_TenantKey 
					AND		GRIDDATASOURCE = v_GridDataSource
					AND		(DATATABLE = 'GRIDCUSTOMIZEDFIELD')
					AND		FIELDNAME <> 'CALCULATEDDATE')
					UNION
					SELECT	'DECODE(' || DENOMINATOR || ', 0,NULL, DECODE((ABS(' || NUMERATOR || '*100.00/' || DENOMINATOR || '-100)-' || FLAGRANGE || '), 1, CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)) || ''' || FLAGTEXT || ''',CAST (' || NUMERATOR || '*100.00/' || DENOMINATOR || ' AS DECIMAL(10,2)))) ' || FIELDNAME AS CF
					FROM	TEMPGRIDCUSTOMIZEDFIELD
					WHERE	DISPLAYLIKE = 1
					AND		CREATEDATE = V_CREATEDATE
					AND FIELDNAME IN (	SELECT	FIELDNAME
					FROM	GRIDDISPLAYFIELD
					WHERE	USERKEY = IN_USERKEY
					AND TENANTKEY = v_TenantKey 
					AND		GRIDDATASOURCE = v_GridDataSource
					AND		(DATATABLE = 'GRIDCUSTOMIZEDFIELD')
					AND		FIELDNAME <> 'CALCULATEDDATE')
					UNION
					SELECT	'DECODE(' || DENOMINATOR || ',0,NULL, DECODE((ABS(' || NUMERATOR || '*100.0000/' || DENOMINATOR || '-100)-' || FLAGRANGE || '),1,CAST (' || NUMERATOR || '*1.0000/' || DENOMINATOR || ' AS DECIMAL(10,4)) || ''' || FLAGTEXT || ''',CAST (' || NUMERATOR || '*1.0000/' || DENOMINATOR || ' AS DECIMAL(10,4)))) ' || FIELDNAME AS CF
					FROM	TEMPGRIDCUSTOMIZEDFIELD
					WHERE	DISPLAYLIKE = 2
					AND		CREATEDATE = V_CREATEDATE
					AND FIELDNAME IN (	SELECT	FIELDNAME
					FROM	GRIDDISPLAYFIELD
					WHERE	USERKEY = IN_USERKEY
					AND TENANTKEY = v_TenantKey 
					AND		GRIDDATASOURCE = v_GridDataSource
					AND		(DATATABLE = 'GRIDCUSTOMIZEDFIELD')
					AND		FIELDNAME <> 'CALCULATEDDATE')
				);
	    EXCEPTION
		  WHEN no_data_found
		  THEN
		  SelectedColumns2 := '';
		  SelectedColumns3 := '';
		END; 

  
	IF (SelectedColumns1 IS NOT NULL) THEN
		SelectedColumns1 := ',' || SelectedColumns1;
	ELSE
		SelectedColumns1 := '';
	END IF;

	IF (SelectedColumns3 IS NOT NULL) THEN
		
		SelectedColumns1 := SelectedColumns1 || ',' || SelectedColumns3;
	END IF;
	
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.CALCULATEDDATE', 'CALCULATEDDATE');

	SelectedColumns1 :=	uspAppendCalculationField(SelectedColumns1,IN_USERKEY,v_GridDataSource);

	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.OWNERNAME', OwnerNameColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.LOCATION', PlantLocationColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.AREA', PlantAreaColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.IMAGECOUNT', ImgCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.GENERICCOUNT', GenCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.ARCOUNT', ARCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.TODOCOUNT', ToDoCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTCOUNT', PartCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTLIFETIMEREPLACEDCOUNT', PartLIFEtimeReplacedCountCol);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.COMMENTPREVIOUSEVENT', CommentPreviousEventCol);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTREPLACEDCOUNT', PartReplacedCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTTOREPLACECOUNT', null);
	SelectedColumns1 := SelectedColumns1 || ',' || PartToPlaceCountColumn;
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTONORDERCOUNT', PartOnOrderCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTNOTGOODCOUNT', PartNotGoodCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PARTFILTERCOUNT', PartsFilterCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.GENERICFILTERCOUNT', GenericFilterCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.TODOFILTERCOUNT', ToDoFilterCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.EVENTCOUNT', EventCountColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.VALVESIZE', ValveSizeColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.NEXTMAINDATE_YYYY', NextMainDateYYYYColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.NEXTMAINDATE_YYMM', NextMainDateYYMMColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.NEXTTESTDATE_YYYY', NextTestDateYYYYColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.NEXTTESTDATE_YYMM', NextTestDateYYMMColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.DATETESTED_YYYY', DateTestedYYYYColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.DATETESTED_YYMM', DateTestedYYMMColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.DATERECEIVED_YYYY', DateReceivedYYYYColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.DATERECEIVED_YYMM', DateReceivedYYMMColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.DATETESTEDEFFECTIVE', DateTestedEffectiveColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.MONTHSGAP', MonthsGapColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PRETEST_AVERAGE', PRETEST_AVERAGE_Column);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.FINALTEST_AVERAGE', FINAL_TEST_AVERAGE_Column);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.MONTHGAPPREVNPDATE', MONTHGAP_PREV_NPDATE_Column);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.MONTHGAPPREVTESTNPDATE', MTHGAP_PREV_TEST_NPDATE_Col);
  SelectedColumns1 :=  REPLACE(SelectedColumns1, 'r.PRENEXTMAINDATE', PRE_NEXT_MAINDATE_COL);
  SelectedColumns1 :=  REPLACE(SelectedColumns1, 'r.PRENEXTTESTDATE', PRE_NEXT_TESTDATE_COL);
  SelectedColumns1 :=  REPLACE(SelectedColumns1, 'r.MTHSGAPPREEVTNXTMAINTEST', MTHSGAP_PREEVTNXTMAIN_TEST_COL);
  SelectedColumns1 :=  REPLACE(SelectedColumns1, 'r.MTHSGAPPREEVTNXTTESTTEST', MTHSGAP_PREEVTNXTTEST_TEST_COL);

	SelectedColumns1 := REPLACE(SelectedColumns1, ',,', ',');
	
	--IF (INSTR(SelectedColumns1, 'r.SINCETESTED') > 0 OR INSTR(SelectedColumns1,'r.PASTDUE') > 0 OR INSTR(SelectedColumns1,'r.TILLDUE') > 0) THEN
	v_SINCETESTED := 'TRUNC(DATEDIFF(''DAY'',TODATE(DECODE(ISDATE(DATETESTED),1,DATETESTED,DECODE(ISDATE(DATERECEIVED),1,DATERECEIVED,NULL))),SYSDATE)*10000/304375) ';
	v_PASTMAINDUE := 'TRUNC(GREATEST(DATEDIFF(''DAY'',TODATE(DECODE(ISDATE(NEXTMAINDATE),1,NEXTMAINDATE,NULL)),SYSDATE),-1)*10000/304375) ';
	v_PASTTESTDUE := 'TRUNC(GREATEST(DATEDIFF(''DAY'',TODATE(DECODE(ISDATE(NEXTTESTDATE),1,NEXTTESTDATE,NULL)),SYSDATE),-1)*10000/304375) ';
	v_TILLMAINDUE := 'TRUNC(GREATEST(DATEDIFF(''DAY'',SYSDATE,TODATE(DECODE(ISDATE(NEXTMAINDATE),1,NEXTMAINDATE,NULL))),-1)*10000/304375) ';
	v_TILLTESTDUE := 'TRUNC(GREATEST(DATEDIFF(''DAY'',SYSDATE,TODATE(DECODE(ISDATE(NEXTTESTDATE),1,NEXTTESTDATE,NULL))),-1)*10000/304375) ';

	SELECT  COUNT(*)
	INTO	RowCount
	FROM    FIELDDEFINITION
	WHERE   TEMPLATEID = v_TemplateID
	AND		TENANTKEY = v_TenantKey
	AND		DATATABLE = 'RELIEFD'
	AND		DATAFIELD = 'NEXTMAINDATE'
	AND		UPPER(USERNAME) LIKE '%NEXT%';

	IF (RowCount > 0) THEN
		SinceTestedColumn := v_SINCETESTED || ' || DECODE(SIGN(' || v_SINCETESTED || '-NEXTMAINFREQ), 1, '' *Maint'','''')';
	ELSE
		SinceTestedColumn := v_SINCETESTED;
	END IF;

	PastDueColumn := ' DECODE(MOSTRECENT, ''T'', DECODE(SIGN('|| v_PASTMAINDUE ||'), 1, '|| v_PASTMAINDUE ||',''''), '''') PASTDUE';
	TillDueColumn := ' DECODE(MOSTRECENT,''T'', DECODE(SIGN('|| v_TILLMAINDUE ||'),1, '|| v_TILLMAINDUE ||',''''), '''' )  TILLDUE';

	SELECT  COUNT(*)
	INTO	RowCount
	FROM    FIELDDEFINITION
	WHERE   TEMPLATEID = v_TemplateID
	AND		TENANTKEY = v_TenantKey
	AND		DATATABLE = 'RELIEFD'
	AND		DATAFIELD = 'NEXTTESTDATE'
	AND		UPPER(USERNAME) LIKE '%NEXT%';

	IF (RowCount > 0) THEN
		SinceTestedColumn := SinceTestedColumn || ' || DECODE(SIGN('|| v_SINCETESTED ||'-NEXTTESTFREQ),1,'' ~Test'','''')';
		PastDueColumn := 'DECODE(MOSTRECENT, ''T'',DECODE(SIGN('|| v_PASTMAINDUE ||'+1),1,'|| v_PASTMAINDUE ||','''') || DECODE(SIGN('|| v_PASTTESTDUE||'+1),1,DECODE(SIGN('|| v_PASTMAINDUE ||'-'|| v_PASTTESTDUE ||'),0,'''','' For Test:'' || '|| v_PASTTESTDUE ||'),''''),'''') PASTDUE';
		TillDueColumn := 'DECODE(MOSTRECENT, ''T'',DECODE(SIGN('|| v_TILLMAINDUE ||'),1,'|| v_TILLMAINDUE ||','''') || DECODE(SIGN('|| v_TILLTESTDUE ||'), 1,  DECODE(SIGN('|| v_TILLMAINDUE ||'-'|| v_TILLTESTDUE ||'),0,'''','' For Test:'' || '|| v_TILLTESTDUE ||'),''''),'''') TILLDUE';
	END IF;

	SELECT  COUNT(*)
	INTO	RowCount
	FROM    FIELDDEFINITION
	WHERE   TEMPLATEID = v_TemplateID
	AND		TENANTKEY = v_TenantKey
	AND		DATATABLE = 'RELIEFD'
	AND		DATAFIELD = 'NEXTINSPDATE'
	AND		UPPER(USERNAME) LIKE '%NEXT%';

	IF (RowCount > 0) THEN
		SinceTestedColumn := SinceTestedColumn || ' || DECODE(SIGN('|| v_SINCETESTED ||'-NEXTINSPFREQ),1,'' ^Insp'','''')';
	END IF;

	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.SINCETESTED', SinceTestedColumn || ' SINCETESTED');
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.PASTDUE', PastDueColumn);
	SelectedColumns1 := REPLACE(SelectedColumns1, 'r.TILLDUE', TillDueColumn);
	--END IF;

	IF(INSTR(UPPER(v_SpecialColumnsFilterClause), 'SINCETESTED')>0) THEN
		BEGIN
		SelectedSpecialColumns := SelectedSpecialColumns ||  ',' || REPLACE(SinceTestedColumn,'r.','RELIEFD.')|| ' SINCETESTED';

		END;
	END IF;
	IF(INSTR(UPPER(v_SpecialColumnsFilterClause), 'PASTDUE')>0) THEN
		BEGIN
		SelectedSpecialColumns := SelectedSpecialColumns || ',' || REPLACE(PastDueColumn,'r.','RELIEFD.');

		END;
	END IF;
	IF(INSTR(UPPER(v_SpecialColumnsFilterClause), 'TILLDUE')>0) THEN
		BEGIN
		SelectedSpecialColumns := SelectedSpecialColumns || ',' || REPLACE(TillDueColumn,'r.','RELIEFD.');
		END;
	END IF;


	--for part bom import link field
	IF(IN_LinkField IS NOT NULL) THEN
		IF(instr(V_BaseColumnsSQL,IN_LinkField)<=0 And instr(SelectedColumns1,IN_LinkField) <= 0) THEN    
		  SelectedColumns1 :=  SelectedColumns1 || ' , '|| IN_LinkField;
		END IF;
	END IF;
	----------------Handle Column End--------------------------

	if(INSTR(SelectedColumns1, 'RECCREATEDBY') = 0) then
		V_BaseColumnsSQL := V_BaseColumnsSQL||',RECCREATEDBY ';
	end if;

	v_GridSortClause := uspGetSortExpression(IN_UserKey, 'uspGetRVList', '');
	v_TempGridSortClause := v_GridSortClause;
			
	v_TempGridSortClause := REPLACE(v_TempGridSortClause ,'ORDER BY','');
	v_TempGridSortClause := REPLACE(v_TempGridSortClause ,'DESC','');
	v_TempGridSortClause  := TRIM(v_TempGridSortClause );
		
	declare
		CURSOR cur_token IS 
		SELECT * FROM    TABLE(UFSPLITSTRING(v_TempGridSortClause, ','));
		row_token cur_token%ROWTYPE;
		begin
		OPEN cur_token;
				FETCH cur_token INTO row_token;
				WHILE cur_token%FOUND
				LOOP
		begin
			v_SortColumn := row_token.TOKEN;			

			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'MONTHGAPPREVNPDATE',MONTHGAP_PREV_NPDATE_Column,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'MONTHGAPPREVTESTNPDATE',MTHGAP_PREV_TEST_NPDATE_Col,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PRETEST_AVERAGE',PRETEST_AVERAGE_Column,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'FINALTEST_AVERAGE',FINAL_TEST_AVERAGE_Column,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'VALVESIZE',ValveSizeColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'GENERICCOUNT',GenCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'IMAGECOUNT',ImgCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'ARCOUNT',ARCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'TODOCOUNT',ToDoCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PARTCOUNT',PartCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PARTLIFETIMEREPLACEDCOUNT',PartLIFEtimeReplacedCountCol,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'COMMENTPREVIOUSEVENT',CommentPreviousEventCol,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PARTREPLACEDCOUNT',PartReplacedCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PARTTOREPLACECOUNT',PartToPlaceCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PARTONORDERCOUNT',PartOnOrderCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PARTNOTGOODCOUNT',PartNotGoodCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'MONTHSGAP',MonthsGapColumn,SelectedSpecialColumns,v_EquipType,NULL,1);			
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'DATETESTEDEFFECTIVE',DateTestedEffectiveColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'EVENTCOUNT',EventCountColumn,SelectedSpecialColumns,v_EquipType,NULL,1);			
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'NEXTMAINDATE_YYYY',NextMainDateYYYYColumn,SelectedSpecialColumns,v_EquipType,NULL,1);	
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'NEXTMAINDATE_YYMM',NextMainDateYYMMColumn,SelectedSpecialColumns,v_EquipType,NULL,1);	
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'NEXTTESTDATE_YYYY',NextTestDateYYYYColumn,SelectedSpecialColumns,v_EquipType,NULL,1);	
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'NEXTTESTDATE_YYMM',NextTestDateYYMMColumn,SelectedSpecialColumns,v_EquipType,NULL,1);	
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'DATETESTED_YYYY',DateTestedYYYYColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'DATETESTED_YYMM',DateTestedYYMMColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'DATERECEIVED_YYYY',DateReceivedYYYYColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'DATERECEIVED_YYMM',DateReceivedYYMMColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'SINCETESTED',SinceTestedColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'PASTDUE',PastDueColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'TILLDUE',TillDueColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'OWNERNAME',OwnerNameColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'LOCATION',PlantLocationColumn,SelectedSpecialColumns,v_EquipType,NULL,1);
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'AREA',PlantAreaColumn,SelectedSpecialColumns,v_EquipType,NULL,1);	
			SelectedSpecialColumns := ufGetFilterSpecialColumns(v_SortColumn,'CALCULATEDDATE',CalculateDateColumn,SelectedSpecialColumns,v_EquipType,NULL,1);	
		end;
		FETCH cur_token INTO row_token;
				END LOOP;
				close cur_token;
		end;


	IF(INSTR(UPPER(v_GridSortClause), 'CF')>0) THEN
				BEGIN
					IF(SelectedSpecialColumns IS NULL) THEN
						SelectedSpecialColumns := ',' || SelectedColumns2;
					ELSE
						SelectedSpecialColumns := SelectedSpecialColumns || ',' || SelectedColumns2;
					END IF;
				END;
	END IF;

	V_SQL2 := 'SELECT UNIQUEKEY AS UNIQUEKEY2,TENANTKEY AS TENANTKEY2 FROM (SELECT UNIQUEKEY,TENANTKEY '|| SelectedSpecialColumns || ' FROM RELIEFD  WHERE ' || FilterSQL||' AND '|| LimitSQL || v_GridSortClause ||') r WHERE '|| v_SpecialColumnsFilterClause || ' AND ' || LimitRownumSQL;
	
	V_SQL :='SELECT ' || V_BaseColumnsSQL || SelectedColumns1 || ' FROM RELIEFD r INNER JOIN (' || V_SQL2 ||' ) T ON r.UNIQUEKEY =T.UNIQUEKEY2 AND r.TENANTKEY = T.TENANTKEY2 ';
	
	IF (v_USINGFIELD = 'ETEXT14') THEN
		v_USINGFIELD := 'SHIPPEDDATE';
	END IF;
	IF (IN_USINGFIELD = 'DATETESTEDEFFECTIVEDATE') THEN
		v_USINGFIELD := 'DATETESTEDEFFECTIVEDATE';
	END IF;
	USPSAVEREPAIRLISTFILTER(IN_USERKEY, IN_ONLYSHOWMR, IN_RVKEY, IN_PARTSREPLACED, IN_PARTSTOREPLACE, IN_PARTSONORDER, IN_PARTSNOTGOOD, IN_COMINGDUETYPE, IN_INCLUDEPASTDUE, v_USINGFIELD, v_DATEFROM, v_DATETO, IN_ANDOR, IN_IMAGE, IN_GENERIC, IN_TODO, IN_INPART, IN_INAR, IN_INWELD, IN_INPOSITIONER, IN_INLOCATION, IN_INGENERIC, IN_INTODO, IN_UNIT);
	--DBMS_OUTPUT.PUT_LINE(V_SQL);
  OPEN OUT_CURSOR FOR V_SQL;
END USPGETRVLISTBYUSER;