pipelined :管道函数
1,返回行集合,可以像物理表一样查询,也可以赋值给集合变量
2,并行执行,可以实时的输出函数执行过程中的信息
3,pipe row()用来返回集合的单个元素;
4,实例:拆分制定字符串的特定字符并返回表
create or replace function strsplit(p_value varchar2, p_split varchar2 := ',')
--usage: select * from table(strsplit('1,2,3,4,5')) 
return type_split 
pipelined is v_idx integer; 
v_str varchar2(4000); 
v_strs_last varchar2(4000) := p_value;
begin 
loop 
if substr(v_strs_last, length(v_strs_last), 1) = p_split then 
v_strs_last := substr(v_strs_last, 1, length(v_strs_last) - 1); 
if substr(v_strs_last, length(v_strs_last) - 1, 2) = p_split then 
v_strs_last := substr(v_strs_last, 1, length(v_strs_last) - 1); 
end if; 
end if; 
v_idx := instr(v_strs_last, p_split); 
exit when v_idx = 0; 
v_str := substr(v_strs_last, 1, v_idx - 1); 
v_strs_last := substr(v_strs_last, v_idx + 1); 
pipe row(v_str); 
end loop; 
pipe row(v_strs_last); 
return;
end ;