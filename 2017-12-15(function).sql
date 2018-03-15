[����36] �����ȣ�� �Է� ������ �޾Ƽ� �� ����� �̸�, �޿�, �μ� �̸��� ����ϴ� ���ν��� ���α׷��� �����ϼ���.
       �� 100�� ����� �Է� ������ ������ ���α׷��� �ƹ��� �۾����� �ʰ� ���� �� �� �־�� �մϴ�. 
       ���� ����� ���� ��� ���� ���� ó�����ּ���.


SQL> execute query_emp(100)

PL/SQL procedure successfully completed.


SQL> execute query_emp(101)
��� �̸�: Kochhar ��� �޿�: 17000 ��� �μ� �̸�: Executive

PL/SQL procedure successfully completed.


SQL> execute query_emp(300)
300 �������� �ʴ� ����Դϴ�.

PL/SQL procedure successfully completed.

--------------------------------------------------------------------------------
select * from user_objects;

select last_name, salary, 
       (select department_name
        from departments
        where department_id = e.department_id)
from employees e
where employee_id = 100;

create or replace procedure query_emp
(p_id in employees.employee_id%type)
is 
   type rec_type is record(lname varchar2(30),
                           sal number,
                           dname varchar2(30));
   v_rec rec_type;
begin
    select last_name, salary, 
       (select department_name
        from departments
        where department_id = e.department_id)
    into v_rec
    from employees e
    where employee_id = p_id;
    
    if p_id <> 100 then
      dbms_output.put_line('��� �̸�: '||v_rec.lname||
      '��� �޿�: '||v_rec.sal||' ��� �μ� �̸�: '||v_rec.dname);
    end if;
  /* ���࿡ �Ʒ��� ���������� �Ǿ� �ִٸ� 100����� ���� exception ó�� �ؾ��� */
exception
    when no_data_found then
      dbms_output.put_line(p_id||' �������� �ʴ� ����Դϴ�.');
  /* when others then
      dbms_output.put_line(sqlcode);
      dbms_output.put_line(sqlerrm); */
end query_emp;
/

show error

/* ���� */
select text
from user_source
where name = 'QUERY_EMP'
order by line; 

exec query_emp(100)
exec query_emp(102)
exec query_emp(300)


/* SQL���忡�� ����Ϸ��� �Լ��� ����, ȣ�⸸ �Ϸ��� ���ν����� ���� */
/* ���ν��� return���� �ڿ� �ƹ��͵� ���� �ȵ�(return;) : ���α׷� ������ �������� ���� 
   - �Լ� return���� �ٸ� 
   - if ���� then return; end if; */
/* DML�� �ؿ��� exception���� �����ȴٸ� ��������Ǳ⿡ rollback �Ǵ� commit�� ����
   �� ������ ���ؾ� ��(ȣ���� �Ǵ� ������) */
   
/* ������ Ǯ�� 1 */  
create or replace procedure query_emp (p_id number)
is
	v_name 		varchar2(30);
	v_sal		number;
	v_dept_name	varchar2(30);
	e_raise   	exception;
begin
 if p_id = 100 then 
  raise e_raise;
 else
  select e.last_name, e.salary, d.department_name
  into v_name, v_sal, v_dept_name
  from employees e, departments d
  where e.department_id = d.department_id
  and e.employee_id = p_id;
  
  dbms_output.put_line('��� �̸�: '||v_name||' ��� �޿�: '||v_sal||' ��� �μ� �̸�: '||v_dept_name);
 end if;


exception
  when e_raise then
    null;
  when no_data_found then
    dbms_output.put_line(p_id ||' �������� �ʴ� ����Դϴ�.');
  when others then
    dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);
end query_emp;
/

show error



/* ������ Ǯ�� 2 */ 
create or replace procedure query_emp (p_id number)
is
	v_name 		varchar2(30);
	v_sal		number;
	v_dept_name	varchar2(30);
	e_raise   	exception;
begin

 if p_id = 100 then 
  return;
 else
  select e.last_name, e.salary, d.department_name
  into v_name, v_sal, v_dept_name
  from employees e, departments d
  where e.department_id = d.department_id
  and e.employee_id = p_id;
  
  dbms_output.put_line('��� �̸�: '||v_name||' ��� �޿�: '||v_sal||' ��� �μ� �̸�: '||v_dept_name);
 end if;

exception
  when no_data_found then
    dbms_output.put_line(p_id ||' �������� �ʴ� ����Դϴ�.');
  when others then
    dbms_output.put_line(sqlerrm);
end query_emp;
/

show error   
   
================================================================================

[����37] �����ȣ�� �Է°����� �޾Ƽ� �� ����� �ٹ��������� ����ϰ� �ٹ���������
180���� �̻��̸� �޿��� 20% �λ��� �޿��� ����, 
179���� ���� �۰ų� ���� 150���� ���� ũ�ų� ������  10%�λ��� �޿��� ����,
150���� �̸��� �ٹ��ڴ� �ƹ� �۾��� �������� �ʴ� ���α׷��� �ۼ��ϼ���.
�׽�Ʈ�� ������ rollback �մϴ�.

begin
  sal_update_proc(100);
  rollback;
end;
/
100 ����� �ٹ��������� 166 �Դϴ�. ���� �޿��� 24000 ������ �޿��� 26400 �Դϴ�.

begin
  sal_update_proc(103);
  rollback;
end;
/
103 ����� �ٹ��������� 136 �Դϴ�. 150 ���� �̸��Դϴ�.9000 �޿��� ���� �ȵ˴ϴ�.

/* update������ �߻��� Transaction�� ȣ���ڰ� rollback ���� */

select employee_id, trunc(months_between(sysdate, hire_date)), salary
from employees;

create or replace procedure sal_update_proc(p_id number)
is 
    v_mon number;
    v_sal number;
    v_sal_up number;
begin
    select trunc(months_between(sysdate, hire_date)), salary
    into v_mon, v_sal
    from employees
    where employee_id = p_id;
    
    if v_mon >= 180 then
      v_sal_up := v_sal * 1.2;
      dbms_output.put_line(p_id||' ����� �ٹ��������� '||v_mon||' �Դϴ�. ���� �޿��� '
      ||v_sal||' ������ �޿��� '||v_sal_up||' �Դϴ�.');
    elsif v_mon >= 150 and v_mon <= 179 then
      v_sal_up := v_sal * 1.1;
      dbms_output.put_line(p_id||' ����� �ٹ��������� '||v_mon||' �Դϴ�. ���� �޿��� '
      ||v_sal||' ������ �޿��� '||v_sal_up||' �Դϴ�.');      
    else
      dbms_output.put_line(p_id||' ����� �ٹ��������� '||v_mon||' �Դϴ�. 150 ���� �̸��Դϴ�. '
      ||v_sal||' �޿��� ���� �ȵ˴ϴ�.');   
      return;
    end if;
    
    update employees
    set salary = v_sal_up
    where employee_id = p_id;
exception
    when no_data_found then
      dbms_output.put_line('�Է��Ͻ� �����ȣ�� �ش��ϴ� ����� �������� �ʽ��ϴ�.');
end sal_update_proc;
/

/* ���� */
show error

select text
from user_source
where name = 'SAL_UPDATE_PROC'
order by line; 

begin
  sal_update_proc(100);
  rollback;
end;
/

begin
  sal_update_proc(103);
  rollback;
end;
/


/* ������ Ǯ�� */
create or replace procedure sal_update_proc(p_id number)
is
	v_mon     number;
	v_sal_be  number;
	v_sal_af  number;
begin
	SELECT salary, trunc(months_between(sysdate, hire_date))
	INTO v_sal_be, v_mon
	FROM employees
	WHERE employee_id = p_id;

	case  
	 when v_mon >= 180 then

		UPDATE employees
		SET salary = salary * 1.20
		WHERE employee_id = p_id
		RETURNING salary INTO v_sal_af;

		dbms_output.put_line(p_id||' ����� �ٹ��������� '
                                 ||v_mon||' �Դϴ�. ���� �޿��� '
				 ||v_sal_be|| ' ������ �޿��� '||v_sal_af ||' �Դϴ�.');
	 when v_mon between 150 and 179 then

		UPDATE employees
		SET salary = salary * 1.10
		WHERE employee_id = p_id
    		RETURNING salary INTO v_sal_af;
			dbms_output.put_line(p_id||' ����� �ٹ��������� '
                                 ||v_mon||' �Դϴ�. ���� �޿��� '
				 ||v_sal_be|| ' ������ �޿��� '||v_sal_af ||' �Դϴ�.');
	 else
		
		dbms_output.put_line(p_id||' ����� �ٹ��������� '||v_mon||' �Դϴ�. 150 ���� �̸��Դϴ�.'
                                         ||v_sal_be||' �޿��� ���� �ȵ˴ϴ�.');

	end case;
exception
  when no_data_found then
    dbms_output.put_line(p_id ||' �������� �ʴ� ����Դϴ�.');
  when others then
    dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);	
	
end sal_update_proc;
/

show error

================================================================================

create table sawon(id number, name varchar2(30), day date, deptno number);

create or replace procedure sawon_in_proc 
 /* in mode�� ���� �� ������ default�� ����(default, :=) */
(p_id number, p_name varchar2, p_day date default sysdate, p_deptno number := 0)
is 
begin

     insert into sawon(id, name, day, deptno)
     values(p_id, p_name, p_day, p_deptno);
end sawon_in_proc;
/

show error

/* ��ġ������� : �����Ű������� ���ĸŰ������� Ÿ�Ժ� ������ ���߾� �ִ� �� */
exec sawon_in_proc(1,'ȫ�浿',to_date('2017-10-10','yyyy-mm-dd'),10)


/* �̸�������� : default ������ ������ �Ϸ��� �� �����ϰ� �ʿ��� �͸� ���� �� */
exec sawon_in_proc(p_id=>2,p_name=>'����ȣ',p_deptno=>20)

/* ���չ�� */
exec sawon_in_proc(3,'������',p_day=>to_date('20020101','yyyymmdd'))

select * from sawon;

/* ���� ���̺� �������� */
drop table emp purge;
drop table dept purge;

/* ���̺� ���� */
create table emp as select * from employees;
create table dept as select * from departments;

/* �� ���̺� %_id�� pk �������� �ο� */
alter table emp
add constraint empid_pk primary key (employee_id);

alter table dept
add constraint deptid_pk primary key (department_id);

/* dept mgr_id�� fk �������� �ο�(emp emp_id�� ����) */
alter table dept
add constraint dept_mgr_id_fk
foreign key(manager_id) references emp(employee_id);

/* �������� ��Ȳ ��ȸ */
select * from user_constraints where table_name in ('EMP','DEPT');

/* �������� �ɸ� �÷� ��ȸ */
select * from user_cons_columns where table_name in ('EMP','DEPT');

--------------------------------------------------------------------------------

/* �ó����� #1 : ���� */
create or replace procedure add_dept
(p_name varchar2, p_mgr number, p_loc number)
is
     v_max number;
begin
     select max(department_id) into v_max from dept;
     
     insert into dept(department_id, department_name, manager_id, location_id)
     values(v_max+10, p_name, p_mgr, p_loc);
end add_dept;
/

/* 2��°���� fk ���ݵǼ� ������ ����, �ڵ� rollback */
begin
    add_dept('�濵����',100,1800);
    add_dept('ȸ����',99,1800);
    add_dept('�ڱݰ���',101,1500);
end;
/

select * from dept;

--------------------------------------------------------------------------------

/* �ó����� #2 : ȣ���� ������ ���ܻ��� ó�� */
create or replace procedure add_dept
(p_name varchar2, p_mgr number, p_loc number)
is
     v_max number;
begin
     select max(department_id) into v_max from dept;
     
     insert into dept(department_id, department_name, manager_id, location_id)
     values(v_max+10, p_name, p_mgr, p_loc);
end add_dept;
/


begin
    add_dept('�濵����',100,1800);
    add_dept('ȸ����',99,1800);
    add_dept('�ڱݰ���',101,1500);
exception
    when others then
       dbms_output.put_line(sqlerrm);
end;
/

select * from dept;
rollback;

--------------------------------------------------------------------------------

/* �ó����� #3 : ���α׷� ���ο��� ���ܻ��� ó��(����ȣ�� ����ó��) */
create or replace procedure add_dept
(p_name varchar2, p_mgr number, p_loc number)
is
     v_max number;
begin
     select max(department_id) into v_max from dept;
     
     insert into dept(department_id, department_name, manager_id, location_id)
     values(v_max+10, p_name, p_mgr, p_loc);
exception
    when others then
       dbms_output.put_line('error : ' ||p_name);
       dbms_output.put_line(sqlerrm);
end add_dept;
/


begin
    add_dept('�濵����',100,1800);
    add_dept('ȸ����',99,1800);
    add_dept('�ڱݰ���',101,1500);
end;
/

select * from dept;
rollback;

--------------------------------------------------------------------------------

/* ���� : ���� ����� ���� ���� ������ �ϴ� ����̶�� ������ ���� 
   dept_id�� ȣ��� ������� �� �ؾ� �Ǵµ�, ���� ��Ÿ�� ���� ����
   �� �߻��ߴٸ� ���ܻ������� �ش� �ο쿡�� dept_id�� ä��� ������
   �� null�� ���ִ°� �� ���� ������? */

create or replace procedure add_dept
(p_name varchar2, p_mgr number, p_loc number)
is
     v_max number;
begin
     select max(department_id) into v_max from dept;
     
     insert into dept(department_id, department_name, manager_id, location_id)
     values(v_max+10, p_name, p_mgr, p_loc);
exception
    when others then
       dbms_output.put_line('error : ' ||p_name);
       dbms_output.put_line(sqlerrm);
       insert into dept(department_id, department_name, manager_id, location_id)
       values(v_max+10, p_name, null, p_loc);
end add_dept;
/


begin
    add_dept('�濵����',100,1800);
    add_dept('ȸ����',99,1800);
    add_dept('�ڱݰ���',101,1500);
end;
/

select * from dept;
rollback;


select * from user_constraints where table_name in ('DEPARTMENTS','LOCATIONS');
select * from user_cons_columns where table_name in ('DEPARTMENTS','LOCATIONS');


================================================================================

/* DBA */

/* ������Ȳ ��ȸ */
select * from dba_users;

/* scott ���� ���� */
create user scott identified by oracle;

/* �α��� ���� �ο� */
grant create session to scott;

select * from dba_sys_privs where grantee = 'SCOTT';

--------------------------------------------------------------------------------

/* HR */

drop procedure query_emp;

create or replace procedure query_emp(p_id number)
is
      v_rec employees%rowtype;
begin 
      select * into v_rec from employees where employee_id = p_id;
      
      dbms_output.put_line(v_rec.last_name||' '||v_rec.job_id);
exception
      when no_data_found then 
        dbms_output.put_line(p_id||' �ش����� �����ϴ�.');
end;
/

show error

exec query_emp(100)
exec query_emp(300)

--------------------------------------------------------------------------------

/* SCOTT */

select * from hr.employees;
exec hr.query_emp(100);
/* hr�� ������ �ο� �ؾ���(�Ѵ� �۵��ȵ�) */ 

--------------------------------------------------------------------------------

/* HR */

grant execute on hr.query_emp to scott;

select * from user_tab_privs where grantee = 'SCOTT';

/* ���忡�� �Ʒ��� ���� �� ������ */
grant select on hr.employees to scott;

/* 
   �̷� ���� ���� ������ ���� select ������ �����ʰ� ������ ���븸 ���α׷����� ȣ���� ��
   �ְ� ������ �ο����ִ°� ���� �� �ǻ�Ȱ���� �̷������ ���� 
   ex) ����â�� ���� 
   
   view�� select �˾ƾ� �ϴϱ� �Ϲ��������� �̷��Ը� ����
*/

/* CREATE PROCEDURE ã�� */
select * from user_sys_privs;
select * from role_sys_privs;

/* WITH ADMIN_OPTION : DBA���� ������ �ο����� USER�� �ش� ������ �ٸ� USER���� �ο����ɿ��� */

--------------------------------------------------------------------------------

/* DBA */

/* ��� �� ���� �ִ� ���� */
grant select any table to hr with admin option;

--------------------------------------------------------------------------------

/* HR */
grant select any table to scott;

--------------------------------------------------------------------------------

/* CREATE PROCEDURE : ���ν���, �Լ�, ��Ű�� ����� �ִ� ���� (������ �͸���� ���� ����)*/

/* �Լ� function ���� */

create or replace function get_sal
(p_id in employees.employee_id%type) --> ������� �ǹ� ����
return number --> return�� ����� ��  / Ÿ�� ���� �ʿ�(������ ���� �ȵ�)
is
   v_sal number := 0;
begin
   select salary into v_sal from employees where employee_id = p_id;
   return v_sal; --> �Լ� return���� �� ����(������ �ʿ�) / ��������� ���ؼ��� ������ ���ϰ���(���� �ϳ���)
exception
   when no_data_found then
      return v_sal; 
end;
/

/* �Լ��� ȣ���� */

exec dbms_output.put_line(get_sal(100))

begin
   dbms_output.put_line(get_sal(100));
end;
/

declare
    v_sal number;
begin
    v_sal := get_sal(300);
    dbms_output.put_line(v_sal);
end;
/

select last_name, salary from employees;
select last_name, get_sal(employee_id) from employees;

================================================================================

[����38] �޿��� 3.3%�� ����ϴ� tax �Լ��� �����ϼ���.

SQL> SELECT employee_id, last_name, salary, tax(salary) FROM employees;

EMPLOYEE_ID LAST_NAME                SALARY TAX(SALARY)
----------- -------------------- ---------- -----------
        100 King                    35138.4   1159.5672
        101 Kochhar                   22627     746.691
        102 De Haan                 24889.7    821.3601
        103 Hunold                     9000         297

create or replace function tax
(f_sal employees.salary%type)
return number
is 
    v_tax_sal number := 0;
begin
    v_tax_sal := f_sal * 0.033;
    return v_tax_sal;
exception
    when no_data_found then
        return v_tax_sal;
end;
/

SELECT employee_id, last_name, salary, tax(salary) FROM employees;

/* ������ Ǯ�� */
create or replace function tax
(f_sal employees.salary%type)
return number
is 
begin
    return (f_sal * 0.033);
end;
/


[����39] �޿��� ����ϴ� get_annual_comp �Լ��� �����ϼ���.

SQL> SELECT employee_id,
     (salary*12) + (commission_pct*salary*12) ann_sal,
     get_annual_comp(salary,commission_pct) ann_sal2
     FROM employees;

EMPLOYEE_ID    ANN_SAL   ANN_SAL2  
----------- ---------- ---------- 
        100                288000    
        101                204000     
        102                204000    
        103                108000 

SELECT employee_id,
      (salary*12) + (commission_pct*salary*12) ann_sal
FROM employees;

/* Ǯ�� 1 */
create or replace function get_annual_comp (f_1 number, f_2 number)
return number
is
begin
    if f_2 is null then
      return(f_1*12);
    else
      return(f_1*12*(1 + f_2));
    end if;
end;
/

show error

SELECT employee_id,
      (salary*12) + (nvl(commission_pct,0)*salary*12) ann_sal,
       get_annual_comp(salary,commission_pct) ann_sal2
FROM employees;

/* Ǯ�� 2 */
create or replace function get_annual_comp (f_1 number, f_2 number)
return number
is
begin
      return(f_1*12*(1 + nvl(f_2,0)));
end;
/

select * from user_objects;

select text
from user_source
where name = 'GET_SAL'
order by line;

