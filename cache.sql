declare
v_tenantkey VARCHAR2(40);
v_count number;
begin
  declare
		  CURSOR cur_emp IS 
		  select uniquekey from tenant;
      row_emp cur_emp%ROWTYPE;
      begin
        OPEN cur_emp;
			  FETCH cur_emp INTO row_emp;
			  WHILE cur_emp%FOUND
			  LOOP
        begin
          v_tenantkey := row_emp.uniquekey; 

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'HYDROSTAMPVERIF','Hydro Stamp Verified',1967,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='HYDROSTAMPVERIF' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'PARTSUNIV2','Parts U2',1968,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='PARTSUNIV2' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'FINALTESTUNIV91','FT U91',1969,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='FINALTESTUNIV91' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'FINALTESTUNIV92','FT U92',1970,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='FINALTESTUNIV92' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'QCUNIV91','QC U91',1971,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='QCUNIV91' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'QCUNIV92','QC U92',1972,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='QCUNIV92' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'SHIPUNIV91','Ship U91',1973,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='SHIPUNIV91' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');

                Insert into GRIDDEFAULTFIELD (TENANTKEY,GRIDDATASOURCE,QUERYTYPE,DATATABLE,FIELDNAME,DISPLAYNAME,FIELDNUM,SEQNO,"SHOW", "VALUE",CREATEDATE,EDITDATE,FIELDTYPE) 
                SELECT  v_tenantkey, 'uspGetRVList','SELECT','ReliefD', 'SHIPUNIV92','Ship U92',1974,0,'T','150',TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),TO_CHAR (CURRENT_TIMESTAMP, 'YYYY/MM/DD'),null FROM dual
                where not exists(SELECT * FROM GRIDDEFAULTFIELD WHERE FIELDNAME='SHIPUNIV92' AND FIELDNUM=1966 AND GRIDDATASOURCE='uspGetRVList');
 
        end;
        FETCH cur_emp INTO row_emp;
			  END LOOP;
			  close cur_emp;
      end;
       
end;
