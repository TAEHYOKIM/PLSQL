/* returning bulk collect into */
DECLARE
   TYPE record_type IS RECORD(name varchar2(50), sal number);
   TYPE table_type IS TABLE OF record_type;  
   v_tab table_type;
BEGIN    	
  	UPDATE employees  
     	SET salary = salary * 1.1  
    	WHERE department_id = 20 
        RETURNING  last_name, salary BULK COLLECT INTO v_tab; --> *은 아직 안됨
  
	FOR i IN v_tab.first..v_tab.last LOOP
    	 DBMS_OUTPUT.PUT_LINE(v_tab(i).name ||' '||v_tab(i).sal);
  	END LOOP;
END;  
/

rollback;

--------------------------------------------------------------------------------

[문제49] 사원들의 급여를 10% 인상하는 프로그램을 생성해주세요. 

declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,180,190,200);
begin 
    emp_pkg.update_sal(v_num);
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
사원번호 : 200        사원이름 : Whalen     수정 급여 : 5808


-- 입력값 : 사원번호(여러명), update in 형식매개변수(배열)
-- 숫자배열타입 선언(numlist), nested table 패키지 내 구현
-- dml sql엔진이 처리 forall문 사용, returning bulk collect into 사용

/*spec 생성*/
create or replace package emp_pkg
is 
   type numlist is table of number;
   procedure update_sal(v_num in numlist);
end emp_pkg;
/

/*body 생성*/
create or replace package body emp_pkg
is 
   procedure update_sal(v_num in numlist)
   is
      type rec_type is record(l_nm varchar2(30), sal number);
      type tab_type is table of rec_type index by binary_integer;
      v_tab tab_type;

   begin
     forall i in v_num.first..v_num.last
        update employees
        set salary = salary * 1.1
        where employee_id = v_num(i)
        returning last_name, salary bulk collect into v_tab;

     for i in v_num.first..v_num.last loop
     dbms_output.put_line('사원번호 : '||rpad(v_num(i),10)||
                          '사원이름 : '||rpad(v_tab(i).l_nm,10)||
                          '수정 급여 : '||rpad(v_tab(i).sal,10));
     end loop;
     dbms_output.put_line(sql%rowcount);
   end;
end emp_pkg;
/

show error


declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,180,190,200);
begin 
    emp_pkg.update_sal(v_num);
end;
/
rollback;

select last_name, salary 
from employees 
where employee_id in (100,103,107,110,112,115,160,170,180,190,200);

select * from employees 
as of timestamp to_timestamp('20171220 10:40:30', 'yyyymmdd hh24:mi:ss')
where employee_id in (100,103,107,110,112,115,160,170,180,190,200);


================================================================================

/* PRAGMA_AUTONOMOUS_TRANSACTION 
  : 9i 이후, 호출자와 프로그램의 독립된 transaction 처리(상호간 영향방지) */
  
-- case 0. 프로그램 transaction 처리문 미설정

CREATE TABLE log_table(
	username varchar2(30),
	date_time timestamp,
	message varchar2(4000));

CREATE TABLE temp_table(
	n number);


CREATE OR REPLACE PROCEDURE log_message(p_message varchar2)
IS

BEGIN
	INSERT INTO log_table(username,date_time,message)
	VALUES(user,current_date,p_message);

END log_message;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

BEGIN
	log_message('About to insert into temp_table'); --> transaction #1(start)

	INSERT INTO temp_table(n) --> transaction #2(ing)
	VALUES(12345);

	log_message('rolling back insert into temp_table'); --> transaction #3(ing)
	
	ROLLBACK;  --> 전부다(#1,2,3) rollback
END;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

--------------------------------------------------------------------------------

-- case 1. PRAGMA_AUTONOMOUS_TRANSACTION 미사용

CREATE TABLE log_table(
	username varchar2(30),
	date_time timestamp,
	message varchar2(4000));

CREATE TABLE temp_table(
	n number);


CREATE OR REPLACE PROCEDURE log_message(p_message varchar2)
IS

BEGIN
	INSERT INTO log_table(username,date_time,message)
	VALUES(user,current_date,p_message);
	COMMIT;
END log_message;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

BEGIN
	log_message('About to insert into temp_table');

	INSERT INTO temp_table(n) --> transaction #1(start)
	VALUES(12345);

	log_message('rolling back insert into temp_table'); --> #1에 영향
	
	ROLLBACK;  --> #1에 아무런 영향 못줌
END;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

--------------------------------------------------------------------------------

-- case 2. PRAGMA_AUTONOMOUS_TRANSACTION 사용

CREATE TABLE log_table(
	username varchar2(30),
	date_time timestamp,
	message varchar2(4000));

CREATE TABLE temp_table(
	n number);


CREATE OR REPLACE PROCEDURE log_message(p_message varchar2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;  --> 지시어, 프로그램 내부에서만 commit, rollback 됨
BEGIN
	INSERT INTO log_table(username,date_time,message)
	VALUES(user,current_date,p_message);
	COMMIT;
END log_message;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

BEGIN
	log_message('About to insert into temp_table');

	INSERT INTO temp_table(n)  --> PRAGMA AUTONOMOUS_TRANSACTION; 만나면 transaction stop
	VALUES(12345);

	log_message('rolling back insert into temp_table');
	
	ROLLBACK;
END;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

/* 결론 : transaction은 프로그램 내외부에 상관없이 지속가능한 성질이므로 맺음처리 주의하자 */

================================================================================
/*
<One-Time-Only> : 한번 호출한 값만 보여줘(그 이후 변동은 무시)
*/

-- 1. 예제 테이블을 만듭니다.

SQL> CREATE TABLE TAX_RATES (rate_name VARCHAR2(30), rate_value NUMBER, rate_date DATE);

Table created.

-- 2. 자료을 INSERT 합니다. 

SQL> INSERT INTO tax_rates (rate_name, rate_value, rate_date) VALUES ('TAX',0.08,to_date('2014-05-28','YYYY-MM-DD'));

1 row created.

SQL> commit;

Commit complete.

SQL> select * from tax_rates;

RATE_NAME                      RATE_VALUE RATE_DATE
------------------------------ ---------- ---------
TAX                                   .08 28-MAY-14

-- 3. 패키지를 작성합니다. 

SQL> CREATE OR REPLACE PACKAGE  taxes
IS
                 tax   NUMBER;   --> global 변수
END taxes;
/ 

Package created.


SQL> CREATE OR REPLACE PACKAGE BODY taxes
IS

BEGIN --> 옵션 제일 나중에 기술
        SELECT  rate_value --> 각 session별 1회용
        INTO    tax
        FROM    tax_rates
        WHERE   rate_name = 'TAX';
END taxes;
/   

Package body created.



-- 4. session_1 Package 실행

SQL> set  serveroutput on
SQL> EXECUTE DBMS_OUTPUT.PUT_LINE (TAXES.TAX)

.08

PL/SQL procedure successfully completed.

-- 5. session_2
SQL> update tax_rates
     set rate_value = 1
     where rate_name = 'TAX';  

1 row updated.

SQL> commit;

Commit complete.

SQL> select * from tax_rates;

RATE_NAME                      RATE_VALUE RATE_DATE
------------------------------ ---------- ---------
TAX                                     1 28-MAY-14

-- 6. session_1 

SQL> EXECUTE DBMS_OUTPUT.PUT_LINE (TAXES.TAX)
.08

PL/SQL procedure successfully completed.

select * from tax_rates;
======================================================
테스트 시에 새로운 session 창을 열어서 TAXES.TAX 확인 

SQL> set  serveroutput  on

SQL> EXECUTE DBMS_OUTPUT.PUT_LINE (TAXES.TAX)
1

PL/SQL procedure successfully completed.

/* 결론 : 간단하게 상수인데 값이 안들어가있다가 변수호출해서 값을 넣는순간 
         상수가 되어버려서 다음부턴 수정이 안된다는 뜻이에요 */
         
================================================================================

/* exception_이름표준화 : 예외사항 이름 마구잡이 생성방지 */

DECLARE
	e_insert_excep EXCEPTION;
	PRAGMA EXCEPTION_INIT(e_insert_excep, -01400);
BEGIN
	INSERT INTO departments(department_id, department_name) 
	VALUES (280, NULL);
EXCEPTION
	WHEN e_insert_excep THEN
		DBMS_OUTPUT.PUT_LINE('INSERT OPERATION FAILED');
		DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

/* spec */
CREATE OR REPLACE PACKAGE err_pkg
IS
	notnull_err EXCEPTION;  --> 이름통일 및 공유
	PRAGMA EXCEPTION_INIT(notnull_err, -01400);
END;
/



BEGIN
	INSERT INTO departments(department_id, department_name) 
	VALUES (280, NULL);
EXCEPTION
	WHEN err_pkg.notnull_err THEN
		DBMS_OUTPUT.PUT_LINE('INSERT OPERATION FAILED');
		DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/


/* DBMS 출력 : 
INSERT OPERATION FAILED
ORA-01400: cannot insert NULL into ("HR"."DEPARTMENTS"."DEPARTMENT_NAME")
*/

================================================================================

/* local_subprogram : 이 프로그램 안에서만 사용할 함수, 프로시저를 선언가능 
                      (복잡 반복 로직을 효율적으로 수행하기 위해) */
         
DECLARE
  TYPE emp_id_type IS TABLE OF number;
  v_id emp_id_type := emp_id_type(100,101,102);
  v_emp employees%ROWTYPE;

  FUNCTION tax(p_salary VARCHAR2) RETURN NUMBER   --> 마지막에 와야함
  IS
  BEGIN
    RETURN p_salary * 0.8;
  END tax;
  
  PROCEDURE message                               --> 마지막에 와야함
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('오늘 하루도 수고하셨습니다.');
  END;
  
BEGIN
  FOR i IN v_id.first..v_id.last LOOP
   
	 SELECT * INTO v_emp FROM EMPLOYEES WHERE employee_id = v_id(i);

    	 DBMS_OUTPUT.PUT_LINE('EMP_ID : ' ||v_emp.employee_id ||' Tax: '|| tax(v_emp.salary));

  END LOOP;

  message;

END;
/         


================================================================================

/* PLSQL_WARNINGS */

-- 프로그램 코드상에 의미없는 로직을 체크

SQL> ALTER SESSION SET PLSQL_WARNINGS='ENABLE:INFORMATIONAL';

Session altered.

SQL> CREATE OR REPLACE PROCEDURE p
IS
BEGIN
  IF 1=2 THEN NULL; 
  END IF;
END p;
/

SP2-0804: Procedure created with compilation warnings

SQL> show error
Errors for PROCEDURE P:

LINE/COL ERROR
-------- -----------------------------------------------------------------
4/15     PLW-06002: Unreachable code




SQL> ALTER SESSION SET PLSQL_WARNINGS='DISABLE:INFORMATIONAL';

Session altered.

SQL> CREATE OR REPLACE PROCEDURE p
IS
BEGIN
  IF 1=2 THEN NULL;
  END IF;
END p;
/  

Procedure created.



SQL> CREATE TABLE t1 ( a VARCHAR2(10) );


SQL> CREATE OR REPLACE PROCEDURE p1
IS
BEGIN
   INSERT INTO t1 VALUES ( 10 );
END p1;
/

Procedure created.

-- 성능에 문제가 되는 부분 체크

SQL> ALTER SESSION SET PLSQL_WARNINGS='ENABLE:PERFORMANCE'; 

Session altered.

SQL> CREATE OR REPLACE PROCEDURE p1
IS
BEGIN
   INSERT INTO t1 VALUES ( 10 ); --> to_char(10) 형변환 소요 발생
END p1;
/  

SP2-0804: Procedure created with compilation warnings

SQL> show error
Errors for PROCEDURE P1:

LINE/COL ERROR
-------- -----------------------------------------------------------------
4/28     PLW-07202: bind type would result in conversion away from column type





SQL> CREATE OR REPLACE PROCEDURE SEVERE_1 IS
 a varchar2(20);
FUNCTION trim(v IN VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
   RETURN v;
 END;
BEGIN
  a := TRIM(' X '); --> 추후 오라클 trim 함수사용시 standard.trim()
END SEVERE_1;
/  

Procedure created.


-- 오라클의 함수이름과 동일한 이름을 사용하면 후에 잠제적인 문제 체크

SQL> ALTER SESSION SET PLSQL_WARNINGS='ENABLE:SEVERE';  

Session altered.

SQL> CREATE OR REPLACE PROCEDURE SEVERE_1 IS
 a varchar2(20);
FUNCTION trim(v IN VARCHAR2) RETURN VARCHAR2 IS
 BEGIN
   RETURN v;
 END;
BEGIN
  a := TRIM(' X ');
END SEVERE_1;
/

SP2-0804: Procedure created with compilation warnings

SQL> show error
Errors for PROCEDURE SEVERE_1:

LINE/COL ERROR
-------- ---------------------------------------------------------------------------
3/10     PLW-05004: identifier TRIM is also declared in STANDARD or is a SQL builtin








