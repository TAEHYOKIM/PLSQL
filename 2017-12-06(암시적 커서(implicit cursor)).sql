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
오류 보고:
ORA-06550: line 2, column 1:
PLS-00428: an INTO clause is expected in this SELECT statement
06550. 00000 -  "line %s, column %s:\n%s"
*Cause:    Usually a PL/SQL compilation error.
*Action:
*/


desc employees;

/* 개선방법(select-into) */
declare
     v_name varchar2(25); --> 해당 컬럼과 동일한 타입 및 비슷한 사이즈 설정
begin
     select last_name    
     into v_name         --> FETCH절(프로그램 내부에서 select문이 작동의 필수조건)
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
     into v_lname, v_fname         --> FETCH절
     from employees 
     where employee_id = 100;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/

/* 
# 암시적 cursor(sql문 실행메모리 영역) 
 - select into 절 : 반드시 1개 row만 fetch 해야함(명시적 cursor로 해결가능)
   * 0개 : no_data_found
   * 2개 이상 : too_many_rows
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
오류 보고:
ORA-01403: no data found
ORA-06512: at line 4
01403. 00000 -  "no data found"
*/


declare
     v_lname varchar2(25);
     v_fname varchar2(25);
begin
     select last_name, first_name    
     into v_lname, v_fname         --> FETCH절
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
     into v_lname, v_fname         --> FETCH절
     from employees 
     where department_id = 20;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/
/*
오류 보고:
ORA-01422: exact fetch returns more than requested number of rows
ORA-06512: at line 5
01422. 00000 -  "exact fetch returns more than requested number of rows"
*Cause:    The number specified in exact fetch is less than the rows returned.
*Action:   Rewrite the query or change number of rows requested
*/

select * from emp where department_id = 20;

/* tool에서 지원하는 걸로 프로그램 내부에 사용하면 안됨 */   
--> bind, host, global 변수표현
var b_id number
exec :b_id := 100
print :b_id

declare
     v_lname varchar2(25);
     v_fname varchar2(25);
begin
     select last_name, first_name    
     into v_lname, v_fname         --> FETCH절
     from employees 
     where employee_id = :b_id;
     dbms_output.put_line(v_lname);
     dbms_output.put_line(v_fname);
     dbms_output.put_line(v_lname||v_fname);
end;
/
 
/*
alter table employee modify last_name varchar2(50) 
 - 이렇게 수정하게 되면 해당 컬럼에 대한 변수도 다 수정해야 된다
그런데 자동으로 바뀔수 있다면? 유지관리가 편해지겠지
*/

declare
     v_lname employees.last_name%type; --> 해당 테이블.컬럼의 타입으로 변수 생성
     v_fname v_lname%type;             --> 변수의 타입을 그대로 받아서 생성
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

[문제2] 전체 사원의 평균 급여를 출력 하는 프로그램 만드세요.  
       프로그램 수행이 끝난 후에도 전체 사원의 평균값을 이용해서 
       전체 사원의 평균 급여 보다 많이 받는 사원의 정보 select 문장을 작성하세요.

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

[문제3] 사원 번호를 입력값으로 받아서 그사원의 사번, 이름, 급여 정보를 
       출력하는 프로그램을 작성하세요.

<화면 결과>

결과=> 사원번호: 100, 사원이름: King, 사원급여: 24000

/* 풀이1 */
<<outer>>
declare 
       v_id employees.employee_id%type;
begin
       v_id := 100;
  declare 
       v_id employees.employee_id%type; --> 굳이 안 써도 될 듯
       v_lname employees.last_name%type;
       v_sal employees.salary%type;
  begin
       select employee_id, last_name, salary
       into v_id, v_lname, v_sal
       from employees
       where employee_id = outer.v_id;
       dbms_output.put_line('사원번호: ' ||v_id||', '||'사원이름: '||v_lname||', '||'사원급여: '||v_sal);
  end;
end;
/

/* 풀이2 */
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
       dbms_output.put_line('사원번호: ' ||v_id||', '||'사원이름: '||v_lname||', '||'사원급여: '||v_sal);
end;
/

/* 풀이3 */
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
       dbms_output.put_line('사원번호: ' ||:v_id||', '||'사원이름: '||v_lname||', '||'사원급여: '||v_sal);
end;
/

[문제4] 사원 번호를 입력값으로 받아서 입사일, 급여 정보를 출력하는 프로그램을 작성하세요.
<화면 결과>

Hire date is : 2003년 6월 17일
Salary is : ￦24,000.00

/* 풀이1 */
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
       dbms_output.put_line('Hire date is : '||to_char(v_hire,'yyyy')||'년 '||to_char(v_hire,'month')||to_char(v_hire,'dd')||'일');
       dbms_output.put_line('Hire date is : '||to_char(v_hire, 'yyyy"년" fmmm"월" fmdd"일'));
       dbms_output.put_line('Salary is : '||ltrim(to_char(v_sal,'l99,999.00')));
  end;
end;
/

/* 풀이2 */
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
       dbms_output.put_line('Hire date is : '||to_char(v_hire,'yyyy')||'년 '||to_char(v_hire,'month')||to_char(v_hire,'dd')||'일');
       dbms_output.put_line('Hire date is : '||to_char(v_hire, 'yyyy"년" fmmm"월" fmdd"일'));
       dbms_output.put_line('Salary is : '||ltrim(to_char(v_sal,'l99,999.00')));
end;
/

/* 풀이3 */
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
       dbms_output.put_line('Hire date is : '||to_char(v_hire, 'yyyy"년" fmmm"월" fmdd"일'));
       dbms_output.put_line('Salary is : '||ltrim(to_char(v_sal,'l99,999.00')));
end;
/

/* bind 변수는 숫자, 문자 타입만 */

================================================================================
 
 /* bind 사용이유 : 프로그램의 동일성을 유지하기 위해(메모리 사용량 줄이기 위해) */
 
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
	dbms_output.put_line('결과=> '||'사원번호: 
'||v_id||', '||'사원이름: '||v_name||', '||'사원급여: '||
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
	dbms_output.put_line('결과=> '||'사원번호: 
'||v_id||', '||'사원이름: '||v_name||', '||'사원급여: '||
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
	dbms_output.put_line('결과=> '||'사원번호: '||:v_id||', '||'사원이름: '||v_name||', '||'사원급여: '||v_sal);
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
	dbms_output.put_line('결과=> '||'사원번호: '||:v_id||', '||'사원이름: '||v_name||', '||'사원급여: '||v_sal);
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
     commit; --> commit; 또는 rollback; 반드시 입력
end;
/

begin
     insert into test(id, name, day)
     values(2, 'bruce', to_date('20171206','yyyymmdd'));
     commit;
end;
/

/* 위 2가지도 마찬가지 2가지 실행계획을 생성하고 메모리 낭비, 개선이 필요 */

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
set name = '홍길동'
where id = 1;

update test
set name = '박찬호'
where id = 3;

/* 이름을 수정하는 프로그램 */

var b_id number
var b_name varchar2(20)

exec :b_id := 3
exec :b_name := '팍찬호'

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
 dbms_output.put_line(sql%rowcount||' 행이 삭제'); --> 영향입은 row의 건수를 보여짐
 
 update emp
 set salary = salary * 1.1
 where department_id = 30;
 dbms_output.put_line(sql%rowcount||' 행이 수정'); --> sql%rowcount : 암시적이 curcor 속성(정수값)
 rollback;
end;
/


begin
  update emp
  set salary = salary * 1.1
  where employee_id = 100;
  
  if sql%found then --> sql%found : 암시적이 curcor 속성(boolean값) T or F
     dbms_output.put_line('수정됨');
  else
     dbms_output.put_line('수정안됨');
  end if;
  rollback;
end;
/

begin
  update emp
  set salary = salary * 1.1
  where employee_id = 500;
  
  if sql%notfound then --> sql%found : 암시적이 curcor 속성(boolean값 반대로)
     dbms_output.put_line('수정안됨');
  else
     dbms_output.put_line('수정됨');
  end if;
  rollback;
end;
/

/* 암시적 cursor 속성 3가지(DML 결과를 판단하는 속성으로만 쓰자(select은 쓸데없는 로직구현 됨, 사용금지))
1. sql%rowcount : DML문으로 영향입은 row의 건수를 보여짐
2. sql%found : DML문으로 영향입은 row가 있으면 True, 없으면 False
3. sql%notfound : DML문으로 영향입은 row가 없으면 True, 있으면 False
*/

