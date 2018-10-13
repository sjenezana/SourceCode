第一章 意识,少做事,从学习开始
Oracle的设计思想及工作原理:少做事.通过分级缓存,减少对磁盘数据的读取.
1.2.1
A 数据库应用角色
 a 开发
 b 管理
 c 优化
d 设计
B Oracle基本知识分类
    a 基本原理    1 体系结构
                        2 物理结构
                        3 表
                        4 索引
                        5,事务
    b 开发技能    1 SQL
                        2 PL/SQL
                        3 常用函数
    c 管理知识    1 用户及权限管理
                        2 安装调试
                        3 备份恢复
                        4 数据迁移
                        5 闪回
                        6 故障处理
    d 优化原理    1 统计信息
                        2 执行计划
                        3 诊断工具
                        4 深入了解表
                        5 深入了解索引
                        6 表连接原理
    e 设计相关    1 模型工具使用
                        2 规范制定执行
                        3 业务理解
                        4 各类知识综合应用
数据库规划路线 : 数据库开发相关工作 sql,pl/sql      2
                          从事管理相关工作,兼顾优化技能   3--
                          学习设计相关知识                        5--
1.3
注:要学以致用,学习知识时要想应用场景,最好能直接用到工作中
第二章 : 物理体系
A :Oracle 体系结构 
    1 组成:a 实例 : SGA PGA   b :数据库
    2 实例 a SGA(system global area) : 共享内存 s:share
                共享池 shared pool ,数据缓冲池 db cache ,日志缓冲区 log buffer
               b PGA(program globl area)  :不共享内存 作用 : 预处理 
                保存用户连接信息,用户权限,指令的排序区
               c 后台进程(一系列): PMON,SMON,LCKn ,,,
    3,数据库:一系列文件组成:数据文件,参数文件,日志文件,控制文件,归档文件
           归档日志:可转移到新的存储介质,用于rman
    4,用户请求 :pga>sga>db,或是pga>sga
2.2.2.1
B :查询sql过程经历的物理结构 select object_name from t where object_id = 29;
    1 , pga 保存用户信息和权限 sql匹配唯一的hash值
        session不断开,下次直接从pga中读取数据
    2 , sga ,shared pool 是否存在sql 的hash值,若无,校验语法.语义,权限 ,解析判断查询代价(索引,全表),生成执行计划并与hash值绑定,若有,执行下一步.
强制全表扫描:select /* + full(t)*/ object_name from t where object_id = 29;
                db cache : 查找数据,若无,执行下一步
    3 , database : 数据文件区,无论有没有查询到数据,都返回给用户.
2.2.3.1
C:更新语句经历的物理结构 update t set object_id = 92 where object_id = 29;
  1,走查询历程,查数据到db cache;
   2,undo表空间(回滚表空间)的事务表上分配事务槽,同时写入log buffer;
   3, db cache创建 object_id = 29的前镜像(最终会写大磁盘的回滚数据文件),同时写入log buffer
   4,执行更新语句,更改db_cache里面的数据,同时写入log buffer;
   5,commit,立即写入log buffer,并触发进程LGWR,将log buffer 的内容写如日志文件,LGWR写日志文件需要覆盖重写的时候,进程ARCH复制日志文件形成归档日志文件.
当db cache中的数据到达设置点,进程CKPT触发进程DBWR将db cache中数据由内存写入到数据文件中,回滚事务标记为INACTIVE,表示不允许重写.
    6,rollback,从回滚段中将前镜像object_id=29的数据读出来,修改db cache .同时写入log buffer.
注:PL/SQL中同一个登录用户同一个sql window中可以在未提交的状态下看到修改的内容,未commit时,新增的sqlwindow中执行的查询语句属于新的session,不会看到修改.
常用进程
PMON : Processes Monitor ,更新语句未提交时进程崩溃了,PMON会自动回滚该操作;
SMON : system monitor ,类似PMON,只不过对象是系统级的操作,重点在于instance             recovery.以及清理临时表空间,回滚段表空间,合并空闲空间..
LCKn:仅使用于RAC(real application cluster)真正应用集群数据库,用于实例间的封锁
RECO : distributed database recovery 分布式数据库恢复,适用于两阶段提交.
CKPT : check point  用于触发DBWR从db cache 写出数据到磁盘;控制参数:fast_start_mttr_target .
DBWR : database writer.从db cache 写出数据到磁盘.由CKPT促使执行,
    前置条件:通知LGWR先完成 log buffer 写到磁盘
LGWR : log writer.将数据从log buffer 写到 磁盘的REDO文件中,进行对数据库对象,数据的
操作过程的记录.以用来进行数据库恢复. 
ARCH : archive ,LGWR写日志写到覆盖重写的时候,复制日志文件形成归档文件.
2.2.3.4 
D rollback 回滚
1,参数 :a undo_management = auto ;自动回滚段管理,回滚段空间不够自动拓展
          bundo_retension : DML要记录前镜像,commit后表示回滚段保留的前镜像可覆盖重新使用的时间.
在Oracle Undo机制中，undo_retention是一个非常不容易理解的参数项。简单的说，undo_retention就是用户使用Oracle过程中，对flashback和一致读的基本要求期间。设置之后，Oracle会根据自动undo管理的原则进行调节，进行空间拓展，来适应实现用户的期间要求。
所谓“巧妇难为无米之炊”，undo_retention是用户的期望。Oracle在进行调节过程中，会根据实际的业务频繁度和数量量、以及undo表空间设置情况进行综合评估。就是说，虽然用户设置了undo_retention的期望，在很多情况下也是不能达到的。
 如果业务场景中真正需要进行retention period的保留，可以使用undo表空间的guarantee方法。一旦设置这个参数开关，undo_retention就成为一个强依赖参数。Oracle在这种情况下，宁可拒绝SQL DML操作，也不会允许将undo数据前镜像覆盖的情况发生.
cundo_tablespace :回滚段表空间名称.
2,    undo : 回滚记录.
       redo :重做记录(归档日志),undo会产生对应的redo.
                    undo        redo                综合
insert          少(rowid)   多
update        中                中
delete        多                少(rowid)  最多(undo会产生对应的redo)
3, 一致读原理 
a ,定义:查询的记录由查询的这一时间点决定,后面即便变化了,也根据回滚段保存的前镜像记录取那个时间点的数据.
b,实现前提
   SCN:system change number.存在于oracle的最小单位块里,只增加不减小,块改变,SCN就会递增
    ITL槽:interest transation list .回滚段记录事务槽.如果更新了某块,事务就写进事务槽里,如果未提交或者回滚,此块就存在活动事务.(查询过程中其它事务对数据有修改.)
注:oracle归档开启:先将数据库关闭,启动到mount状态,执行开启归档命令,数据库open
方法语句:
    shutdown immediate;
    startup mount;
    alter databse archivelog;
    alter database open;
查看 88
archive log list;
4 数据库起停和参数文件的关系;
a,startup nomount : 数据库的参数文件 :SPFILE(9i后)和PFILE:包含控制文件的名称及位置.
现在多为 :先找spfile,找不到找INIT.ORA,再找不到就报错
b,startup mount :数据库的控制文件 :包含数据文件,日志文件和检查点信息
c,alter database open :根据控制文件定位到数据库文件,日志文件
    数据库停止是启动的逆过程,只不过整合到一个指令中完成: shutdown immediate.
    文件位置:
    参数文件 : show parameter spfilter;
    控制文件 : show parameter control;
    数据文件 : select file_name from dba_data_files;
    日志文件 : select group#,member from v$logfile;
    归档日志 : show parameter recovery;
    告警日志文件: show parameter dump;
--参数文件位置
Show parameter Spfile;
--控制文件位置
Show parameter control;
--数据文件位置
Select file_name From dba_data_files;
--日志文件位置
Select group#,Member From v$logfile;
--归档文件位置
Show parameter Recovery;
--告警文件位置 bdump目录下,alert%
Show parameter dump;
  监听:查看状态: lsnrctrl status
          停止/开启:lsnrctrl stop/start
2.3.2 优化 insert 语句的执行的几个层次
实现将1到10万的值插入到t表
1 , 
for i in 1 .. 100000
loop
execute immediate 'insert into t values (' || i || ')';
coommit;
end loop;
2 ,变量代替具体值,share_pool 中hash值只产生一个
for i in 1 .. 100000
loop
execute immediate 'insert into t values ( :x)' using i;
coommit;
end loop;
3 ,动态sql进行静态改写
    动态sql:执行过程中进行解析;
    静态sql:编译过程时就进行解析(均在shared_pool)
for i in 1 .. 100000
loop
insert into t values (i) ;
coommit;
end loop;
4,批量提交
commit:LGWR将REDO BUFFER写出到日志文件,回滚段的事务标记为不活动,对应的前镜像记录位置标记为可重写.
for i in 1 .. 100000
loop
insert into t values (i) ;
end loop;
coommit;
5,集合写法
将语句整批的写入Data Buffer
insert into t select rownum from dual connect by level <=100000;
6,直接路径
跳过数据缓存区,直接写入到磁盘
create table t as select rownum from dual connect by level <= 100000;
with x As (select 'aa' Chr from dual union All select 'bb' chr from dual)
select level, chr, lpad(' ', (level - 1) * 5, '-') || chr other from x connect by level <= 3
7,并行设置:会占用大多数CPU资源
create  table t nologging parallel 64 as select rownum from dual connect by level <= 100000;
第三章 逻辑体系
数据库逻辑结构的对象是 : 物理结构中的数据文件.
逻辑结构可以让我们更好理解数据库的数据文件
数据库 , DataBase
表空间 ,TableSpace  可以组成表空间组
段 ,Segment               和table对应
若表中包含LOB类型列,则LOB至少有段:数据段和索引段;
若表有分区,则每个分区也都独立成段.
区 ,Extent
块  ,Block
3.2.2 Block 数据库块
1,含义 block:Oracle逻辑结构的最小单位,block size. 
                                物理存储的最小单位:字节  最小空间分配单位是extent
2, 单位 操作系统(OS)的块容量为 512xB(x>=1);
    数据库块默认值为 8KB,也可以为2xKB(x>=1),但一定要为OS块的容量的整数倍.
    因:数据库运行在OS上,真正操作的是OS块. 可以减少空间浪费.
3 组成 (5部分) 
     数据库块头 data block header:概要内容 ,例:block adress, segment的类型:表或是索引
    表目录 table directory: 行数据所在的表的信息
    行目录  row directory: 行数据的插入的地址
    可用空间区:空域空间.pctfree参数控制 ,一般为10%,
    行数据区 : 行或是索引的信息
    管理开销 overhead : data block header, table directory,row directory
3.2.3 Extent&Segment :区与段
create table t (int i)
1 含义:建表t的本质是建数据段segment t;
2 应用 : segment创建成功,则数据分配由data block组成的初始数据拓展initial extent,插入数据以致空间不足时,Oracle会为segment t 分配新增数据拓展 incremental extent(大于等于之前的数据拓展)
3 存储参数(storage parameter):segement的定义中包含extent的storage parameter.
    storage:用在create table中,决定 为data segment 分配的初始空间,默认取tablespace的默认storage.
    extent的容量:a 用户设定的固定值:create tablespace 时用 uniform 默认1M ,
                 下限 : >= 5 * data block
                 注:本地管理(locally managed)的临时表空间(temporary tablespace)只能用此方式.
             b 系统自动决定可变值:                                           用 autoallocate
                 下限 : >=64KB ,若datablock >=16KB,则 >=1M 
3.2.4 TableSapce表空间
 1,按作用分类     a ,系统表空间 : 存放系统的配置,控制等全局信息;    
                            b,临时表空间:存放临时数据
                            c:回滚表空间(还原):UNDO,暂存要处理的数据
                            d:数据表空间:存放数据文件
3.2.5 数据字典及数据参数
1,block的大小:show parameter db_block_size
select block_size from dba_tablespaces where tablespace_name = 'SYSTEM';
2,创建表空间
a ,普通数据表空间
create tablespace tbs_lib blocksize 16K
 datafile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' size 100M
exten management local         segment space management auto;
Select file_name ,tablespace_name,autoextensible,bytes From dba_data_files Where Rownum < 3  
b,临时表空间  temporary , tempfile 
create temporary tablespace tbs_lib tempfile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' size 100M
c,回滚表空间 undo
create undo  tablespace tbs_lib datafile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' size 100M
d,系统表空间 (10g后增加了sysaux)
Select file_name ,tablespace_name,autoextensible,bytes From dba_data_files 
Where tablespace_name Like 'SYS%'
3,系统表空间和用户表空间属于永久保留内容的表空间
select tablespace_name ,contents from dba_tablespaces where rownum < 11;
4,extent
Select segment_name ,extent_id ,bytes,blocks From user_extents Where Rownum < 100;
5,segment
Select segment_name , segment_type,Tablespace_name,blocks,extents,bytes 
From user_segments Where Rownum <= 200;
6,修改16K大小的内存
 show parameter cache_size
 alter system set db_16k_cache_size = 100M;
 show parameter 16k
SGA中的databuffer中有100M让16K的大小进行访问
7.PCTFREE参数:设置block的空余空间.
PCTFREE的作用是：当数据块的剩余容量达到PCTFREE值时，此数据块不再被记录于freelist中，不允许其他数据再存放至数据块中。
PCTUSED的作用是：当数据块中的数据量小于PCTUSED值时，此数据块将被记录于freelist中，允许其他数据再存放至此数据块中。要将表空间设置为手动管理
 select * from v$version;
 show user;
 select PCT_FREE,PCT_USED from dba_tables where table_name = 'EMP';
 alter table t5 pctfree 40; 
 alter table t5 pctused 50;
8,表空间情况
--查看以创建的表空间
select tablespace_name ,contents from dba_tablespaces where rownum < 11;
--查看剩余表空间
select sum(bytes)/1024/1024/1024 from Dba_Free_Space where Tablespace_name = 'SYSTEM';
--查看表空间总体的分配
select sum(bytes)/1024/1024/1024 from dba_data_files where Tablespace_name = 'SYSTEM';
--显示创建文件存放路径
show parameter create_file_dest
--拓展表空间 100M
Alter Tablespace System Add Datafile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' Size 100M
--表空间设置为自动拓展
Alter Tablespace System Add Datafile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' Autoextend on;
--删除表空间
Drop Tablespace SYSTEMTest 
Including Contents And Datafiles --删除表空间的数据及对应的数据文件
--创建表空间
create tablespace tbs_lib 
blocksize 16K --blocksize
datafile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' size 100M
Autoextend On --自动拓展
Next 64k --每次以64K进行拓展
Maxsize 5G --表空间最大尺寸
exten management Local segment space management auto;--10g以上默认自动添加
--用户指定到临时表空间
Alter User fyerp Temporary Tablespace SYSTEMTest;
Select default_tablespace,temporary_tablespace From dba_users Where username = 'FYERP';
--所有用户指定临时表空间
Alter Database Default Temporary Tablespace systemtest;
9 表空间组
--查看临时表空间组
Select * From dba_tablespace_groups;
--创建临时表空间组 
create temporary tablespace tbs_lib tempfile 'E:ORA10\DATAFILE\TBS_LIB_01.DBF' size 100M 
Tablespace Group tmp_grp1;
--指定临时表空间到组
Alter Tablespace temp_lib Tablespace Group temp_grp1;
--用户指定临时表空间组
Alter User lib Temporary Tablespace tmp_grp1;
Select * From dba_users Where username = 'LIB';--查看
10 ,行迁移与优化
--创建行迁移相关表
create table CHAINED_ROWS (
  owner_name         varchar2(30),
  table_name         varchar2(30),
  cluster_name       varchar2(30),
  partition_name     varchar2(30),
  subpartition_name  varchar2(30),
  head_rowid         urowid,
  analyze_timestamp  date
);
Select * From chained_rows;
--参数视图
SELECT name,value                                                                                                                            
  FROM v$parameter                                                                                                                           
 WHERE name = 'db_block_size';    
 Create Table chained_rows As Select * from xst12 Where
 Rownum <=1 
--分析表xst12 将产生迁移的记录插入chained_rows 
Analyze Table xst12 List Chained Rows Into chained_rows;
--检查所有表是否存在迁移
Select 'analyze table '|| table_name ||' list chained rows into chained_rows;' From user_tables ;
第四章 表的设计
五朵金花:普通堆表,全局临时表,分区表,索引组织表,簇表(132)
没有最高级的技术,只有最合适的技术
4.2.2 普通堆表 
 不足之处 : 
    a 更新有日志开销  解决:全局临时表 : 无需写日志
    b delete不会释放空间   解决:全局临时表和分区表
    c 表记录太大,检索太慢    解决:分区表:高效的清理数据,释放空间,缩短访问路径.
    d 索引回表读开销很大    解决:索引组织表
    e 有序插入难有序读出    解决:簇表              
--查看产生多少日志
Select a.name, b.VALUE
  From v$statname a
  Left Join V$mystat b
    On a.statistic# = b.STATISTIC#
 Where a.name = 'redo size';
4.2.2.1 insert,update,delete三种更新操作都会产生日志.
4.2.2.2, delete(DML) 删除无法释放空间;delete后的空间是insert的首选空间.
    truncate(DDL) 删除后直接释放空间;无法按条件删除表数据,但可以删除分区;
--oracle10g的回收站功能，并没有彻底的删除表，而是把表放入回收站
Select a.object_name, a.original_name, a.type From User_Recyclebin a;
Purge User_Recyclebin;
--删除Table不进入Recycle的方法：
drop table tableName purge;
alter table t truncate partition '分区名' ;分区表:高效的清理数据,释放空间.
4.2.2.3 提升检索速度 :缩短访问路径.
    解决技术:索引技术:按条件查出的数据相比总数据非常少,不适用于更新非常频繁的表.
                    分区技术:一个取就是一个segment,可以直接确定到条件所在区.
4.2.2.4 索引回表读 table access by index rowid 
    1 ,含义:根据索引检索记录,会有先从索引中找记录,再根据索引列的rowid定位到表中从而返回索引列以外其他列的动作.
4.2.2.5 有序插入却难有序读出
    1原因: 如果segment中存在delete后的空间,insert会先填补这些空间.
    2解决: a,在order by的排序列上加索引,b,将普通表改为有序散列聚簇表
4.2.3 全局临时表  Global Temporary table
4.2.3.1 类型 :   基于session (on commit preserve rows)
create global temporary table tmpSession on commit preserve rows as select * from dba_objects
                        基于事务 (on commit delete rows)
create global temporary table tmpTransaction on commit delete rows as select * from dba_objects     
4.2.3.2 DML的REDO量
 无论Insert ,,Update ,Delete 普通表产生的日志逗比全局临时表多;
4..2.3.3 特性
a,高效删除记录 :基于事务的全局临时表commit或是session连接退出后临时表记录自动删除
    基于session的,只在退出session后表记录自动删除.
    此时只产生commit的日志,几乎可忽略
b,不同session数据独立,不同的session访问全局临时表看到结果不同.
--查看sessionID
Select * From v$mystat Where Rownum <=1
应用:基于session :使用率高;
         基于事务 : 一次事务中需要记录清空再插入等复杂动作.
4.2.4 分区表 partition
4.2.4.1 原理及类型
1 原理 : 一个分区就对应一个segment;普通表仅有一个segment
将大对象切割成小对象,从而直接定位小对象
2 分类 a 范围分区 : 使用最广泛,最常见的是按时间列进行分区.
 --创建范围分区表
 Create Table range_part_tab (Id number,dealdate date,areacode Number,
 Contents Varchar2(4000))
 Partition By Range(dealdate)
 (
 Partition p1 Values Less than (to_date('2012-06-01','YYYY-MM-DD')),
 Partition p12 Values Less than (to_date('2013-01-01','YYYY-MM-DD')),
 Partition pmax Values Less Than (Maxvalue)
 );
--插入数据
Insert Into range_part_tab
    (id, dealdate, areacode, contents)
    Select rownum,
           to_date(to_char(Sysdate - 365, 'J') +
                   trunc(dbms_random.value(0, 365)),
                   'J'),
           Ceil(Dbms_Random.value(590, 599)),
           Rpad('*', 400, '*')
      From dual
    Connect By Rownum <= 1000;
 Select * From range_part_tab
 Drop Table range_part_tab Purge
        关键字 :   partition by range(关键字)
                        values less than 指明具体的范围  2012-06-01  小于6月份的记录
                        partition pmax values less than (maxvalue)  表示超出 2013-01-01 的记录都落在此segment.
        b 列表分区
 --创建列表分区表
 Create Table list_part_tab (Id number,dealdate date,areacode Number,
 Contents Varchar2(4000))
 Partition By list(areacode)
 (
 Partition p1 Values  (591),
 Partition p9 Values  (599),
 Partition pothers Values  (default)
 );
--插入数据
Insert Into list_part_tab
    (id, dealdate, areacode, contents)
    Select rownum,
           to_date(to_char(Sysdate - 365, 'J') +
                   trunc(dbms_random.value(0, 365)),
                   'J'),
           Ceil(Dbms_Random.value(590, 599)),
           Rpad('*', 400, '*')
      From dual
    Connect By Rownum <= 1000;
 --查询
 Select * From list_part_tab
 --直接删除,不经过Oracle回收站
 Drop Table list_part_tab Purge
         关键字 : partition by list(关键字)
                       values(),可以为多个, partition p values(591,592)
                       Partition pothers Values  (default) 表示非指定记录都落在此默认分区
                       分区表的分区可分别指定在不同的表空间,不写即为同一默认表空间
        c 散列分区(HASH分区)
优:将数据按一定hash算法均匀的分不到不同分区中,从而避免热点块的竞争,改善IO;
劣:无法让指定的数据到指定的分区
 --创建列表分区表
 Create Table hash_part_tab (Id number,dealdate date,areacode Number,
 Contents Varchar2(4000))
 Partition By hash(dealdate)
 Partitions 2  
-- Store In (tbs1,tbs2);--分别存在两个表空间
--插入数据
Insert Into hash_part_tab
    (id, dealdate, areacode, contents)
    Select rownum,
           to_date(to_char(Sysdate - 365, 'J') +
                   trunc(dbms_random.value(0, 365)),
                   'J'),
           Ceil(Dbms_Random.value(590, 599)),
           Rpad('*', 400, '*')
      From dual
    Connect By Rownum <= 1000;
 --查询
 Select * From hash_part_tab
 --直接删除,不经过Oracle回收站
 Drop Table hash_part_tab Purge
       关键字 : partition by hash(关键字)
                     Partitions 2  没有指定分区名,仅指定分区个数
                     分区个数尽量设置为偶数个,与oracle内部架构有关 
                     store in (tbs1,tbs2)  分区表的分区可分别指定在不同的表空间,不写即为同一默认表空间
     d 组合分区 11g以前只支持range-list 和 range-hash
--range-list
    Create table sales  
    (  
       Product_id varchar2(5),  
       Sales_date date,  
       Sales_cost number(10),  
       Status varchar2(20)  
    )  
    Partition by range(Sales_cost)  
    Subpartition by list(status)  
    (  
       Partition p1 values less than (1) tablespace dinya_space01  
       (  
           Subpartition p1sub1 values('ACTIVE') tablespace   dinya_space03,  
           Subpartition p1sub2 values('INACTIVE') tablespace dinya_space04  
       ),  
       Partition p2 values less than (3) tablespace dinya_space02  
       (  
           Subpartition p1sub3 values('ACTIVE') tablespace    dinya_space05,  
           Subpartition p1sub4 values('INACTIVE') tablespace dinya_space06  
       )  
    )  
--range-hash
    create table dinya_test  
    (  
           transaction_id number primary key,  
           item_id number(8) not null,  
       　  item_description varchar2(300),  
     　    transaction_date date  
    )  
    partition by range(transaction_date)subpartition by hash(transaction_id)  
           subpartitions 3 store in (dinya_space07,dinya_space08,dinya_space09)  
    (  
           partition part_07 values less than(to_date('2006-01-01','yyyy-mm-dd')),  
           partition part_08 values less than(to_date('2010-01-01','yyyy-mm-dd')),  
           partition part_09 values less than(maxvalue)  
    );  
 3,操作 
    a,分区清除
        alter table range_part_tab truncate partition p1;
    b,分区交换,
        是对两个segment的数据的交换,
        交换可逆
        alter table range_part_tab EXCHANGE partition p1 WITH TABLE mid_table;
        select count(*) from range_part_tab partition(p8);
    c,分区分割
        alter table range_part_tab SPLIT partition pmax AT (to_date('2016-02-01','YYYY-MM-DD'))
INTO (Partition p201601,Partition pmax)
        关键字 at 说明具体的范围,小于某个指定的值
                    into 说明分区被切割成两个分区
    d 分区合并
        alter table range_part_tab MERGE partition p201601 ,pmax INTO partition pamx;
        关键字 merge 说明要合并的两个分区名
                    into 说明合并后分区名,可为新的,也可为旧的
    e 分区增删
        alter table range_part_tab add partition p201602 values less than (to_date('2016-03-01','YYYY-MM-DD'));
        最后一个分区是maxvalue时,只能split不能追加.可以删掉maxvalue,然后新增.
        alter table range_part_tab drop partition pmax;
4.2.4.3 分区索引类型 
--!!注:索引的高度比较低,容易受影响.
--全局索引
Create Index idx_part_tab_date On range_part_tab(dealdate);
--局部索引
Create Index idx_part_tab_area On range_part_tab(areacode) LOCAL;
分区表的分区操作(truncate,add,drop,exchange..),对局部索引一般都没有影响,但对全局索引影响比较大.
--索引失效后重建
Alter Index idx_part_tab_date rebuild;
--分区操作同时重建索引 update global indexes 
Alter Table idx_part_tab_area Truncate Partition p2 Update  Global  Indexes ;
4.2.5 索引组织表
--创建索引组织表
 Create Table org_index_tab (Id number,dealdate date,areacode Number,
 Contents Varchar2(4000),Primary Key (id)) Organization index; 
a, 表就是索引,索引就是表.
b,不会产生回表 table access by index rowid;
c,适用在少更新,频繁读的情况,例如地区配置表
4.2.6 簇表:用来避免排序;
避免排序的另一个方法:排序列正好是索引列
 1、创建簇的 格式
 CREATE CLUSTER cluster_name
 (column date_type [,column datatype]...)
 [PCTUSED 40 | integer] [PCTFREE 10 | integer]
 [SIZE integer]
 [INITRANS 1 | integer] [MAXTRANS 255 | integer]
 [TABLESPACE tablespace]
 [STORAGE storage]
 SIZE：指定估计平均簇键，以及与其相关的行所需的字节数。
 2、创建簇
 create cluster my_clu (deptno number )
 pctused 60
 pctfree 10
 size 1024
 tablespace users
 storage (
 initial 128 k
 next 128 k
 minextents 2
 maxextents 20
 );
 3、创建簇表
 create table t1_dept(
 deptno number ,
 dname varchar2 ( 20 )
 )
 cluster my_clu(deptno);
 create table t1_emp(
 empno number ,
 ename varchar2 ( 20 ),
 birth_date date ,
 deptno number
 )
 cluster my_clu(deptno);
 4、为簇创建索引
 create index clu_index on cluster my_clu;
 注：若不创建索引，则在插入数据时报错：ORA-02032: clustered tables cannot be used before the cluster index is built 
第五章 索引 
索引的三大特点
    1,索引树的高度一般都比较低;
    2,索引由索引列存储的值及Rowid组成;
    3,索引本身是有序的
索引查询
--用户索引字典
Select index_name,
       blevel,--索引树所在层数
       leaf_blocks,--Leaf(叶子块)的数目
       num_rows,
       distinct_keys,
       clustering_factor
  From user_ind_statistics;
