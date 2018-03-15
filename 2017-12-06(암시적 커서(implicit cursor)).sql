select last_name 
from employees 
where employee_id = 100;

begin
select last_name 
from employees 
where employee_id = 100;
end;
/
/*
���� ����:
ORA-06550: line 2, column 1:
PLS-00428: an INTO clause is expected in this SELECT statement
06550. 00000 -  "line %s, column %s:\n%s"
*Cause:    Usually a PL/SQL compilation error.
*Action:
*/


desc employees;

/* �������(select-into) */
declare
     v_name varchar2(25); --> �ش� �÷��� ������ Ÿ�� �� ����� ������ ����
begin
     select last_name    
     into v_name         --> FETCH��(���α׷� ���ο��� select���� �۵��� �ʼ�����)
     from employees 
     where employee_id = 100;
     dbms_output.put_line(v_name);
end;
/


declare
     v_lname varchar2(25);
     v_fname varchar2(25);
begin
     select last_name, first_name    
     into v_lname, v_fname         --> FETCH��
     from employees 
     where employee_id = 100;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/

/* 
# �Ͻ��� cursor(sql�� ����޸� ����) 
 - select into �� : �ݵ�� 1�� row�� fetch �ؾ���(����� cursor�� �ذᰡ��)
   * 0�� : no_data_found
   * 2�� �̻� : too_many_rows
 - DML
*/

declare
     v_name varchar2(25); 
begin
     select last_name    
     into v_name         
     from employees 
     where employee_id = 300;
     dbms_output.put_line(v_name);
end;
/
/*
���� ����:
ORA-01403: no data found
ORA-06512: at line 4
01403. 00000 -  "no data found"
*/


declare
     v_lname varchar2(25);
     v_fname varchar2(25);
begin
     select last_name, first_name    
     into v_lname, v_fname         --> FETCH��
     from employees 
     where department_id = 10;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/

declare
     v_lname varchar2(25);
     v_fname varchar2(25);
begin
     select last_name, first_name    
     into v_lname, v_fname         --> FETCH��
     from employees 
     where department_id = 20;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/
/*
���� ����:
ORA-01422: exact fetch returns more than requested number of rows
ORA-06512: at line 5
01422. 00000 -  "exact fetch returns more than requested number of rows"
*Cause:    The number specified in exact fetch is less than the rows returned.
*Action:   Rewrite the query or change number of rows requested
*/

select * from emp where department_id = 20;

/* tool���� �����ϴ� �ɷ� ���α׷� ���ο� ����ϸ� �ȵ� */   
--> bind, host, global ����ǥ��
var b_id number
exec :b_id := 100
print :b_id

declare
     v_lname varchar2(25);
     v_fname varchar2(25);
begin
     select last_name, first_name    
     into v_lname, v_fname         --> FETCH��
     from employees 
     where employee_id = :b_id;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/
 
/*
alter table employee modify last_name varchar2(50) 
 - �̷��� �����ϰ� �Ǹ� �ش� �÷��� ���� ������ �� �����ؾ� �ȴ�
�׷��� �ڵ����� �ٲ�� �ִٸ�? ���������� ����������
*/

declare
     v_lname employees.last_name%type; --> �ش� ���̺�.�÷��� Ÿ������ ���� ����
     v_fname v_lname%type;             --> ������ Ÿ���� �״�� �޾Ƽ� ����
     v_sal employees.salary%type;
begin
     select last_name, first_name, salary    
     into v_lname, v_fname, v_sal
     from employees 
     where employee_id = :b_id;
     dbms_output.put_line(upper(v_lname));
     dbms_output.put_line(upper(v_fname));
     dbms_output.put_line(ltrim(to_char(v_sal,'l999,99.00')));
end;
/

[����2] ��ü ����� ��� �޿��� ��� �ϴ� ���α׷� ���弼��.  
       ���α׷� ������ ���� �Ŀ��� ��ü ����� ��հ��� �̿��ؼ� 
       ��ü ����� ��� �޿� ���� ���� �޴� ����� ���� select ������ �ۼ��ϼ���.

select avg(salary) from employees;

var v_avgsal number
exec :v_avgsal
print :v_avgsal

begin
       select avg(salary)
       into :v_avgsal
       from employees;
       dbms_output.put_line(:v_avgsal);
end;
/
print :v_avgsal

select * 
from employees
where salary > :v_avgsal;

commit;

[����3] ��� ��ȣ�� �Է°����� �޾Ƽ� �׻���� ���, �̸�, �޿� ������ 
       ����ϴ� ���α׷��� �ۼ��ϼ���.

<ȭ�� ���>

���=> �����ȣ: 100, ����̸�: King, ����޿�: 24000

/* Ǯ��1 */
<<outer>>
declare 
       v_id employees.employee_id%type;
begin
       v_id := 100;
  declare 
       v_id employees.employee_id%type; --> ���� �� �ᵵ �� ��
       v_lname employees.last_name%type;
       v_sal employees.salary%type;
  begin
       select employee_id, last_name, salary
       into v_id, v_lname, v_sal
       from employees
       where employee_id = outer.v_id;
       dbms_output.put_line('�����ȣ: ' ||v_id||', '||'����̸�: '||v_lname||', '||'����޿�: '||v_sal);
  end;
end;
/

/* Ǯ��2 */
declare 
       v_id employees.employee_id%type;
       v_lname employees.last_name%type;
       v_sal employees.salary%type;
begin
       v_id := 100;
       select last_name, salary
       into v_lname, v_sal
       from employees
       where employee_id = v_id;
       dbms_output.put_line('�����ȣ: ' ||v_id||', '||'����̸�: '||v_lname||', '||'����޿�: '||v_sal);
end;
/

/* Ǯ��3 */
var v_id number
exec :v_id := 100
print :v_id

declare
       v_lname employees.last_name%type;
       v_sal employees.salary%type;
begin
       select last_name, salary
       into v_lname, v_sal
       from employees
       where employee_id = :v_id;
       dbms_output.put_line('�����ȣ: ' ||:v_id||', '||'����̸�: '||v_lname||', '||'����޿�: '||v_sal);
end;
/

[����4] ��� ��ȣ�� �Է°����� �޾Ƽ� �Ի���, �޿� ������ ����ϴ� ���α׷��� �ۼ��ϼ���.
<ȭ�� ���>

Hire date is : 2003�� 6�� 17��
Salary is : ��24,000.00

/* Ǯ��1 */
<<outer>>
declare 
       v_id employees.employee_id%type;
begin
       v_id := 100;
  declare 
       v_hire employees.hire_date%type;
       v_sal employees.salary%type;
  begin
       select hire_date, salary
       into v_hire, v_sal
       from employees
       where employee_id = outer.v_id;
       dbms_output.put_line('Hire date is : '||to_char(v_hire,'yyyy')||'�� '||to_char(v_hire,'month')||to_char(v_hire,'dd')||'��');
       dbms_output.put_line('Hire date is : '||to_char(v_hire, 'yyyy"��" fmmm"��" fmdd"��'));
       dbms_output.put_line('Salary is : '||ltrim(to_char(v_sal,'l99,999.00')));
  end;
end;
/

/* Ǯ��2 */
declare 
       v_id employees.employee_id%type;
       v_hire employees.hire_date%type;
       v_sal employees.salary%type;
begin
       v_id := 100;
       select hire_date, salary
       into v_hire, v_sal
       from employees
       where employee_id = v_id;
       dbms_output.put_line('Hire date is : '||to_char(v_hire,'yyyy')||'�� '||to_char(v_hire,'month')||to_char(v_hire,'dd')||'��');
       dbms_output.put_line('Hire date is : '||to_char(v_hire, 'yyyy"��" fmmm"��" fmdd"��'));
       dbms_output.put_line('Salary is : '||ltrim(to_char(v_sal,'l99,999.00')));
end;
/

/* Ǯ��3 */
var v_id number
exec :v_id := 100
print :v_id

declare 
       v_hire employees.hire_date%type;
       v_sal employees.salary%type;
begin
       select hire_date, salary
       into v_hire, v_sal
       from employees
       where employee_id = :v_id;
       dbms_output.put_line('Hire date is : '||to_char(v_hire, 'yyyy"��" fmmm"��" fmdd"��'));
       dbms_output.put_line('Salary is : '||ltrim(to_char(v_sal,'l99,999.00')));
end;
/

/* bind ������ ����, ���� Ÿ�Ը� */

================================================================================
 
 /* bind ������� : ���α׷��� ���ϼ��� �����ϱ� ����(�޸� ��뷮 ���̱� ����) */
 
1. DBA SESSION


ALTER SYSTEM FLUSH SHARED_POOL;
ALTER SYSTEM FLUSH SHARED_POOL;

select sql_id, sql_text, parse_calls, executions
from v$sql
where sql_text like '%employee%'
and sql_text not like '%v$sql%';

2. HR SESSION

declare
	v_id employees.employee_id%type := 100;
	v_name  employees.last_name%TYPE;
  	v_sal   employees.salary%TYPE;
begin
	SELECT last_name, salary
	INTO v_name, v_sal
	FROM employees
	WHERE employee_id = v_id;
	dbms_output.put_line('���=> '||'�����ȣ: 
'||v_id||', '||'����̸�: '||v_name||', '||'����޿�: '||
v_sal);
end;
/


declare
	v_id employees.employee_id%type := 101;
	v_name  employees.last_name%TYPE;
  	v_sal   employees.salary%TYPE;
begin
	SELECT last_name, salary
	INTO v_name, v_sal
	FROM employees
	WHERE employee_id = v_id;
	dbms_output.put_line('���=> '||'�����ȣ: 
'||v_id||', '||'����̸�: '||v_name||', '||'����޿�: '||
v_sal);
end;
/


3. DBA SESSION

select sql_id, sql_text, parse_calls, executions
from v$sql
where sql_text like '%employee%'
and sql_text not like '%v$sql%';




ALTER SYSTEM FLUSH SHARED_POOL;
ALTER SYSTEM FLUSH SHARED_POOL;

select sql_id, sql_text, parse_calls, executions
from v$sql
where sql_text like '%employee%'
and sql_text not like '%v$sql%';

4. HR SESSION

var v_id number
execute :v_id := 100
declare
	v_name  employees.last_name%TYPE;
  	v_sal   employees.salary%TYPE;
begin
	SELECT last_name, salary
	INTO v_name, v_sal
	FROM employees
	WHERE employee_id = :v_id;
	dbms_output.put_line('���=> '||'�����ȣ: '||:v_id||', '||'����̸�: '||v_name||', '||'����޿�: '||v_sal);
end;
/

execute :v_id := 101
declare
	v_name  employees.last_name%TYPE;
  	v_sal   employees.salary%TYPE;
begin
	SELECT last_name, salary
	INTO v_name, v_sal
	FROM employees
	WHERE employee_id = :v_id;
	dbms_output.put_line('���=> '||'�����ȣ: '||:v_id||', '||'����̸�: '||v_name||', '||'����޿�: '||v_sal);
end;
/

5. DBA SESSION

select sql_id, sql_text, parse_calls, executions
from v$sql
where sql_text like '%employee%'
and sql_text not like '%v$sql%';


================================================================================

/* DML */

drop table test purge;

create table test(id number, name varchar2(20), day date);

desc test;

insert into test(id, name, day)
values(1, 'tae_hyo', to_date('20171206','yyyymmdd'));

select * from test;

commit;

begin
     insert into test(id, name, day)
     values(1, 'tae_hyo', to_date('20171206','yyyymmdd'));
     commit; --> commit; �Ǵ� rollback; �ݵ�� �Է�
end;
/

begin
     insert into test(id, name, day)
     values(2, 'bruce', to_date('20171206','yyyymmdd'));
     commit;
end;
/

/* �� 2������ �������� 2���� �����ȹ�� �����ϰ� �޸� ����, ������ �ʿ� */

var b_id number
var b_name varchar2(20)
var b_day varchar2(30)

exec :b_id := 3
exec :b_name := 'hyo'
exec :b_day := '20171126'

print :b_id :b_name :b_day

begin
 insert into test(id, name, day)
 values(:b_id, :b_name, to_date(:b_day,'yyyymmdd'));
 commit;
end;
/

select * from test;

truncate table test;

================================================================================

update test
set name = 'ȫ�浿'
where id = 1;

update test
set name = '����ȣ'
where id = 3;

/* �̸��� �����ϴ� ���α׷� */

var b_id number
var b_name varchar2(20)

exec :b_id := 3
exec :b_name := '����ȣ'

begin
     update test
     set name = :b_name
     where id = :b_id;
     commit;
     dbms_output.put_line(sql%rowcount);
end;
/

select * from test;

--------------------------------------------------------------------------------

drop table emp purge;

create table emp as select * from employees;

update emp
set salary = salary * 1.1
where department_id = 20;

rollback;

begin
 delete from emp where department_id = 20;
 dbms_output.put_line(sql%rowcount||' ���� ����'); --> �������� row�� �Ǽ��� ������
 
 update emp
 set salary = salary * 1.1
 where department_id = 30;
 dbms_output.put_line(sql%rowcount||' ���� ����'); --> sql%rowcount : �Ͻ����� curcor �Ӽ�(������)
 rollback;
end;
/


begin
  update emp
  set salary = salary * 1.1
  where employee_id = 100;
  
  if sql%found then --> sql%found : �Ͻ����� curcor �Ӽ�(boolean��) T or F
     dbms_output.put_line('������');
  else
     dbms_output.put_line('�����ȵ�');
  end if;
  rollback;
end;
/

begin
  update emp
  set salary = salary * 1.1
  where employee_id = 500;
  
  if sql%notfound then --> sql%found : �Ͻ����� curcor �Ӽ�(boolean�� �ݴ��)
     dbms_output.put_line('�����ȵ�');
  else
     dbms_output.put_line('������');
  end if;
  rollback;
end;
/

/* �Ͻ��� cursor �Ӽ� 3����(DML ����� �Ǵ��ϴ� �Ӽ����θ� ����(select�� �������� �������� ��, ������))
1. sql%rowcount : DML������ �������� row�� �Ǽ��� ������
2. sql%found : DML������ �������� row�� ������ True, ������ False
3. sql%notfound : DML������ �������� row�� ������ True, ������ False
*/

