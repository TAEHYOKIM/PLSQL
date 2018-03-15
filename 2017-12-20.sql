/* returning bulk collect into */
DECLARE
   TYPE record_type IS RECORD(name varchar2(50), sal number);
   TYPE table_type IS TABLE OF record_type;  
   v_tab table_type;
BEGIN    	
  	UPDATE employees  
     	SET salary = salary * 1.1  
    	WHERE department_id = 20 
        RETURNING  last_name, salary BULK COLLECT INTO v_tab; --> *�� ���� �ȵ�
  
	FOR i IN v_tab.first..v_tab.last LOOP
    	 DBMS_OUTPUT.PUT_LINE(v_tab(i).name ||' '||v_tab(i).sal);
  	END LOOP;
END;  
/

rollback;

--------------------------------------------------------------------------------

[����49] ������� �޿��� 10% �λ��ϴ� ���α׷��� �������ּ���. 

declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,180,190,200);
begin 
    emp_pkg.update_sal(v_num);
end;
/

�����ȣ : 100        ����̸� : King       ���� �޿� : 29040
�����ȣ : 103        ����̸� : Hunold     ���� �޿� : 9900
�����ȣ : 107        ����̸� : Lorentz    ���� �޿� : 4620
�����ȣ : 110        ����̸� : Chen       ���� �޿� : 9020
�����ȣ : 112        ����̸� : Urman      ���� �޿� : 8580
�����ȣ : 115        ����̸� : Khoo       ���� �޿� : 3410
�����ȣ : 160        ����̸� : Doran      ���� �޿� : 8250
�����ȣ : 170        ����̸� : Fox        ���� �޿� : 10560
�����ȣ : 180        ����̸� : Taylor     ���� �޿� : 3520
�����ȣ : 190        ����̸� : Gates      ���� �޿� : 3190
�����ȣ : 200        ����̸� : Whalen     ���� �޿� : 5808


-- �Է°� : �����ȣ(������), update in ���ĸŰ�����(�迭)
-- ���ڹ迭Ÿ�� ����(numlist), nested table ��Ű�� �� ����
-- dml sql������ ó�� forall�� ���, returning bulk collect into ���

/*spec ����*/
create or replace package emp_pkg
is 
   type numlist is table of number;
   procedure update_sal(v_num in numlist);
end emp_pkg;
/

/*body ����*/
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
     dbms_output.put_line('�����ȣ : '||rpad(v_num(i),10)||
                          '����̸� : '||rpad(v_tab(i).l_nm,10)||
                          '���� �޿� : '||rpad(v_tab(i).sal,10));
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
  : 9i ����, ȣ���ڿ� ���α׷��� ������ transaction ó��(��ȣ�� �������) */
  
-- case 0. ���α׷� transaction ó���� �̼���

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
	
	ROLLBACK;  --> ���δ�(#1,2,3) rollback
END;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

--------------------------------------------------------------------------------

-- case 1. PRAGMA_AUTONOMOUS_TRANSACTION �̻��

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

	log_message('rolling back insert into temp_table'); --> #1�� ����
	
	ROLLBACK;  --> #1�� �ƹ��� ���� ����
END;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

--------------------------------------------------------------------------------

-- case 2. PRAGMA_AUTONOMOUS_TRANSACTION ���

CREATE TABLE log_table(
	username varchar2(30),
	date_time timestamp,
	message varchar2(4000));

CREATE TABLE temp_table(
	n number);


CREATE OR REPLACE PROCEDURE log_message(p_message varchar2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;  --> ���þ�, ���α׷� ���ο����� commit, rollback ��
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

	INSERT INTO temp_table(n)  --> PRAGMA AUTONOMOUS_TRANSACTION; ������ transaction stop
	VALUES(12345);

	log_message('rolling back insert into temp_table');
	
	ROLLBACK;
END;
/

SELECT * FROM temp_table;

SELECT * FROM log_table;

/* ��� : transaction�� ���α׷� ���ܺο� ������� ���Ӱ����� �����̹Ƿ� ����ó�� �������� */

================================================================================
/*
<One-Time-Only> : �ѹ� ȣ���� ���� ������(�� ���� ������ ����)
*/

-- 1. ���� ���̺��� ����ϴ�.

SQL> CREATE TABLE TAX_RATES (rate_name VARCHAR2(30), rate_value NUMBER, rate_date DATE);

Table created.

-- 2. �ڷ��� INSERT �մϴ�. 

SQL> INSERT INTO tax_rates (rate_name, rate_value, rate_date) VALUES ('TAX',0.08,to_date('2014-05-28','YYYY-MM-DD'));

1 row created.

SQL> commit;

Commit complete.

SQL> select * from tax_rates;

RATE_NAME                      RATE_VALUE RATE_DATE
------------------------------ ---------- ---------
TAX                                   .08 28-MAY-14

-- 3. ��Ű���� �ۼ��մϴ�. 

SQL> CREATE OR REPLACE PACKAGE  taxes
IS
                 tax   NUMBER;   --> global ����
END taxes;
/ 

Package created.


SQL> CREATE OR REPLACE PACKAGE BODY taxes
IS

BEGIN --> �ɼ� ���� ���߿� ���
        SELECT  rate_value --> �� session�� 1ȸ��
        INTO    tax
        FROM    tax_rates
        WHERE   rate_name = 'TAX';
END taxes;
/   

Package body created.



-- 4. session_1 Package ����

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
�׽�Ʈ �ÿ� ���ο� session â�� ��� TAXES.TAX Ȯ�� 

SQL> set  serveroutput  on

SQL> EXECUTE DBMS_OUTPUT.PUT_LINE (TAXES.TAX)
1

PL/SQL procedure successfully completed.

/* ��� : �����ϰ� ����ε� ���� �ȵ��ִٰ� ����ȣ���ؼ� ���� �ִ¼��� 
         ����� �Ǿ������ �������� ������ �ȵȴٴ� ���̿��� */
         
================================================================================

/* exception_�̸�ǥ��ȭ : ���ܻ��� �̸� �������� �������� */

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
	notnull_err EXCEPTION;  --> �̸����� �� ����
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


/* DBMS ��� : 
INSERT OPERATION FAILED
ORA-01400: cannot insert NULL into ("HR"."DEPARTMENTS"."DEPARTMENT_NAME")
*/

================================================================================

/* local_subprogram : �� ���α׷� �ȿ����� ����� �Լ�, ���ν����� ���𰡴� 
                      (���� �ݺ� ������ ȿ�������� �����ϱ� ����) */
         
DECLARE
  TYPE emp_id_type IS TABLE OF number;
  v_id emp_id_type := emp_id_type(100,101,102);
  v_emp employees%ROWTYPE;

  FUNCTION tax(p_salary VARCHAR2) RETURN NUMBER   --> �������� �;���
  IS
  BEGIN
    RETURN p_salary * 0.8;
  END tax;
  
  PROCEDURE message                               --> �������� �;���
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('���� �Ϸ絵 �����ϼ̽��ϴ�.');
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

-- ���α׷� �ڵ�� �ǹ̾��� ������ üũ

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

-- ���ɿ� ������ �Ǵ� �κ� üũ

SQL> ALTER SESSION SET PLSQL_WARNINGS='ENABLE:PERFORMANCE'; 

Session altered.

SQL> CREATE OR REPLACE PROCEDURE p1
IS
BEGIN
   INSERT INTO t1 VALUES ( 10 ); --> to_char(10) ����ȯ �ҿ� �߻�
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
  a := TRIM(' X '); --> ���� ����Ŭ trim �Լ����� standard.trim()
END SEVERE_1;
/  

Procedure created.


-- ����Ŭ�� �Լ��̸��� ������ �̸��� ����ϸ� �Ŀ� �������� ���� üũ

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








