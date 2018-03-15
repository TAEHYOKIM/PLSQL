[문제36] 사원번호를 입력 값으로 받아서 그 사원의 이름, 급여, 부서 이름을 출력하는 프로시저 프로그램을 생성하세요.
       단 100번 사원이 입력 값으로 들어오면 프로그램은 아무런 작업하지 않고 종료 될 수 있어야 합니다. 
       또한 사원이 없을 경우 예외 사항 처리해주세요.


SQL> execute query_emp(100)

PL/SQL procedure successfully completed.


SQL> execute query_emp(101)
사원 이름: Kochhar 사원 급여: 17000 사원 부서 이름: Executive

PL/SQL procedure successfully completed.


SQL> execute query_emp(300)
300 존재하지 않는 사원입니다.

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
      dbms_output.put_line('사원 이름: '||v_rec.lname||
      '사원 급여: '||v_rec.sal||' 사원 부서 이름: '||v_rec.dname);
    end if;
  /* 만약에 아래로 로직구현이 되어 있다면 100사원에 대해 exception 처리 해야함 */
exception
    when no_data_found then
      dbms_output.put_line(p_id||' 존재하지 않는 사원입니다.');
  /* when others then
      dbms_output.put_line(sqlcode);
      dbms_output.put_line(sqlerrm); */
end query_emp;
/

show error

/* 검토 */
select text
from user_source
where name = 'QUERY_EMP'
order by line; 

exec query_emp(100)
exec query_emp(102)
exec query_emp(300)


/* SQL문장에서 사용하려면 함수로 개발, 호출만 하려면 프로시저로 개발 */
/* 프로시저 return문은 뒤에 아무것도 쓰면 안됨(return;) : 프로그램 무조건 정상적인 종료 
   - 함수 return문과 다름 
   - if 조건 then return; end if; */
/* DML문 밑에서 exception으로 가버렸다면 정상종료되기에 rollback 또는 commit을 누가
   할 것인지 정해야 함(호출자 또는 제공자) */
   
/* 선생님 풀이 1 */  
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
  
  dbms_output.put_line('사원 이름: '||v_name||' 사원 급여: '||v_sal||' 사원 부서 이름: '||v_dept_name);
 end if;


exception
  when e_raise then
    null;
  when no_data_found then
    dbms_output.put_line(p_id ||' 존재하지 않는 사원입니다.');
  when others then
    dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);
end query_emp;
/

show error



/* 선생님 풀이 2 */ 
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
  
  dbms_output.put_line('사원 이름: '||v_name||' 사원 급여: '||v_sal||' 사원 부서 이름: '||v_dept_name);
 end if;

exception
  when no_data_found then
    dbms_output.put_line(p_id ||' 존재하지 않는 사원입니다.');
  when others then
    dbms_output.put_line(sqlerrm);
end query_emp;
/

show error   
   
================================================================================

[문제37] 사원번호를 입력값으로 받아서 그 사원의 근무개월수를 출력하고 근무개월수가
180개월 이상이면 급여를 20% 인상한 급여로 수정, 
179개월 보다 작거나 같고 150개월 보다 크거나 같으면  10%인상한 급여로 수정,
150개월 미만인 근무자는 아무 작업을 수행하지 않는 프로그램을 작성하세요.
테스트가 끝나면 rollback 합니다.

begin
  sal_update_proc(100);
  rollback;
end;
/
100 사원은 근무개월수가 166 입니다. 이전 급여는 24000 수정된 급여는 26400 입니다.

begin
  sal_update_proc(103);
  rollback;
end;
/
103 사원은 근무개월수가 136 입니다. 150 개월 미만입니다.9000 급여는 수정 안됩니다.

/* update문으로 발생된 Transaction은 호출자가 rollback 실행 */

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
      dbms_output.put_line(p_id||' 사원은 근무개월수가 '||v_mon||' 입니다. 이전 급여는 '
      ||v_sal||' 수정된 급여는 '||v_sal_up||' 입니다.');
    elsif v_mon >= 150 and v_mon <= 179 then
      v_sal_up := v_sal * 1.1;
      dbms_output.put_line(p_id||' 사원은 근무개월수가 '||v_mon||' 입니다. 이전 급여는 '
      ||v_sal||' 수정된 급여는 '||v_sal_up||' 입니다.');      
    else
      dbms_output.put_line(p_id||' 사원은 근무개월수가 '||v_mon||' 입니다. 150 개월 미만입니다. '
      ||v_sal||' 급여는 수정 안됩니다.');   
      return;
    end if;
    
    update employees
    set salary = v_sal_up
    where employee_id = p_id;
exception
    when no_data_found then
      dbms_output.put_line('입력하신 사원번호에 해당하는 사원은 존재하지 않습니다.');
end sal_update_proc;
/

/* 검증 */
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


/* 선생님 풀이 */
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

		dbms_output.put_line(p_id||' 사원은 근무개월수가 '
                                 ||v_mon||' 입니다. 이전 급여는 '
				 ||v_sal_be|| ' 수정된 급여는 '||v_sal_af ||' 입니다.');
	 when v_mon between 150 and 179 then

		UPDATE employees
		SET salary = salary * 1.10
		WHERE employee_id = p_id
    		RETURNING salary INTO v_sal_af;
			dbms_output.put_line(p_id||' 사원은 근무개월수가 '
                                 ||v_mon||' 입니다. 이전 급여는 '
				 ||v_sal_be|| ' 수정된 급여는 '||v_sal_af ||' 입니다.');
	 else
		
		dbms_output.put_line(p_id||' 사원은 근무개월수가 '||v_mon||' 입니다. 150 개월 미만입니다.'
                                         ||v_sal_be||' 급여는 수정 안됩니다.');

	end case;
exception
  when no_data_found then
    dbms_output.put_line(p_id ||' 존재하지 않는 사원입니다.');
  when others then
    dbms_output.put_line(sqlcode);
    dbms_output.put_line(sqlerrm);	
	
end sal_update_proc;
/

show error

================================================================================

create table sawon(id number, name varchar2(30), day date, deptno number);

create or replace procedure sawon_in_proc 
 /* in mode시 값이 안 들어오면 default로 지정(default, :=) */
(p_id number, p_name varchar2, p_day date default sysdate, p_deptno number := 0)
is 
begin

     insert into sawon(id, name, day, deptno)
     values(p_id, p_name, p_day, p_deptno);
end sawon_in_proc;
/

show error

/* 위치지정방식 : 실제매개변수가 형식매개변수의 타입별 순서에 맞추어 넣는 것 */
exec sawon_in_proc(1,'홍길동',to_date('2017-10-10','yyyy-mm-dd'),10)


/* 이름지정방식 : default 값으로 나오게 하려는 것 제외하고 필요한 것만 넣을 때 */
exec sawon_in_proc(p_id=>2,p_name=>'박찬호',p_deptno=>20)

/* 조합방식 */
exec sawon_in_proc(3,'박지성',p_day=>to_date('20020101','yyyymmdd'))

select * from sawon;

/* 기존 테이블 완전삭제 */
drop table emp purge;
drop table dept purge;

/* 테이블 생성 */
create table emp as select * from employees;
create table dept as select * from departments;

/* 각 테이블 %_id에 pk 제약조건 부여 */
alter table emp
add constraint empid_pk primary key (employee_id);

alter table dept
add constraint deptid_pk primary key (department_id);

/* dept mgr_id에 fk 제약조건 부여(emp emp_id에 대한) */
alter table dept
add constraint dept_mgr_id_fk
foreign key(manager_id) references emp(employee_id);

/* 제약조건 현황 조회 */
select * from user_constraints where table_name in ('EMP','DEPT');

/* 제약조건 걸린 컬럼 조회 */
select * from user_cons_columns where table_name in ('EMP','DEPT');

--------------------------------------------------------------------------------

/* 시나리오 #1 : 실패 */
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

/* 2번째에서 fk 위반되서 비정상 종료, 자동 rollback */
begin
    add_dept('경영지원',100,1800);
    add_dept('회계팀',99,1800);
    add_dept('자금관리',101,1500);
end;
/

select * from dept;

--------------------------------------------------------------------------------

/* 시나리오 #2 : 호출자 측에서 예외사항 처리 */
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
    add_dept('경영지원',100,1800);
    add_dept('회계팀',99,1800);
    add_dept('자금관리',101,1500);
exception
    when others then
       dbms_output.put_line(sqlerrm);
end;
/

select * from dept;
rollback;

--------------------------------------------------------------------------------

/* 시나리오 #3 : 프로그램 내부에서 예외사항 처리(정상호출 정상처리) */
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
    add_dept('경영지원',100,1800);
    add_dept('회계팀',99,1800);
    add_dept('자금관리',101,1500);
end;
/

select * from dept;
rollback;

--------------------------------------------------------------------------------

/* 번외 : 만약 당신이 위와 같은 업무를 하는 사원이라고 가정해 보자 
   dept_id가 호출된 순서대로 꼭 해야 되는데, 단지 오타로 인해 오류
   가 발생했다면 예외사항으로 해당 로우에서 dept_id라도 채우고 나머지
   는 null로 해주는게 더 낫지 않을까? */

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
    add_dept('경영지원',100,1800);
    add_dept('회계팀',99,1800);
    add_dept('자금관리',101,1500);
end;
/

select * from dept;
rollback;


select * from user_constraints where table_name in ('DEPARTMENTS','LOCATIONS');
select * from user_cons_columns where table_name in ('DEPARTMENTS','LOCATIONS');


================================================================================

/* DBA */

/* 계정현황 조회 */
select * from dba_users;

/* scott 계정 생성 */
create user scott identified by oracle;

/* 로그인 권한 부여 */
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
        dbms_output.put_line(p_id||' 해당사원은 없습니다.');
end;
/

show error

exec query_emp(100)
exec query_emp(300)

--------------------------------------------------------------------------------

/* SCOTT */

select * from hr.employees;
exec hr.query_emp(100);
/* hr이 권한을 부여 해야함(둘다 작동안됨) */ 

--------------------------------------------------------------------------------

/* HR */

grant execute on hr.query_emp to scott;

select * from user_tab_privs where grantee = 'SCOTT';

/* 현장에서 아래와 같은 건 안해줌 */
grant select on hr.employees to scott;

/* 
   이런 것이 간접 엑세스 직접 select 권한은 주지않고 보여줄 내용만 프로그램으로 호출할 수
   있게 권한을 부여해주는게 현장 및 실생활에서 이루어지는 일임 
   ex) 은행창구 직원 
   
   view는 select 알아야 하니까 일반유저에게 이렇게만 지원
*/

/* CREATE PROCEDURE 찾기 */
select * from user_sys_privs;
select * from role_sys_privs;

/* WITH ADMIN_OPTION : DBA에게 권한을 부여받은 USER가 해당 권한을 다른 USER에게 부여가능여부 */

--------------------------------------------------------------------------------

/* DBA */

/* 모든 걸 볼수 있는 권한 */
grant select any table to hr with admin option;

--------------------------------------------------------------------------------

/* HR */
grant select any table to scott;

--------------------------------------------------------------------------------

/* CREATE PROCEDURE : 프로시저, 함수, 패키지 만들수 있는 권한 (없으면 익명블럭만 생성 가능)*/

/* 함수 function 생성 */

create or replace function get_sal
(p_id in employees.employee_id%type) --> 사이즈는 의미 없다
return number --> return절 꼭써야 함  / 타입 설정 필요(사이즈 설정 안됨)
is
   v_sal number := 0;
begin
   select salary into v_sal from employees where employee_id = p_id;
   return v_sal; --> 함수 return문은 값 전달(무조건 필요) / 조건제어문을 통해서만 여러개 리턴가능(원래 하나만)
exception
   when no_data_found then
      return v_sal; 
end;
/

/* 함수의 호출방식 */

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

[문제38] 급여에 3.3%를 계산하는 tax 함수를 생성하세요.

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

/* 선생님 풀이 */
create or replace function tax
(f_sal employees.salary%type)
return number
is 
begin
    return (f_sal * 0.033);
end;
/


[문제39] 급여를 계산하는 get_annual_comp 함수를 생성하세요.

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

/* 풀이 1 */
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

/* 풀이 2 */
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

