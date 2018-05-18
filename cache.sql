declare
v_tenantkey VARCHAR2(40);
begin
  declare
	CURSOR cur_emp IS 
	select uniquekey from tenant t where	 exists (select * from  TEMPLATES tem where tem.ISDEFAULT = 'T' and tem.tenantkey=t.uniquekey);
      row_emp cur_emp%ROWTYPE;
      begin
        OPEN cur_emp;
			  FETCH cur_emp INTO row_emp;
			  WHILE cur_emp%FOUND
			  LOOP
        begin
          v_tenantkey := row_emp.uniquekey;

          insert into griddefaultfield (tenantkey,griddatasource,querytype,datatable,fieldname,displayname,fieldnum,seqno,show,value,createdate,editdate,fieldtype) 
          select v_tenantkey tenantkey,griddatasource,querytype,datatable,fieldname,displayname,fieldnum,seqno,show,value,createdate,editdate,fieldtype from (
          select distinct  griddatasource,querytype,'NA' datatable,'PRENEXTMAINDATE' fieldname,displayname || ' - Previous Event' displayname,
          119 fieldnum,0 seqno,"SHOW","VALUE",'2018/05/16' createdate,'2018/05/16' editdate,fieldtype 
            from griddefaultfield g   where fieldname = 'NEXTMAINDATE' and griddatasource in ('uspGetCVList','uspGetLVList','uspGetMOVList','uspGetRVList')
          union all
          select  distinct  griddatasource,querytype,'NA' datatable,'PRENEXTTESTDATE' fieldname,displayname || ' - Previous Event' displayname,
          124 fieldnum,0 seqno,"SHOW","VALUE",'2018/05/16' createdate,'2018/05/16' editdate,fieldtype 
            from griddefaultfield g   where fieldname = 'NEXTTESTDATE' and griddatasource in ('uspGetCVList','uspGetLVList','uspGetMOVList','uspGetRVList')
          );
          
          insert into griddefaultfield (tenantkey,griddatasource,querytype,datatable,fieldname,displayname,fieldnum,seqno,show,value,createdate,editdate,fieldtype) 
          select v_tenantkey tenantkey,griddatasource,querytype,datatable,fieldname,displayname,fieldnum,seqno,show,value,createdate,editdate,fieldtype from (
          select  distinct  griddatasource,querytype,'NA' datatable,'MTHSGAPPREEVTNXTMAINTEST' fieldname,'# Mths Gap Date Tested - Prev Next Maint' displayname, 
          null fieldnum,0 seqno,"SHOW","VALUE",'2018/05/16' createdate,'2018/05/16' editdate,'I' fieldtype 
            from griddefaultfield g   where fieldname = 'MONTHSGAP' and griddatasource in ('uspGetCVList','uspGetLVList','uspGetMOVList','uspGetRVList')
          union
          select  distinct  griddatasource,querytype,'NA' datatable,'MTHSGAPPREEVTNXTTESTTEST' fieldname,'# Mths Gap Date Tested - Prev Next Test' displayname, 
          null fieldnum,0 seqno,"SHOW","VALUE",'2018/05/16' createdate,'2018/05/16' editdate,'I' fieldtype
            from griddefaultfield g   where fieldname = 'MONTHSGAP' and griddatasource in ('uspGetCVList','uspGetLVList','uspGetMOVList','uspGetRVList')  
          );
          
        end;
        FETCH cur_emp INTO row_emp;
			  END LOOP;
			  close cur_emp;
      end;
end;

ufGetEquipPreField

uspGetGridField
ufFormatLowerColumns
uspGetGeneralSummary
uspGetKeyListByFitlerInGrid
uspPrepareGridFieldsNoCust

uspGetRVListByUser
uspGetCVListByUser
uspGetLVListByUser
uspGetLVListByUsercount
uspGetMOVListByUser
uspGetMOVListByUsercount





, 'PRENEXTMAINDATE', 'PRENEXTTESTDATE', 'MTHSGAPPREEVTNXTMAINTEST','MTHSGAPPREEVTNXTTESTTEST'


 
select reliefd.A_COMMENT,reliefd.* from reliefd where tagnumber = 'A' and A_COMMENT is not null order by tenantkey


'LAG(to_char(A_COMMENT),1) over  (order by equipmentkey, DECODE(ISDATE(DATETESTED), 0, DECODE(ISDATE(DATERECEIVED),0, 
SUBSTR(DATECREATE, 1, 4)||''/''|| SUBSTR(DATECREATE, 5, 2) ||''/''|| SUBSTR(DATECREATE, 7, 2), DATERECEIVED), DATETESTED) 
,UNIQUEKEY) AS COMMENTPREVIOUSEVENT';