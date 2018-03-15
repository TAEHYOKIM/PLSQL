[문제53]
사원번호를 입력값으로 받아서 급여를 10% 인상하는 update_proc 프로시저를 생성하세요.
green 계정을 생성한 후 시스템 권한 CREATE SESSION 부여하시고(dba) update_proc 프로시저 execute 권한을 부여(hr) 합니다.
사원테이블에 급여를 수정한 후 commit 발생하면 급여를 수정하는 사용자계정, 날짜, 사원번호, 이전 급여, 새로운 급여가 
감사테이블(audit_emp_sal) 저장을 할 수 있는 트리거(sal_audit)를 생성하세요.
(단 급여가 이전급여하고 새롭게 변경된 급여가 틀릴경우에만 감사테이블에 감사정보가 저장되도록하세요)

<green 유저 생성>

SQL> conn / as sysdba

SQL> CREATE USER green
     IDENTIFIED BY oracle
     DEFAULT TABLESPACE users
     TEMPORARY TABLESPACE temp
     QUOTA UNLIMITED ON users
     ACCOUNT UNLOCK;

<감사테이블 생성>

SQL> conn hr/hr
Connected.


SQL> create table audit_emp_sal(name varchar2(30), day timestamp,id number, old_sal number, new_sal number);

Table created.

< sal_audit trigger생성>


< update_proc 생성>


< update_proc execute 권한 green유저에 부여>



<green 에서 작업>

SQL> conn green/oracle
Connected.

SQL> select * from user_tab_privs;

GRANTEE    OWNER      TABLE_NAME           GRANTOR    PRIVILEGE  GRANTA
---------- ---------- -------------------- ---------- ---------- ------
GREEN      HR         UPDATE_PROC          HR         EXECUTE    NO


SQL> execute hr.update_proc(100)

PL/SQL procedure successfully completed.

SQL> rollback;

Rollback complete.

SQL> execute hr.update_proc(200)

PL/SQL procedure successfully completed.

SQL> commit;

Commit complete.


< 감사테이블 조회>

SQL> conn hr/hr
Connected.

SQL> select * from audit_emp_sal;
/*
NAME       DAY                                    ID    OLD_SAL    NEW_SAL
---------- ------------------------------ ---------- ---------- ----------
GREEN      17/05/16 11:47:25.560000              200       4840       5324
*/
--------------------------------------------------------------------------------

-- DBA SESSION --

/* USER ID : green, PW : oracle 계정생성 */
CREATE USER green 
IDENTIFIED BY oracle 
DEFAULT TABLESPACE users 
TEMPORARY TABLESPACE temp 
quota unlimited ON users 
account unlock;

grant create session to green;


-- HR SESSION --

/* AUDIT_EMP_SAL : 감사테이블 생성 */
CREATE TABLE audit_emp_sal
  (
    name VARCHAR2(30),
    DAY TIMESTAMP,
    id      NUMBER,
    old_sal NUMBER,
    new_sal NUMBER
  );

/* SAL_AUDIT TRIGGER 생성 */
create or replace trigger sal_audit
 after update of salary on employees
 for each row
 begin
   insert into audit_emp_sal(name, day, id, old_sal, new_sal)
   values(user, systimestamp, :old.employee_id, :old.salary, :new.salary);
 end;
 /

show error

/* update_proc 생성 
: 사원번호를 입력값으로 받아서 급여를 10% 인상 */
create or replace procedure update_proc(p_id number)
is
begin
  update employees
  set salary = salary * 1.1
  where employee_id = p_id;
  
  if sql%found then
    dbms_output.put_line(p_id||'번 사원 급여 10% 인상완료');
  else 
    raise no_data_found;
  end if;
exception
  when no_data_found then
    dbms_output.put_line(p_id||'번 사원은 존재하지 않음');
end;
/
show error

/* update_proc execute 권한 green유저에 부여 */
grant execute on update_proc to green;

/* < 감사테이블 조회> */
select * from audit_emp_sal;
truncate table audit_emp_sal;

--------------------------------------------------------------------------------
/* 선생님 풀이 */
SQL> conn / as sysdba

SQL> CREATE USER green
     IDENTIFIED BY oracle
     DEFAULT TABLESPACE users
     TEMPORARY TABLESPACE temp
     QUOTA UNLIMITED ON users
     ACCOUNT UNLOCK;

User created.

SQL> grant create session to green;



SQL> conn hr/hr
Connected.


SQL> create table audit_emp_sal(name varchar2(30), day timestamp,id number, old_sal number, new_sal number);

Table created.


SQL> CREATE OR REPLACE PROCEDURE update_proc(p_id IN number)
IS
BEGIN
	UPDATE employees
	SET salary = salary * 1.1
	WHERE employee_id = p_id;
END update_proc;
/


SQL> grant execute on update_proc to green;

SQL> select * from user_tab_privs;





SQL>  CREATE OR REPLACE TRIGGER sal_audit
          AFTER UPDATE OF salary ON employees
          FOR EACH ROW
          WHEN (old.salary != new.salary)
      BEGIN
  
          INSERT INTO audit_emp_sal(name, day, id, old_sal, new_sal) 
          VALUES(user,systimestamp, :new.employee_id, :old.salary, :new.salary);
  
      END sal_audit;
      /



SQL> CREATE OR REPLACE TRIGGER sal_audit
         AFTER UPDATE OF salary ON employees
         FOR EACH ROW
     BEGIN
         IF :old.salary != :new.salary THEN
            INSERT INTO audit_emp_sal(name, day, id, old_sal, new_sal) 
            VALUES(user,systimestamp, :new.employee_id, :old.salary, :new.salary);
         END IF;
     END sal_audit;
     /


SQL> conn green/oracle
Connected.

SQL> select * from user_tab_privs;

GRANTEE    OWNER      TABLE_NAME           GRANTOR    PRIVILEGE  GRANTA
---------- ---------- -------------------- ---------- ---------- ------
GREEN      HR         UPDATE_PROC          HR         EXECUTE    NO


SQL> execute hr.update_proc(100)

PL/SQL procedure successfully completed.

SQL> rollback;

Rollback complete.

SQL> execute hr.update_proc(200)

PL/SQL procedure successfully completed.

SQL> commit;

Commit complete.

SQL> conn hr/hr
Connected.

SQL> select * from audit_emp_sal;

NAME       DAY                                    ID    OLD_SAL    NEW_SAL
---------- ------------------------------ ---------- ---------- ----------
GREEN      17/05/16 11:47:25.560000              200       4840       5324

SQL> select text from user_source where name = 'UPDATE_PROC' order by line;


SQL> select * from user_triggers where trigger_name = 'SAL_AUDIT';


SQL> drop trigger sal_audit;

Trigger dropped.

SQL> drop procedure update_proc;

Procedure dropped.

================================================================================
/* trigger 만들어야할 이유 중 하나 : 복제 */
[문제54] 복제 테이블을 생성한후 emp_source 테이블에 DML이 발생하면 emp_target값도 함께 수행되도록 해주세요.

drop table emp_target purge;
drop table emp_source purge;

/* 복제 테이블 */
create table emp_target
(id number, name varchar2(10), day timestamp default systimestamp, sal number);

create table emp_source
(id number, name varchar2(10), day timestamp default systimestamp, sal number);






SQL> insert into emp_source(id,name,day,sal) values(100,'ora1',default,1000);

1 row created.

SQL> commit;

Commit complete.

SQL>  select * from emp_source;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 ora1                 15/07/23 17:15:21.799000                                 1000

SQL> select * from emp_target;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 ora1                 15/07/23 17:15:21.799000                                 1000

SQL> update emp_source
  2  set sal = 2000
  3  where id = 100;

1 row updated.

SQL> select * from emp_source;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 ora1                 15/07/23 17:15:21.799000                                 2000

SQL> select * from emp_target;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 ora1                 15/07/23 17:15:21.799000                                 2000

SQL> update emp_source
  2  set name = 'oracle'
  3  where id = 100;

1 row updated.

SQL> select * from emp_source;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 oracle               15/07/23 17:15:21.799000                                 2000

SQL> select * from emp_target;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 oracle               15/07/23 17:15:21.799000                                 2000

SQL> insert into emp_source(id,name,day,sal) values(2,user,default,3000);

1 row created.

SQL> select * from emp_source;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 oracle               15/07/23 17:15:21.799000                                 2000
         2 HR                   15/07/23 17:18:20.248000                                 3000

SQL> select * from emp_target;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 oracle               15/07/23 17:15:21.799000                                 2000
         2 HR                   15/07/23 17:18:20.248000                                 3000

SQL> delete from emp_source where id = 2;

1 row deleted.

SQL> select * from emp_source;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 oracle               15/07/23 17:15:21.799000                                 2000

SQL> select * from emp_target;

        ID NAME                 DAY                                                       SAL
---------- -------------------- -------------------------------------------------- ----------
       100 oracle               15/07/23 17:15:21.799000                                 2000


SQL> rollback;

-- emp_target : emp_source 복제 테이블 --

create or replace trigger emp_cv
 after insert or delete or update on emp_source
 for each row

begin
 if inserting then
   insert into emp_target(id, name, day, sal)
   values(:new.id, :new.name, :new.day, :new.sal);
 
 elsif deleting then
   delete from emp_target
   where id = :old.id;
 
 elsif updating('name') then
   update emp_target
   set name = :new.name
   where id = :old.id;
 
 elsif updating('sal') then
   update emp_target
   set sal = :new.sal
   where id = :old.id;
 end if;
 
end;
/
/* ※ set sal = :new.sal, name = :new.name(동시 수정작업) 
     도 가능 하지만 undo에 불필요한 엑세스가 발생 */
show error

/* test */
insert into emp_source(id,name,day,sal)
values(100,'ora1',default,1000);

select * from emp_source;
select * from emp_target;

insert into emp_source(id,name,day,sal)
values(2,user,default,2000);

select * from emp_source;
select * from emp_target;

delete from emp_source
where id = 2;

select * from emp_source;
select * from emp_target;

update emp_source
set name = 'hong'
where id = 100;

select * from emp_source;
select * from emp_target;

update emp_source
set sal = 2000
where id = 100;

select * from emp_source;
select * from emp_target;

rollback;

================================================================================

[문제55]사원들의 급여를 수정할 때 그 사원의 job_id 별 최저 임금에서 최고 임금 사이에 
급여값으로만 입력, 수정하도록 하는 프로그램을 작성하세요. 트리거를 이용하셔야 합니다.



SQL> select * from jobs;

JOB_ID               JOB_TITLE                                          MIN_SALARY MAX_SALARY
-------------------- -------------------------------------------------- ---------- ----------
AD_PRES              President                                               20080      40000
AD_VP                Administration Vice President                           15000      30000
AD_ASST              Administration Assistant                                 3000       6000
FI_MGR               Finance Manager                                          8200      16000
FI_ACCOUNT           Accountant                                               4200       9000
AC_MGR               Accounting Manager                                       8200      16000
AC_ACCOUNT           Public Accountant                                        4200       9000
SA_MAN               Sales Manager                                           10000      20080
SA_REP               Sales Representative                                     6000      12008
PU_MAN               Purchasing Manager                                       8000      15000
PU_CLERK             Purchasing Clerk                                         2500       5500
ST_MAN               Stock Manager                                            5500       8500
ST_CLERK             Stock Clerk                                              2008       5000
SH_CLERK             Shipping Clerk                                           2500       5500
IT_PROG              Programmer                                               4000      10000
MK_MAN               Marketing Manager                                        9000      15000
MK_REP               Marketing Representative                                 4000       9000
HR_REP               Human Resources Representative                           4000       9000
PR_REP               Public Relations Representative                          4500      10500

19 rows selected.



SQL> select job_id, salary from employees where employee_id = 115;

JOB_ID                   SALARY
-------------------- ----------
PU_CLERK                   3100


SQL> update employees
  2  set salary = 3000
  3  where employee_id = 115;

1 row updated.

SQL> rollback;

Rollback complete.

SQL> update employees
  2  set salary = 6000
  3  where employee_id = 115;
update employees
       *
ERROR at line 1:
ORA-20100: Invalid salary $6000. Salaries for job PU_CLERK must be between $2500 and $5500
ORA-06512: at "HR.CHECK_SALARY", line 10
ORA-06512: at "HR.CHECK_SALARY_TRG", line 2
ORA-04088: error during execution of trigger 'HR.CHECK_SALARY_TRG'



SQL> insert into employees(employee_id, last_name, email, hire_date, job_id, salary)
  2  values(300, 'happy','happy',sysdate,'PU_CLERK',5000);

1 row created.

SQL> rollback;

Rollback complete.

SQL> insert into employees(employee_id, last_name, email, hire_date, job_id, salary)
  2  values(300, 'happy','happy',sysdate,'PU_CLERK',6000);
insert into employees(employee_id, last_name, email, hire_date, job_id, salary)
            *
ERROR at line 1:
ORA-20100: Invalid salary $6000. Salaries for job PU_CLERK must be between $2500 and $5500
ORA-06512: at "HR.CHECK_SALARY", line 10
ORA-06512: at "HR.CHECK_SALARY_TRG", line 2
ORA-04088: error during execution of trigger 'HR.CHECK_SALARY_TRG'


-- insert, update trigger 작동 - job_id 가져옴 - 비교작업(범주) -
-- check : job_id별 급여범위 내 수정
-- raise_application_error(-20100,) 사용

create or replace trigger CHECK_SALARY_TRG
 after insert or update of job_id, salary on employees
 for each row
declare
      type rec_type is record(min_sal number, max_sal number);
      v_rec rec_type;
begin
      select min_salary, max_salary
      into v_rec
      from jobs
      where job_id = upper(:new.job_id);

    if :new.salary < v_rec.min_sal or :new.salary > v_rec.max_sal then
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||:new.salary ||'. '
      || 'Salaries for job '|| :new.job_id ||' must be between $'
      || v_rec.min_sal ||' and $' || v_rec.max_sal);      
    else
      dbms_output.put_line('성공');
    end if;
end CHECK_SALARY_TRG;
/
show error
rollback;

insert into employees(employee_id, last_name, email, hire_date, job_id, salary)
values(300, 'happy','happy',sysdate,'PU_CLERK',5000);

select job_id, salary from employees where employee_id = 115;
update employees
set salary = 3000
where employee_id = 115;


--------------------------------------------------------------------------------
/* 선생님 풀이 #1 */

CREATE OR REPLACE PROCEDURE check_salary  
(p_the_job VARCHAR2, p_the_salary NUMBER) 
IS
  v_minsal jobs.min_salary%type;
  v_maxsal jobs.max_salary%type;
BEGIN
  SELECT min_salary, max_salary INTO v_minsal, v_maxsal
  FROM jobs
  WHERE job_id = UPPER(p_the_job);

  IF p_the_salary NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_the_salary ||'. '
      || 'Salaries for job '|| p_the_job ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  END IF;
END;
/



CREATE OR REPLACE TRIGGER check_salary_trg
AFTER INSERT OR UPDATE OF job_id, salary
ON employees
FOR EACH ROW
BEGIN
  check_salary(:new.job_id, :new.salary);
END;
/


CREATE OR REPLACE TRIGGER check_salary_trg
AFTER INSERT OR UPDATE OF job_id, salary
ON employees
FOR EACH ROW
  CALL  check_salary(:new.job_id, :new.salary)  --> CALL : trigger 전용(procedure만 호출)
/


/* 선생님 풀이 #2 : trigger */
CREATE OR REPLACE TRIGGER check_salary_trg
AFTER INSERT OR UPDATE OF job_id, salary ON employees
FOR EACH ROW
DECLARE
  v_minsal jobs.min_salary%type;
  v_maxsal jobs.max_salary%type;
BEGIN
  SELECT min_salary, max_salary INTO v_minsal, v_maxsal
  FROM jobs
  WHERE job_id = UPPER(:NEW.job_id); 
   --> 수식자 :NEW.job_id : insert, update 겸용사용 / 수정할 사원의 job_id 조회 select 줄임 

  IF :NEW.salary NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||:NEW.salary ||'. '
      || 'Salaries for job '|| :NEW.job_id ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  END IF;
END;
/

/* trigger source크기 제약 입음 32kbyte 이내 */

--------------------------------------------------------------------------------
[문제 56]
/* 사원번호, 급여정보 입력 급여 변경 job_id 기준 procedure 로 해결 sql 3개 */

select job_id, salary from employees;
select * from jobs;

create or replace procedure check_salary_pro(p_id number, new_sal number)
is
   v_rec jobs%rowtype;
begin
   select j.job_id, j.min_salary, j.max_salary 
   into v_rec.job_id, v_rec.min_salary, v_rec.max_salary
   from employees e, jobs j
   where e.job_id = j.job_id
   and e.employee_id = p_id;
   
   if new_sal not between v_rec.min_salary and v_rec.max_salary then
       raise_application_error(-20100,'Invalid salary $'||
       new_sal||'. Salaries for job '||v_rec.job_id||' must be between $'||
       v_rec.min_salary||' and $'||v_rec.max_salary);
   else
       update employees
       set salary = new_sal
       where employee_id = p_id;
   end if;
end;
/

show error

exec check_salary_pro(178, 1000000)
--------------------------------------------------------------------------------
/* 선생님 풀이 #1*/
create or replace procedure emp_sal_proc(p_id number, p_sal number)
is
	v_job varchar2(30);
	v_minsal number;
	v_maxsal number;
begin
 
	select job_id into v_job from employees where employee_id = p_id;
	
	select min_salary, max_salary into v_minsal, v_maxsal
	from jobs
	where job_id = v_job;

  IF p_sal NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_sal ||'. '
      || 'Salaries for job '|| v_job ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  ELSE
    update employees
    set salary = p_sal
    where employee_id = p_id;
  END IF;
END;
/


/* 선생님 풀이 #2 : join */
create or replace procedure emp_sal_proc(p_id number, p_sal number)
is
	v_job varchar2(30);
	v_minsal number;
	v_maxsal number;
begin
 
	select e.job_id,j.min_salary, j.max_salary
	into v_job, v_minsal, v_maxsal
	from jobs j , employees e
	where e.job_id = j.job_id
	and e.employee_id = p_id;

  IF p_sal NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_sal ||'. '
      || 'Salaries for job '|| v_job ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  ELSE
    update employees
    set salary = p_sal
    where employee_id = p_id;
  END IF;
END;
/


SQL> exec emp_sal_proc(115,5000)

PL/SQL procedure successfully completed.

SQL> rollback;

Rollback complete.

SQL> exec emp_sal_proc(115,7000)
BEGIN emp_sal_proc(115,7000); END;

*
ERROR at line 1:
ORA-20100: Invalid salary $7000. Salaries for job PU_CLERK must be between $2500 and $5500
ORA-06512: at "HR.EMP_SAL_PROC", line 15
ORA-06512: at line 1


SQL> exec emp_sal_proc(200,100)
BEGIN emp_sal_proc(200,100); END;

*
ERROR at line 1:
ORA-20100: Invalid salary $100. Salaries for job AD_ASST must be between $3000 and $6000
ORA-06512: at "HR.EMP_SAL_PROC", line 15
ORA-06512: at line 1

================================================================================
/* NOTE : index 설계 여부 확인하는 작업이 필요하지 않을까? */
================================================================================

/* Trigger_enable_disable 
   : trigger 생성시 활성화 여부 설정가능 11g~(기본값 enable), 오류시 disable로 변경후 작업 */

SQL> conn hr/hr
Connected.

SQL> CREATE TABLE trigger_control_test (id NUMBER, description VARCHAR2(50));

Table created.

SQL> set serveroutput on

SQL> CREATE OR REPLACE TRIGGER trigger_control_test_trg
         BEFORE INSERT ON trigger_control_test
         FOR EACH ROW
         ENABLE --> 안써도 됨
     BEGIN
         DBMS_OUTPUT.PUT_LINE('TRIGGER_CONTROL_TEST_TRG - Executed');
     END;
     /

/* DML문 실행시 나오는 메세지 다 trigger */

Trigger created.

SQL> select status from user_triggers where trigger_name = 'TRIGGER_CONTROL_TEST_TRG';

STATUS
----------------
ENABLED

SQL> INSERT INTO trigger_control_test VALUES (1, 'ONE');
TRIGGER_CONTROL_TEST_TRG - Executed

1 row created.

SQL> rollback;

Rollback complete.

select * from trigger_control_test;

/* ENABLE시 ERROR 상황 */
SQL> CREATE OR REPLACE TRIGGER trigger_control_test_trg
         BEFORE INSERT ON trigger_control_test
         FOR EACH ROW
         ENABLE
     BEGIN
         DBMS_OUTPUT.PUT_LINE('TRIGGER_CONTROL_TEST_TRG - Executed')
     END;
     /

Warning: Trigger created with compilation errors.


SQL> show error
Errors for TRIGGER TRIGGER_CONTROL_TEST_TRG:

LINE/COL ERROR
-------- -----------------------------------------------------------------
3/1      PLS-00103: Encountered the symbol "END" when expecting one of
         the following:
         := . ( % ;
         The symbol ";" was substituted for "END" to continue.


SQL> select status from user_triggers where trigger_name = 'TRIGGER_CONTROL_TEST_TRG';

STATUS
----------------
ENABLED


SQL> INSERT INTO trigger_control_test VALUES (1, 'ONE');
INSERT INTO trigger_control_test VALUES (1, 'ONE')
            *
ERROR at line 1:
ORA-04098: trigger 'HR.TRIGGER_CONTROL_TEST_TRG' is invalid and failed re-validation
/* NOTE : trigger enable일때 compile error면 DML 실행에도 영향을 줌 */

/* 위 해결법 : DISABLE으로 재설정 */
SQL> CREATE OR REPLACE TRIGGER trigger_control_test_trg
        BEFORE INSERT ON trigger_control_test
        FOR EACH ROW
        DISABLE  --> compile 실패를 대비한 비활성화 
     BEGIN
        DBMS_OUTPUT.PUT_LINE('TRIGGER_CONTROL_TEST_TRG - Executed')
     END;
     /

Warning: Trigger created with compilation errors.

SQL> show error
Errors for TRIGGER TRIGGER_CONTROL_TEST_TRG:

LINE/COL ERROR
-------- -----------------------------------------------------------------
3/1      PLS-00103: Encountered the symbol "END" when expecting one of
         the following:
         := . ( % ;
         The symbol ";" was substituted for "END" to continue.

SQL> select status from user_triggers where trigger_name = 'TRIGGER_CONTROL_TEST_TRG';


STATUS
----------------
DISABLED


SQL> INSERT INTO trigger_control_test VALUES (2, 'TWO');

1 row created.

SQL> select * from trigger_control_test;

        ID 	  DESCRIPTION
------------  --------------------
         2	  TWO
        
SQL> rollback;

Rollback complete.
/* NOTE : trigger disable 상태에서 error여도 DML 수행가능 */

/* ERROR수정후 ENABLE로 실행 */
SQL> CREATE OR REPLACE TRIGGER trigger_control_test_trg
    BEFORE INSERT ON trigger_control_test
    FOR EACH ROW
    ENABLE
    BEGIN
      DBMS_OUTPUT.PUT_LINE('TRIGGER_CONTROL_TEST_TRG - Executed');
    END;
    /

Trigger created.

SQL> INSERT INTO trigger_control_test VALUES (3, 'THREE');
TRIGGER_CONTROL_TEST_TRG - Executed

1 row created.

SQL> select * from trigger_control_test;

        ID DESCRIPTIO
---------- ----------
         3  THREE

SQL> rollback;

Rollback complete.


SQL> select status from user_triggers where trigger_name = 'TRIGGER_CONTROL_TEST_TRG';


STATUS
----------------
ENABLED

SQL> ALTER TRIGGER trigger_control_test_trg DISABLE; --> 생성이후 활성화 여부 수정 가능

Trigger altered.

SQL> select status from user_triggers where trigger_name = 'TRIGGER_CONTROL_TEST_TRG';


STATUS
----------------
DISABLED

SQL> INSERT INTO trigger_control_test VALUES (1, 'ONE');

1 row created.

SQL> rollback;

Rollback complete.

SQL> ALTER TRIGGER trigger_control_test_trg ENABLE;

Trigger altered.

SQL> select status from user_triggers where trigger_name = 'TRIGGER_CONTROL_TEST_TRG';


STATUS
----------------
ENABLED

SQL> INSERT INTO trigger_control_test VALUES (1, 'ONE');
TRIGGER_CONTROL_TEST_TRG - Executed

1 row created.

SQL> rollback;

Rollback complete.

SQL> DROP TRIGGER trigger_control_test_trg;

Trigger dropped.

SQL>


================================================================================

drop table emp_20 purge;
create or replace view emp_20
as select * from employees where department_id = 20;

select * from emp_20;

select * from user_objects where object_name in ('EMPLOYEES', 'EMP_20');
/* 
- data_object_id : table, index만 가지고 있음(view는 없음) 
- created : 만들어진 날
- status : 
- timestamp : 마지막 recompile한 날
*/

alter table employees modify last_name varchar2(60);
select * from user_objects where object_name in ('EMPLOYEES', 'EMP_20');
/*
- 참조하는 테이블 변동하면 view는 status : invalid로 변경. 실행불가능(종속관계 특징)
- select 호출순간 invalid면 오라클 자동 컴파일됨
- valid된 object만 사용가능
*/
select * from emp_20;
select * from user_objects where object_name in ('EMPLOYEES', 'EMP_20');


================================================================================

/* 종속성 관계 */

/* 
 - 참조를 하는  object : validate_comm
 - 참조를 당하는 object : employees
*/
SQL> CREATE OR REPLACE FUNCTION  validate_comm (v_c IN NUMBER)
          RETURN BOOLEAN
        IS
                v_max_comm    NUMBER;
        BEGIN
                SELECT   max(commission_pct)  INTO  v_max_comm FROM employees;
    
                IF   v_c > v_max_comm 
                THEN   RETURN(FALSE);
                ELSE   RETURN(TRUE);
                END IF;
END validate_comm;
/
      
Function created.


/* 
 - 참조를 하는  object : reset_comm
 - 참조를 당하는 object : validate_comm
*/
SQL> CREATE OR REPLACE PROCEDURE  reset_comm (v_comm   IN  NUMBER)
        IS
    		g_comm      NUMBER := 0.1;
        BEGIN
                IF  validate_comm(v_comm) 
                THEN
                        dbms_output.put_line('OLD: '||g_comm);
                        g_comm:=v_comm;
                        dbms_output.put_line('NEW: '||g_comm);
                ELSE
                        RAISE_APPLICATION_ERROR (-20210,'Invalid commission');
                END IF;
END reset_comm;
/   

Procedure created.

/* 영향도 평가 : 변경되면 종속된 넘들이 누구인지 찾아보자 */

SQL> execute reset_comm(0.2)
OLD: .1
NEW: .2

PL/SQL procedure successfully completed.

SQL> SELECT object_name, object_type, status
FROM USER_OBJECTS 
WHERE OBJECT_NAME IN ('EMPLOYEES','RESET_COMM','VALIDATE_COMM');   

OBJECT_NAME                    OBJECT_TYPE         STATUS
------------------------------ ------------------- -------
EMPLOYEES                      TABLE               VALID
RESET_COMM                     PROCEDURE           VALID
VALIDATE_COMM                  FUNCTION            VALID


/*  name, type -> referenced_name, referenced_type */
SQL> SELECT name, type, referenced_name, referenced_type
FROM USER_DEPENDENCIES
WHERE REFERENCED_NAME IN('EMPLOYEES','VALIDATE_COMM');

NAME                           TYPE               REFERENCED_NAME                REFERENCED_TYPE
------------------------------ ------------------ ------------------------------ ------------------
CHECK_SALARY                   TRIGGER            EMPLOYEES                      TABLE
COMM_PACKAGE                   PACKAGE BODY       EMPLOYEES                      TABLE
EMP_DETAILS_VIEW               VIEW               EMPLOYEES                      TABLE
EMP_TEXT                       PROCEDURE          EMPLOYEES                      TABLE
PACK_CUR                       PACKAGE BODY       EMPLOYEES                      TABLE
RESET_COMM                     PROCEDURE          VALIDATE_COMM                  FUNCTION ★
SECURE_EMPLOYEES               TRIGGER            EMPLOYEES                      TABLE
UPDATE_JOB_HISTORY             TRIGGER            EMPLOYEES                      TABLE
VALIDATE_COMM                  FUNCTION           EMPLOYEES                      TABLE    ★


/* commission_pct 상태변경(타입) */
SQL> alter table hr.employees modify (commission_pct number(10,3));

Table altered.

SQL>  SELECT object_name, object_type, status
FROM USER_OBJECTS 
WHERE OBJECT_NAME IN ('EMPLOYEES','RESET_COMM','VALIDATE_COMM'); 

OBJECT_NAME                    OBJECT_TYPE         STATUS
------------------------------ ------------------- -------
EMPLOYEES                      TABLE               VALID
RESET_COMM                     PROCEDURE           INVALID
VALIDATE_COMM                  FUNCTION            INVALID



SQL> ALTER FUNCTION VALIDATE_COMM COMPILE;

Function altered.

SQL> ALTER PROCEDURE RESET_COMM COMPILE;

Procedure altered.

SQL> SELECT object_name, object_type, status
FROM USER_OBJECTS 
WHERE OBJECT_NAME IN ('EMPLOYEES','RESET_COMM','VALIDATE_COMM');  

OBJECT_NAME                    OBJECT_TYPE         STATUS
------------------------------ ------------------- -------
VALIDATE_COMM                  FUNCTION            VALID
RESET_COMM                     PROCEDURE           VALID
EMPLOYEES                      TABLE               VALID

SQL> execute reset_comm(0.2)
OLD: .1
NEW: .2

PL/SQL procedure successfully completed.



SQL> @$ORACLE_HOME/rdbms/admin/utldtree.sql  -- @%ORACLE_HOME%\rdbms\admin\utldtree.sql (window)

SQL> execute deptree_fill('TABLE','HR','EMPLOYEES')


PL/SQL procedure successfully completed.


SQL> select * from deptree; --> 종속관계 데이터를 여기다 넣음


NESTED_LEVEL TYPE                SCHEMA                         NAME                                 SEQ#
------------ ------------------- ------------------------------ ------------------------------ ----------
           0 TABLE               HR                             EMPLOYEES                               0
           1 VIEW                HR                             EMP_DETAILS_VIEW                        1
           1 TRIGGER             HR                             SECURE_EMPLOYEES                        2
           1 TRIGGER             HR                             UPDATE_JOB_HISTORY                      3
           1 PACKAGE BODY        HR                             COMM_PACKAGE                            5
           1 PACKAGE BODY        HR                             PACK_CUR                                6
           1 TRIGGER             HR                             CHECK_SALARY                            7
           1 PROCEDURE           HR                             EMP_TEXT                                8
           1 FUNCTION            HR                             VALIDATE_COMM                           9
           2 PROCEDURE           HR                             RESET_COMM                             10

11 rows selected.

/* 참조순서도 : 0 ← 1 / 바로 위에 있는 1 ← 2 */

================================================================================

/* wrap : 오라클에서 소스 암호화하는 놈 */

create or replace procedure emp_sal_proc(p_id number, p_sal number)
is
	v_job varchar2(30);
	v_minsal number;
	v_maxsal number;
begin
 
	select e.job_id,j.min_salary, j.max_salary
	into v_job, v_minsal, v_maxsal
	from jobs j , employees e
	where e.job_id = j.job_id
	and e.employee_id = p_id;

  IF p_sal NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_sal ||'. '
      || 'Salaries for job '|| v_job ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  ELSE
    update employees
    set salary = p_sal
    where employee_id = p_id;
  END IF;
END;
/




SQL> SELECT text FROM user_source WHERE name = 'EMP_SAL_PROC';
/*
TEXT
--------------------------------------------------------------------------------
procedure emp_sal_proc(p_id number, p_sal number)
is
        v_job varchar2(30);
        v_minsal number;
        v_maxsal number;
begin

        select e.job_id,j.min_salary, j.max_salary
        into v_job, v_minsal, v_maxsal
        from jobs j , employees e
        where e.job_id = j.job_id
        and e.employee_id = p_id;

  IF p_sal NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_sal ||'. '
      || 'Salaries for job '|| v_job ||' must be between $'|| v_minsal ||' and $
' || v_maxsal);

  ELSE
    update employees
    set salary = p_sal
    where employee_id = p_id;
  END IF;
END;
*/

                            -- 소스코드 암호화 --

C:\data\emp_sal_proc.sql

create or replace procedure emp_sal_proc(p_id number, p_sal number)
is
	v_job varchar2(30);
	v_minsal number;
	v_maxsal number;
begin
 
	select e.job_id,j.min_salary, j.max_salary
	into v_job, v_minsal, v_maxsal
	from jobs j , employees e
	where e.job_id = j.job_id
	and e.employee_id = p_id;

  IF p_sal NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_sal ||'. '
      || 'Salaries for job '|| v_job ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  ELSE
    update employees
    set salary = p_sal
    where employee_id = p_id;
  END IF;
END;
/

C:\Users\user>cd c:\data

/* wrap : oracle 제공 암호화 유틸리티 */
c:\data>wrap iname=emp_sal_proc.sql oname=emp_sal_proc.plb

PL/SQL Wrapper: Release 11.2.0.2.0- 64bit Production on 금 12월 22 16:47:26 2017

Copyright (c) 1993, 2009, Oracle.  All rights reserved.

Processing emp_sal_proc.sql to emp_sal_proc.plb

c:\data>dir emp_sal_proc.*
 C 드라이브의 볼륨에는 이름이 없습니다.
 볼륨 일련 번호: E4E0-38C0

 c:\data 디렉터리

2017-12-22  오후 04:47               686 emp_sal_proc.plb
2017-12-22  오후 04:42               633 emp_sal_proc.sql
               2개 파일               1,319 바이트
               0개 디렉터리  271,429,922,816 바이트 남음


c:\data>sqlplus hr/hr

SQL*Plus: Release 11.2.0.2.0 Production on 금 12월 22 16:47:58 2017

Copyright (c) 1982, 2014, Oracle.  All rights reserved.


Connected to:
Oracle Database 11g Express Edition Release 11.2.0.2.0 - 64bit Production

SQL> @c:\data\emp_sal_proc.plb

Procedure created.

SQL> SELECT text FROM user_source WHERE name = 'EMP_SAL_PROC';

TEXT
-------------------------------------------------------------------------------
procedure emp_sal_proc wrapped
a000000
34e
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
7
24e 1fa
Vy+lSOKINGDaps5ZsTsE6P1YsAYwg3nM2UgVfC+KKvkYrcOeWj7yBQt31qgMf56hkROxPqzx
8sM0NqBcY8/PeCgOB6P3ipCkcjBJJtwjjkoqqJocwuvgt6RK+MQr7CYvCDB3bM2o119f7OVi
ifP/FP0bTFkaubIaPycA+M0ONoDFvH/2ov/5ZkwjXC2puHTpdwMOyx5LjXiKpVUlYPy+W+Jd
2CZGjOATDsDSuAhN3I1huJJ7iDeYOYQwDsyrbMdmHdP/9Wd6MZVElthxLALvhsj9H59VYrDL
RqbDtWX14LNs2mwYZBkWZIeAAx0G9OVjY2WJ+iHww66jjduI3pB9PGq3tX34HHEN+KN+PNW4
R22GKLlMjunNXo5IW0iMXo64LqGTwUk0u9DOtJbuZaPG/3F+JK4XVsf5/5pCvAsm5VV6S5FW
nwqDj5LD+YCm6UDFE1Kr8gzEU8VQyOmkEo1giCC9eH/5t5SZwATlLOcZ1pgP3zVueA==



SQL> set serveroutput on

SQL> desc emp_sal_proc
PROCEDURE emp_sal_proc
 Argument Name                  Type                    In/Out Default?
 ------------------------------ ----------------------- ------ --------
 P_ID                           NUMBER                  IN
 P_SAL                          NUMBER                  IN


SQL> exec emp_sal_proc(115,5000)

PL/SQL procedure successfully completed.

SQL> exec emp_sal_proc(115,7000)
BEGIN emp_sal_proc(115,7000); END;

*
ERROR at line 1:
ORA-20100: Invalid salary $7000. Salaries for job PU_CLERK must be between
$2500 and $5500
ORA-06512: at "HR.EMP_SAL_PROC", line 15
ORA-06512: at line 1


SQL>

/* 복호화는 https://www.codecrete.net/UnwrapIt/ */