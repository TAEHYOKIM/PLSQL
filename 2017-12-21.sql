[문제50] 사원들의 급여를 10% 인상하는 프로그램을 생성해주세요.

declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,250,180,190,200,300);
begin 
    emp_pkg.update_sal(v_num);
    rollback;
end;
/

사원번호 : 100        사원이름 : King       수정 급여 : 29040
사원번호 : 103        사원이름 : Hunold     수정 급여 : 9900
사원번호 : 107        사원이름 : Lorentz    수정 급여 : 4620
사원번호 : 110        사원이름 : Chen       수정 급여 : 9020
사원번호 : 112        사원이름 : Urman      수정 급여 : 8580
사원번호 : 115        사원이름 : Khoo       수정 급여 : 3410
사원번호 : 160        사원이름 : Doran      수정 급여 : 8250
사원번호 : 170        사원이름 : Fox        수정 급여 : 10560
사원번호 : 180        사원이름 : Taylor     수정 급여 : 3520
사원번호 : 190        사원이름 : Gates      수정 급여 : 3190
사원번호 : 200        사원이름 : Whalen     수정 급여 : 0
250 처리되지 않는 값입니다.
300 처리되지 않는 값입니다.

-- 문자열 비교? 없는 사원 예외사항 처리해야 됨

/* spec 선언 */
create or replace package emp_pkg
is 
  type numlist is table of number;
  procedure update_sal(v_num numlist);
end emp_pkg;
/
/* body 선언 */
create or replace package body emp_pkg
is
  procedure update_sal(v_num numlist)
  is
    type rec_type is record(e_id number, l_nm varchar2(30), sal number);
    type tab_type is table of rec_type;
    v_tab tab_type;
  begin
    forall i in v_num.first..v_num.last
      update employees
      set salary = salary * 1.1
      where employee_id = v_num(i)
      returning employee_id, last_name, salary bulk collect into v_tab;
    /*
    for i in v_tab.first..v_tab.last loop
      dbms_output.put_line('사원번호 : '||rpad(v_tab(i).e_id,10)||
                           '사원이름 : '||rpad(v_tab(i).l_nm,10)||
                           '수정 급여 : '||rpad(v_tab(i).sal,10));
    end loop;
    */
    for i in v_num.first..v_num.last loop
      for j in v_tab.first..v_tab.last loop
        if v_num(i)=v_tab(j).e_id then
      dbms_output.put_line('사원번호 : '||rpad(v_tab(j).e_id,10)||
                           '사원이름 : '||rpad(v_tab(j).l_nm,10)||
                           '수정 급여 : '||rpad(v_tab(j).sal,10));
           exit;
        elsif j = v_tab.last then
          dbms_output.put_line(v_num(i)||' 처리되지 않는 값입니다.');
        end if;
      end loop;
    end loop;
    
  end;
end emp_pkg;
/

show error

declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,250,180,190,200,300);
begin 
    emp_pkg.update_sal(v_num);
    rollback;
end;
/

select employee_id, last_name, salary 
from employees 
where employee_id in (100,103,107,110,112,115,160,170,250,180,190,200,300);


select employee_id from employees;

================================================================================

/*
- plsql 함수 사용 제약. 
프로시저문에서 사용할 수 있는 함수. 변수할당연산자 오른쪽에 함수 쓸 수 있음. 이게 프로시저문.
decode함수, 그룹함수는 프로시저문에서 사용할 수 없음. 
*/

================================================================================
/* 배열타입 생각 */
create or replace package emp_pkg
is
  type numlist is table of number; 
  procedure update_sal(p_id numlist);
end emp_pkg;
/

create or replace package body emp_pkg
is
  procedure update_sal(p_id numlist)	
  is
	 type record_type is record(id number, name varchar2(50), sal number);
   type table_type is table of record_type;  
   v_tab table_type;
  begin  
  	for i in  p_id.first..p_id.last loop  
    	     update employees  
     	     set salary = salary * 1.1  
    	     where employee_id = p_id(i) 
           returning employee_id, last_name, salary into v_tab(i);  
  
	  if sql%notfound then
		  dbms_output.put_line(p_id(i) ||' 처리 되지 않았습니다.');
	  else
	    dbms_output.put_line('사원번호 : '|| rpad(v_tab(i).id,10,' ')||' 사원이름 : '
			 ||rpad(v_tab(i).name,10,' ')||' 수정 급여 : '||rpad(v_tab(i).sal,10,' '));
	  end if;

    end loop;
 end update_sal;
end emp_pkg;  
/
show error


SQL> declare
  2     v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,250,180,190,200,300);
  3  begin
  4      emp_pkg.update_sal(v_num);
  5      rollback;
  6  end;
  7  /
declare
*
ERROR at line 1:
ORA-06531: Reference to uninitialized collection
ORA-06512: at "HR.EMP_PKG", line 13
ORA-06512: at line 4


SQL>




===================================================================

create or replace package emp_pkg
is
  type numlist is table of number;
   
  procedure update_sal(p_id numlist);
  

end emp_pkg;
/

create or replace package body emp_pkg
is

  procedure update_sal(p_id numlist)	
  is
  
	 type record_type is record(id number, name varchar2(50), sal number);
	 v_tab record_type;
  begin  
  	for i in  p_id.first..p_id.last loop  
    	     update employees  
     	     set salary = salary * 1.1  
    	     where employee_id = p_id(i) 
             returning employee_id, last_name, salary into v_tab;  
  
	if sql%notfound then
		dbms_output.put_line(p_id(i) ||' 처리 되지 않았습니다.');
	else
	 dbms_output.put_line('사원번호 : '|| rpad(v_tab.id,10,' ')||' 사원이름 : '
			 ||rpad(v_tab.name,10,' ')||' 수정 급여 : '||rpad(v_tab.sal,10,' '));
	
	end if;

  end loop;


  end update_sal;
    
end emp_pkg;  
/
show error


declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,250,180,190,200,300);
begin 
    emp_pkg.update_sal(v_num);
    rollback;
end;
/




=============================================================





create or replace package emp_pkg
is
  type numlist is table of number;
   
  procedure update_sal(p_id numlist);
  

end emp_pkg;
/

create or replace package body emp_pkg
is

  procedure update_sal(p_id numlist)	
  is
  
	 type record_type is record(id number, name varchar2(50), sal number);
	
  	 type table_type is table of record_type index by pls_integer;  
  	 v_tab table_type;
  begin  
  	for i in  p_id.first..p_id.last loop  
    	     update employees  
     	     set salary = salary * 1.1  
    	     where employee_id = p_id(i) 
             returning employee_id, last_name, salary into v_tab(i);  
  
	if sql%notfound then
		dbms_output.put_line(p_id(i) ||' 처리 되지 않았습니다.');
	else
	 dbms_output.put_line('사원번호 : '|| rpad(v_tab(i).id,10,' ')||' 사원이름 : '
			 ||rpad(v_tab(i).name,10,' ')||' 수정 급여 : '||rpad(v_tab(i).sal,10,' '));
	
	end if;

  end loop;


  end update_sal;
    
end emp_pkg;  
/
show error


declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,250,180,190,200,300);
begin 
    emp_pkg.update_sal(v_num);
    rollback;
end;
/

/*
index by varchar2 : 배열안에 들어갈 갯수가 32067byte 사이즈(문자배열방)
*/
================================================================================
[문제 51] 입력값으로 받은 숫자들의 합을 구하는 함수, 평균을 구하는 함수를 패키지에서 생성하세요.

declare
 v_num agg_pack.num_type := agg_pack.num_type(10,5,2,1,8,9,20,21);
begin
  dbms_output.put_line('합 : '||agg_pack.sum_fc(v_num));
  dbms_output.put_line('평균 : '||agg_pack.avg_fc(v_num));
end;
/

합 : 76
평균 : 9.5

create or replace package agg_pack
is
   type num_type is table of number;
   function sum_fc(v_num num_type) return number;
   function avg_fc(v_num num_type) return number;
   function var_fc(v_num num_type) return number;
   function sd_fc(v_num num_type) return number;
end agg_pack;
/

create or replace package body agg_pack
is 
  
  function sum_fc(v_num num_type)
  return number
  is   sgm number := 0;
  begin
     for i in v_num.first..v_num.last loop
       sgm := sgm + v_num(i);
     end loop;
     return sgm;
  end;
  
  function avg_fc(v_num num_type)
  return number
  is 
  begin
     return sum_fc(v_num)/v_num.count;
  end;
  
  function lemma_fc(v_num num_type)
  return number
  is sgm number := 0;
  begin
    for i in v_num.first..v_num.last loop
        sgm := sgm + v_num(i)**2;
    end loop;
       return sgm;
  end;
  
  function var_fc(v_num num_type)
  return number
  is 
     p_num num_type;
  begin
    return lemma_fc(v_num)/v_num.count-(avg_fc(v_num)**2);
  end;
  
  function sd_fc(v_num num_type)
  return number
  is
  begin
    return trunc(sqrt(var_fc(v_num)),2);
  end;
  
end agg_pack;
/

-- sqrt : 루트함수

show error

declare
 v_num agg_pack.num_type := agg_pack.num_type(10,5,2,1,8,9,20,21);
begin
  dbms_output.put_line('합 : '||agg_pack.sum_fc(v_num));
  dbms_output.put_line('평균 : '||agg_pack.avg_fc(v_num));
  dbms_output.put_line('분산 : '||agg_pack.var_fc(v_num));
  dbms_output.put_line('표준편차 : '||agg_pack.sd_fc(v_num));
end;
/

select power(2,2) from dual;
exec dbms_output.put_line(2**2)

================================================================================

[문제52] 분산, 표준편차 함수를 생성하세요.

declare
 v_num agg_pack.num_type := agg_pack.num_type(10,5,2,1,8,9,20,21);
begin
  dbms_output.put_line('합 : '||agg_pack.sum_fc(v_num));
  dbms_output.put_line('평균 : '||agg_pack.avg_fc(v_num));
  dbms_output.put_line('분산 : '||agg_pack.var_fc(v_num));
  dbms_output.put_line('표준편차 : '||agg_pack.sd_fc(v_num));
end;
/


합 : 76
평균 : 9.5
분산 : 49.25
표준편차 : 7.01



create or replace package agg_pack
is
  type num_type is table of number;
  function sum_fc(p_num num_type) return number;
  function avg_fc(p_num num_type) return number;
  function var_fc(p_num num_type) return number;
  function sd_fc(p_num num_type) return number;
end agg_pack;
/

show error

create or replace  package  body  agg_pack
is
  function sum_fc(p_num num_type) return number
  is
    v_sum number := 0;
  begin
	for i in p_num.first..p_num.last loop
		v_sum := v_sum + p_num(i);
    end loop;
        return v_sum;
   end sum_fc;

   function avg_fc(p_num num_type) return number
   is
	v_avg number := 0;
   begin
	v_avg := sum_fc(p_num)/p_num.count;
        return v_avg;
   end avg_fc;

   function var_fc(p_num num_type) return number
   is	
	v_var number;
	v_avg number;
	v_sum number := 0;
   begin
	v_avg := avg_fc(p_num);
	for i in p_num.first..p_num.last loop
		v_sum := v_sum + ((p_num(i)-v_avg)**2);
	end loop;
		v_var := v_sum/p_num.count;
	return v_var;
   end var_fc;

   function sd_fc(p_num num_type) return number
   is
   begin
	return trunc(sqrt(var_fc(p_num)),2);
   end sd_fc;
	
end agg_pack;
/

show error

================================================================================
                              T  R  I  G  G  E  R
================================================================================
/* trigger #1 */
/*
<Database Trigger 수행 순서> : 나도 모르게 돌아간다(밑바닥에서 작동)
 trigger ex) 제약조건
*/

/* 문자 트리거 : DML에 영향을 입은 로우가 존재유무 상관없이 작동 */
create or replace trigger departments_before
before insert on departments --> before : 타이밍(필수기술), insert : 이벤트
begin
	dbms_output.put_line('Statement before trigger is Fired.');
end;
/

create or replace trigger departments_after
after insert on departments
begin
	dbms_output.put_line('Statement After trigger is Fired.');
end;
/

/* 행 트리거 : DML에 영향을 입은 로우가 있으면 작동 */
create or replace trigger departments_row_before
before insert on departments
	for each row --> 행 트리거
begin
	dbms_output.put_line('Row before trigger is Fired.');
end;
/

create or replace trigger departments_row_after
after insert on departments
for each row
begin
	dbms_output.put_line('Row after trigger is Fired.');
end;
/


<<테스트>>

SQL> set serveroutput on

SQL> insert into departments  values(300, 'edu', 100, 1700); rollback;
delete from departments where department_id = 300;
commit;
/*
Statement before trigger is Fired.
Row before trigger is Fired.
Row after trigger is Fired.
Statement After trigger is Fired.
*/
/*
1 row created.
*/

select * from user_triggers where table_name = 'DEPARTMENTS';


drop trigger departments_after;

select * from departments;

--------------------------------------------------------------------------------
/* trigger #2 */

drop table test purge;

create table test(id number, name varchar2(20));


CREATE OR REPLACE TRIGGER secure_emp
BEFORE INSERT ON test
/*declare(사용가능)*/
BEGIN
IF (TO_CHAR(SYSDATE,'DY') IN ('토','일')) OR 
   (TO_CHAR(SYSDATE,'HH24:MI') NOT BETWEEN '11:00' AND '14:00') THEN
RAISE_APPLICATION_ERROR(-20500, 'Insert 시간이 아닙니다. 확인하세요..');
END IF;
END;
/

/* 트리거는 해당 session에서 작동(여기선 insert 수행자) */

SQL> insert into test(id, name) values(2, user);
insert into test(id, name) values(2, user)
            *
ERROR at line 1:
ORA-20500: Insert 시간이 아닙니다. 확인하세요..
ORA-06512: at "HR.SECURE_EMP", line 4
ORA-04088: error during execution of trigger 'HR.SECURE_EMP'

select * from test;
select * from user_sys_privs;
select * from session_privs;
select * from role_sys_privs;

--------------------------------------------------------------------------------

/* trigger #3 */

SQL> create table copy_emp as select employee_id, last_name, salary, department_id from employees;

Table created.



SQL> CREATE OR REPLACE TRIGGER test_trig
BEFORE DELETE OR INSERT OR UPDATE OF salary ON copy_emp --> of column(옵션) : 해당 컬럼에 대해
FOR EACH ROW
WHEN (new.department_id = 20  OR  old.department_id = 10)  --> 문장트리거 사용못함(옵션), 수식자 꼭 써야함
DECLARE
        salary_diff     NUMBER;
BEGIN
        IF deleting /*조건부술어*/ THEN
                dbms_output.put_line('Old salary :'||:old.salary);  --> delete(update) 수식자 :old.salary : 이전값
        ELSIF inserting THEN
                dbms_output.put_line('New salary :'||:new.salary);  --> insert(update) 수식자 :new.salary : 이후값
        ELSE /*update*/
                salary_diff := :new.salary - :old.salary;
                dbms_output.put_line('Employee_id : ' ||:new.employee_id||' Old salary : '||:old.salary ||' New salary : '||:new.salary 
                                        ||' Difference of Salary : '||salary_diff);                
        END IF;
END;
/
   
Trigger created.


SQL> select * from user_triggers where table_name = 'COPY_EMP';

SQL> set serveroutput on

SQL> UPDATE copy_emp
SET salary = salary * 1.1
WHERE department_id = 20;

Employee_id : 201 Old salary : 13000 New salary : 14300 Difference of Salary : 1300
Employee_id : 202 Old salary : 6000 New salary : 6600 Difference of Salary : 600

2 rows updated.

SQL> rollback;

Rollback complete.

SQL> UPDATE copy_emp
SET salary = salary * 1.1
WHERE department_id = 10;

Employee_id : 200 Old salary : 4400 New salary : 4840 Difference of Salary : 440

1 row updated.

SQL> rollback;

Rollback complete.

SQL> UPDATE copy_emp
SET salary = salary * 1.1
WHERE employee_id = 201;

Employee_id : 201 Old salary : 13000 New salary : 14300 Difference of Salary : 1300

1 row updated.

SQL> UPDATE copy_emp
SET salary = salary * 1.1
WHERE employee_id = 200;
 
Employee_id : 200 Old salary : 4400 New salary : 4840 Difference of Salary : 440

1 row updated.


SQL> UPDATE copy_emp
SET salary = salary * 1.1
WHERE employee_id = 100;
/* 100번 사원은 90번 부서라서 출력이 안 되나? */
1 row updated. 

SQL> rollback;

Rollback complete.

SQL> INSERT INTO copy_emp(employee_id, last_name, salary, department_id) VALUES (300,'oracle',1000,20);
New salary :1000

1 row created.


SQL> INSERT INTO copy_emp(employee_id, last_name, salary, department_id) VALUES (400, 'oracle',1000,10);
/* 10번 부서는 old. 인데 insert는 new.라서 출력 안되나? */
1 row created./

SQL> rollback;

Rollback complete.


SQL> DELETE FROM copy_emp WHERE department_id = 10;
Old salary :4400

1 row deleted.

SQL> rollback;

Rollback complete.

SQL> DELETE FROM copy_emp WHERE employee_id = 200;
Old salary :4400

1 row deleted.

SQL> rollback;

Rollback complete.


SQL> DELETE FROM copy_emp WHERE department_id = 20;

2 rows deleted.


SQL> DELETE FROM copy_emp WHERE employee_id = 100;

1 row deleted.

SQL> rollback; 

Rollback complete.

--------------------------------------------------------------------------------

/* trigger #4 */

<INSTEAD OF 트리거 >

1. 예제 테이블을 만듭니다.

DROP TABLE new_emps;
DROP TABLE new_depts;
DROP VIEW emp_details;

/* NEW_EMPS : EMPLOYEES 테이블에서 C.T.A.S */
CREATE TABLE new_emps 
AS
SELECT employee_id, last_name, salary, department_id, email, job_id, hire_date
FROM employees;

/* NEW_DEPTS : EMPLOYEES & DEPARTMENTS JOIN해서 C.T.A.S(부서별 급여총합)*/
CREATE TABLE new_depts 
AS
SELECT d.department_id, d.department_name, d.location_id, SUM(e.salary) TOT_DEPT_SAL
FROM employees e, departments d
WHERE e.department_id=d.department_id
GROUP BY d.department_id, d.department_name, d.location_id;

/* EMP_DETAILS : 복합 view(JOIN이라서) 생성,  DML 안됨 */
CREATE VIEW EMP_DETAILS 
AS  
SELECT e.employee_id, e.last_name, e.salary, e.department_id, e.email, e.job_id, 
       d.department_name, d.location_id, d.tot_dept_sal
FROM new_emps e, new_depts d
WHERE e.department_id=d.department_id;

/* VIEW 복습
① CREATE VIEW는 뷰의 구조를 바꾸려면 뷰를 삭제하고 다시 만들어야 함.
② CREATE OR REPLACE VIEW는 새로운 뷰를 만들거나 기존의 뷰를 통해 새로운 구조의 뷰 생성가능
- VIEW에는 VIEW를 생성하는 SELECT 문만 저장(실제로 테이블은 존재하지 않음)
- VIEW를 SELECT 문으로 검색하는 순간 실제 테이블을 참조하여 보여준다.
- VIEW의 query문에는 ORDER BY 절을 사용할 수 없음
- WITH CHECK OPTION을 사용하면, 해당 VIEW를 통해서 볼 수 있는 범위 내에서만 UPDATE/INSERT 가능
     ex)
        CREATE OR REPLACE VIEW V_EMP_SKILL
        AS
        SELECT *
        FROM EMP_SKILL
        WHERE AVAILABLE = 'YES'
        WITH CHECK OPTION;

  위와 같이 WITH CHECK OPTION을 사용하여 뷰를 만들면, 
  AVAILABLE 컬럼이 'YES'가 아닌 데이터는 VIEW를 통해 입력불가
  (즉, 아래와 같이 입력하는 것은 '불가능'하다)

  INSERT INTO V_EMP_SKILL
  VALUES('10002', 'C101', '01/11/02','NO');

- WITH READ ONLY을 사용하면 해당 VIEW를 통해서는 SELECT만 가능하며 
  INSERT/UPDATE/DELETE를 할 수 없게 됩니다. 만약 이것을 생략한다면, 
  뷰를 사용하여 Create, Update, Delete 등 모두 가능합니다.
*/
2. 	트리거를 작성합니다.

/* EMP_DEPT : */
CREATE OR REPLACE  TRIGGER  EMP_DEPT
  INSTEAD OF  --> view 전용 타이밍(이것만 사용)
    INSERT  OR UPDATE OR DELETE  ON  EMP_DETAILS
    FOR EACH ROW  --> view는 문장트리거 안됨
BEGIN
  /* CASE #1. EMP_DETAILS에서 추가(:NEW.) */
  IF INSERTING THEN 
      
      /* NEW_EMPS에도 자동추가 */
    	INSERT INTO new_emps
     	VALUES (:NEW.employee_id, :NEW.last_name, :NEW.salary, :NEW.department_id, :NEW.email, :NEW.job_id, SYSDATE);
      
      /* NEW_DEPTS에는 해당 부서 tot_dept_sal 자동증가 */
    	UPDATE new_depts
     	SET  tot_dept_sal = tot_dept_sal + :NEW.salary
     	WHERE department_id = :NEW.department_id;
      
  /* CASE #2. EMP_DETAILS에서 삭제(:OLD.) */    
  ELSIF DELETING  THEN 
      
      /* NEW_EMPS에도 자동삭제 */
    	DELETE FROM new_emps 
     	WHERE employee_id = :OLD.employee_id;

    	/* NEW_DEPTS에는 해당 부서 tot_dept_sal 자동감소 */
      UPDATE new_depts
     	SET  tot_dept_sal = tot_dept_sal - :OLD.salary
     	WHERE department_id = :OLD.department_id;
      
  /* CASE #3. EMP_DETAILS에서 급여 변경(:NEW. & :OLD.) */     
  ELSIF UPDATING ('salary')  THEN
    	
      /* NEW : SALARY | OLD : EMP_ID(상대적 기준) */
      UPDATE new_emps
 	    SET  salary = :NEW.salary
     	WHERE employee_id = :OLD.employee_id;
    	
      /* NEW : 변경후 SALARY | OLD : 변경전 SALARY, DEPT_ID(상대적 기준) */
	    UPDATE new_depts
 	    SET  tot_dept_sal = tot_dept_sal + (:NEW.salary - :OLD.salary)
     	WHERE department_id = :OLD.department_id;

  /* CASE #4. EMP_DETAILS에서 부서변경 */
  ELSIF UPDATING ('department_id')  THEN
      
      /* NEW : 변경후 DEPT_ID | OLD : EMP_ID(상대적 기준) */
    	UPDATE new_emps
 	    SET department_id = :NEW.department_id
     	WHERE employee_id = :OLD.employee_id;
    	
      /* NEW_DEPTS 예전 부서 총합급여는 -, 새 부서 총합급여는 + */
	    UPDATE new_depts	
      SET  tot_dept_sal = tot_dept_sal - :OLD.salary
     	WHERE department_id = :OLD.department_id;
    	
	    UPDATE new_depts	
 	    SET tot_dept_sal = tot_dept_sal + :NEW.salary
     	WHERE department_id = :NEW.department_id;
  END IF;    
END;
/
/* 트리거 내부에서는 rollback, commit 사용하면 안됨(외부까지 영향 끼침) 
   PRAGMA_AUTONOMOUS_TRANSACTION 쓰면 사용가능 */

<<테스트>>
select * from new_emps;
select * from new_depts;

/* CASE #1. EMP_DETAILS에서 추가(:NEW.) */ 
INSERT INTO emp_details (employee_id, last_name, salary, department_id, email, job_id) 
VALUES (9001,'ABBOTT',1000,10,'abbott.mail','HR_MAN');
     --> new_emps : insert & new_depts : update
     --> 이거 끝나고 transaction 마무리 해야함

/* CASE #2. EMP_DETAILS에서 삭제(:OLD.) */
delete from emp_details 
where employee_id = 9001;

/* CASE #3. EMP_DETAILS에서 급여 변경(:NEW. & :OLD.) */ 
update emp_details 
set salary = salary * 1.1 
where department_id = 10;

/* CASE #4. EMP_DETAILS에서 부서변경 */
update emp_details
set department_id = 50
where employee_id = 9001;

select * from new_emps;
select * from new_depts;

rollback;

--------------------------------------------------------------------------------

/* TRIGGER_AUTONOMOUS */

/* TEST용 테이블 */                                  
create table trigger_tab (id number, name char(10), day timestamp default systimestamp);


/* 로그기록 저장 테이블 */
create table trigger_log(id number, name char(10), log_day timestamp default systimestamp);


/* CASE #1. 무조건 로그기록 남겨야 한다면 */

CREATE OR REPLACE TRIGGER trigger_log
    AFTER INSERT OR UPDATE OR DELETE ON trigger_tab FOR EACH ROW
DECLARE
       PRAGMA AUTONOMOUS_TRANSACTION; /* transaction 분리 */
BEGIN
       INSERT INTO trigger_log (id, name, log_day) 
       VALUES(:new.id, :new.name, default);
       COMMIT;
END;
  /

insert into trigger_tab(id, name) values(1, user);
/*
1 row created.
*/
rollback;

select * from trigger_tab;
/*
no rows selected
*/

/* 로그기록 테이블은 rollback의 영향 안 받을 걸 확인 */
select * from trigger_log;

        ID NAME                 LOG_DAY
---------- -------------------- ------------------------------
         1 HR                   14/10/17 11:38:27.607000


/* CASE #2. commit한 로그기록만 남기려면 */

CREATE OR REPLACE TRIGGER trigger_log
  AFTER INSERT OR UPDATE OR DELETE ON trigger_tab FOR EACH ROW
BEGIN
  INSERT INTO trigger_log (id, name, log_day) 
  VALUES(:new.id, :new.name, default);
END;
/

insert into trigger_tab(id, name) values(1, user);
/*
1 row created.
*/
rollback;
commit;

delete from trigger_tab where id = 1;

select * from trigger_tab;
/*
no rows selected
*/

select * from trigger_log;
truncate table trigger_log;

select * from user_triggers;