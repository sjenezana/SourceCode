  

SELECT *
  FROM  (select v.sql_id,
	   v.child_number,
	   v.sql_text,v.sql_fulltext,
	   v.elapsed_time,
	   v.cpu_time,
	   v.disk_reads,
	   rank () over (order BY v.elapsed_time desc) elapsed_rank
  FROM v$sql v) a
 WHERE elapsed_rank <= 10;
 
 
select count(TABLE_NAME),TABLE_NAME from ALL_TAB_COLUMNS group by TABLE_NAME order by count(TABLE_NAME) desc; 


select client_name,status,consumer_group,window_group from dba_autotask_client order by client_name;

select task_name,status,to_char(execution_end,'DD-MON-YY HH24:MI') from 
dba_advisor_executions where task_name='SYS_AUTO_SQL_TUNING_TASK' order by 
execution_end;
select DBMS_SQLTUNE.REPORT_AUTO_TUNING_TASK FROM DUAL;


SELECT VALUE FROM v$parameter t WHERE t.name = 'optimizer_mode';


select * from V$SQLSTATS 
order by ELAPSED_TIME DESC


SELECT /*+NESTED_TABLE_GET_REFS+*/ "VKC2"."RELIEFD".* FROM "VKC2"."RELIEFD" 



select a.sql_text SQL_clause, b.etime,
    c.user_id,
    c.SAMPLE_TIME 执行时间, 
    c.INSTANCE_NUMBER 实例数,
    u.username 用户名,a.sql_id SQL编号
 from dba_hist_sqltexta,
    (
select sql_id, ELAPSED_TIME_DELTA / 1000000 as etime
          from dba_hist_sqlstat
         where ELAPSED_TIME_DELTA / 1000000 >= 1
) b,
    dba_hist_active_sess_history c,
    dba_users u
 where a.sql_id=b.sql_id
  and c.user_id=u.user_id
  and b.sql_id=c.sql_id
  --anda.sql_textlike'%IN%'
 order by SAMPLE_TIME desc, 
  b.etime desc;



SELECT A.SQL_TEXT  , B.ETIME  ,C.USER_ID,C.SAMPLE_TIME,C.INSTANCE_NUMBER, U.USERNAME, A.SQL_ID
FROM DBA_HIST_SQLTEXT A,
  (SELECT SQL_ID, ELAPSED_TIME_DELTA / 1000000 AS ETIME
  FROM DBA_HIST_SQLSTAT
  ) B, DBA_HIST_ACTIVE_SESS_HISTORY C,DBA_USERS U
  WHERE A.SQL_ID = B.SQL_ID AND U.USERNAME = 'XXXX' AND C.USER_ID = U.USER_ID AND 
  B.SQL_ID = C.SQL_ID --and a.sql_text like '%IN%'
 ORDER BY SAMPLE_TIME DESC,B.ETIME DESC;




--1.查看总消耗时间最多的前10条SQL语句
SELECT *
  FROM  (select v.sql_id,
	   v.child_number,
	   v.sql_text,v.sql_fulltext,
	   v.elapsed_time,
	   v.cpu_time,
	   v.disk_reads,
	   rank ()  over (order BY v.elapsed_time desc)  elapsed_rank
  FROM v$sql v)  a
 WHERE elapsed_rank <= 10;
 
--2.查看CPU消耗时间最多的前10条SQL语句
SELECT *
  FROM  (select v.sql_id,
	   v.child_number,
	   v.sql_text,
	   v.elapsed_time,
	   v.cpu_time,
	   v.disk_reads,
	   rank ()  over (order BY v.cpu_time desc)  elapsed_rank
  FROM v$sql v)  a
 WHERE elapsed_rank <= 10;
--3.查看消耗磁盘读取最多的前10条SQL语句
SELECT *
  FROM  (select v.sql_id,
	   v.child_number,
	   v.sql_text,
	   v.elapsed_time,
	   v.cpu_time,
	   v.disk_reads,
	   rank ()  over (order BY v.disk_reads desc)  elapsed_rank
  FROM v$sql v)  a
 WHERE elapsed_rank <= 10;