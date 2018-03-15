[����50] ������� �޿��� 10% �λ��ϴ� ���α׷��� �������ּ���.

declare
   v_num  emp_pkg.numlist := emp_pkg.numlist(100,103,107,110,112,115,160,170,250,180,190,200,300);
begin 
    emp_pkg.update_sal(v_num);
    rollback;
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
�����ȣ : 200        ����̸� : Whalen     ���� �޿� : 0
250 ó������ �ʴ� ���Դϴ�.
300 ó������ �ʴ� ���Դϴ�.

-- ���ڿ� ��? ���� ��� ���ܻ��� ó���ؾ� ��

/* spec ���� */
create or replace package emp_pkg
is 
  type numlist is table of number;
  procedure update_sal(v_num numlist);
end emp_pkg;
/
/* body ���� */
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
      dbms_output.put_line('�����ȣ : '||rpad(v_tab(i).e_id,10)||
                           '����̸� : '||rpad(v_tab(i).l_nm,10)||
                           '���� �޿� : '||rpad(v_tab(i).sal,10));
    end loop;
    */
    for i in v_num.first..v_num.last loop
      for j in v_tab.first..v_tab.last loop
        if v_num(i)=v_tab(j).e_id then
      dbms_output.put_line('�����ȣ : '||rpad(v_tab(j).e_id,10)||
                           '����̸� : '||rpad(v_tab(j).l_nm,10)||
                           '���� �޿� : '||rpad(v_tab(j).sal,10));
           exit;
        elsif j = v_tab.last then
          dbms_output.put_line(v_num(i)||' ó������ �ʴ� ���Դϴ�.');
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
- plsql �Լ� ��� ����. 
���ν��������� ����� �� �ִ� �Լ�. �����Ҵ翬���� �����ʿ� �Լ� �� �� ����. �̰� ���ν�����.
decode�Լ�, �׷��Լ��� ���ν��������� ����� �� ����. 
*/

================================================================================
/* �迭Ÿ�� ���� */
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
		  dbms_output.put_line(p_id(i) ||' ó�� ���� �ʾҽ��ϴ�.');
	  else
	    dbms_output.put_line('�����ȣ : '|| rpad(v_tab(i).id,10,' ')||' ����̸� : '
			 ||rpad(v_tab(i).name,10,' ')||' ���� �޿� : '||rpad(v_tab(i).sal,10,' '));
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
		dbms_output.put_line(p_id(i) ||' ó�� ���� �ʾҽ��ϴ�.');
	else
	 dbms_output.put_line('�����ȣ : '|| rpad(v_tab.id,10,' ')||' ����̸� : '
			 ||rpad(v_tab.name,10,' ')||' ���� �޿� : '||rpad(v_tab.sal,10,' '));
	
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
		dbms_output.put_line(p_id(i) ||' ó�� ���� �ʾҽ��ϴ�.');
	else
	 dbms_output.put_line('�����ȣ : '|| rpad(v_tab(i).id,10,' ')||' ����̸� : '
			 ||rpad(v_tab(i).name,10,' ')||' ���� �޿� : '||rpad(v_tab(i).sal,10,' '));
	
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
index by varchar2 : �迭�ȿ� �� ������ 32067byte ������(���ڹ迭��)
*/
================================================================================
[���� 51] �Է°����� ���� ���ڵ��� ���� ���ϴ� �Լ�, ����� ���ϴ� �Լ��� ��Ű������ �����ϼ���.

declare
 v_num agg_pack.num_type := agg_pack.num_type(10,5,2,1,8,9,20,21);
begin
  dbms_output.put_line('�� : '||agg_pack.sum_fc(v_num));
  dbms_output.put_line('��� : '||agg_pack.avg_fc(v_num));
end;
/

�� : 76
��� : 9.5

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

-- sqrt : ��Ʈ�Լ�

show error

declare
 v_num agg_pack.num_type := agg_pack.num_type(10,5,2,1,8,9,20,21);
begin
  dbms_output.put_line('�� : '||agg_pack.sum_fc(v_num));
  dbms_output.put_line('��� : '||agg_pack.avg_fc(v_num));
  dbms_output.put_line('�л� : '||agg_pack.var_fc(v_num));
  dbms_output.put_line('ǥ������ : '||agg_pack.sd_fc(v_num));
end;
/

select power(2,2) from dual;
exec dbms_output.put_line(2**2)

================================================================================

[����52] �л�, ǥ������ �Լ��� �����ϼ���.

declare
 v_num agg_pack.num_type := agg_pack.num_type(10,5,2,1,8,9,20,21);
begin
  dbms_output.put_line('�� : '||agg_pack.sum_fc(v_num));
  dbms_output.put_line('��� : '||agg_pack.avg_fc(v_num));
  dbms_output.put_line('�л� : '||agg_pack.var_fc(v_num));
  dbms_output.put_line('ǥ������ : '||agg_pack.sd_fc(v_num));
end;
/


�� : 76
��� : 9.5
�л� : 49.25
ǥ������ : 7.01



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
<Database Trigger ���� ����> : ���� �𸣰� ���ư���(�عٴڿ��� �۵�)
 trigger ex) ��������
*/

/* ���� Ʈ���� : DML�� ������ ���� �ο찡 �������� ������� �۵� */
create or replace trigger departments_before
before insert on departments --> before : Ÿ�̹�(�ʼ����), insert : �̺�Ʈ
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

/* �� Ʈ���� : DML�� ������ ���� �ο찡 ������ �۵� */
create or replace trigger departments_row_before
before insert on departments
	for each row --> �� Ʈ����
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


<<�׽�Ʈ>>

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
/*declare(��밡��)*/
BEGIN
IF (TO_CHAR(SYSDATE,'DY') IN ('��','��')) OR 
   (TO_CHAR(SYSDATE,'HH24:MI') NOT BETWEEN '11:00' AND '14:00') THEN
RAISE_APPLICATION_ERROR(-20500, 'Insert �ð��� �ƴմϴ�. Ȯ���ϼ���..');
END IF;
END;
/

/* Ʈ���Ŵ� �ش� session���� �۵�(���⼱ insert ������) */

SQL> insert into test(id, name) values(2, user);
insert into test(id, name) values(2, user)
            *
ERROR at line 1:
ORA-20500: Insert �ð��� �ƴմϴ�. Ȯ���ϼ���..
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
BEFORE DELETE OR INSERT OR UPDATE OF salary ON copy_emp --> of column(�ɼ�) : �ش� �÷��� ����
FOR EACH ROW
WHEN (new.department_id = 20  OR  old.department_id = 10)  --> ����Ʈ���� ������(�ɼ�), ������ �� �����
DECLARE
        salary_diff     NUMBER;
BEGIN
        IF deleting /*���Ǻμ���*/ THEN
                dbms_output.put_line('Old salary :'||:old.salary);  --> delete(update) ������ :old.salary : ������
        ELSIF inserting THEN
                dbms_output.put_line('New salary :'||:new.salary);  --> insert(update) ������ :new.salary : ���İ�
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
/* 100�� ����� 90�� �μ��� ����� �� �ǳ�? */
1 row updated. 

SQL> rollback;

Rollback complete.

SQL> INSERT INTO copy_emp(employee_id, last_name, salary, department_id) VALUES (300,'oracle',1000,20);
New salary :1000

1 row created.


SQL> INSERT INTO copy_emp(employee_id, last_name, salary, department_id) VALUES (400, 'oracle',1000,10);
/* 10�� �μ��� old. �ε� insert�� new.�� ��� �ȵǳ�? */
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

<INSTEAD OF Ʈ���� >

1. ���� ���̺��� ����ϴ�.

DROP TABLE new_emps;
DROP TABLE new_depts;
DROP VIEW emp_details;

/* NEW_EMPS : EMPLOYEES ���̺��� C.T.A.S */
CREATE TABLE new_emps 
AS
SELECT employee_id, last_name, salary, department_id, email, job_id, hire_date
FROM employees;

/* NEW_DEPTS : EMPLOYEES & DEPARTMENTS JOIN�ؼ� C.T.A.S(�μ��� �޿�����)*/
CREATE TABLE new_depts 
AS
SELECT d.department_id, d.department_name, d.location_id, SUM(e.salary) TOT_DEPT_SAL
FROM employees e, departments d
WHERE e.department_id=d.department_id
GROUP BY d.department_id, d.department_name, d.location_id;

/* EMP_DETAILS : ���� view(JOIN�̶�) ����,  DML �ȵ� */
CREATE VIEW EMP_DETAILS 
AS  
SELECT e.employee_id, e.last_name, e.salary, e.department_id, e.email, e.job_id, 
       d.department_name, d.location_id, d.tot_dept_sal
FROM new_emps e, new_depts d
WHERE e.department_id=d.department_id;

/* VIEW ����
�� CREATE VIEW�� ���� ������ �ٲٷ��� �並 �����ϰ� �ٽ� ������ ��.
�� CREATE OR REPLACE VIEW�� ���ο� �並 ����ų� ������ �並 ���� ���ο� ������ �� ��������
- VIEW���� VIEW�� �����ϴ� SELECT ���� ����(������ ���̺��� �������� ����)
- VIEW�� SELECT ������ �˻��ϴ� ���� ���� ���̺��� �����Ͽ� �����ش�.
- VIEW�� query������ ORDER BY ���� ����� �� ����
- WITH CHECK OPTION�� ����ϸ�, �ش� VIEW�� ���ؼ� �� �� �ִ� ���� �������� UPDATE/INSERT ����
     ex)
        CREATE OR REPLACE VIEW V_EMP_SKILL
        AS
        SELECT *
        FROM EMP_SKILL
        WHERE AVAILABLE = 'YES'
        WITH CHECK OPTION;

  ���� ���� WITH CHECK OPTION�� ����Ͽ� �並 �����, 
  AVAILABLE �÷��� 'YES'�� �ƴ� �����ʹ� VIEW�� ���� �ԷºҰ�
  (��, �Ʒ��� ���� �Է��ϴ� ���� '�Ұ���'�ϴ�)

  INSERT INTO V_EMP_SKILL
  VALUES('10002', 'C101', '01/11/02','NO');

- WITH READ ONLY�� ����ϸ� �ش� VIEW�� ���ؼ��� SELECT�� �����ϸ� 
  INSERT/UPDATE/DELETE�� �� �� ���� �˴ϴ�. ���� �̰��� �����Ѵٸ�, 
  �並 ����Ͽ� Create, Update, Delete �� ��� �����մϴ�.
*/
2. 	Ʈ���Ÿ� �ۼ��մϴ�.

/* EMP_DEPT : */
CREATE OR REPLACE  TRIGGER  EMP_DEPT
  INSTEAD OF  --> view ���� Ÿ�̹�(�̰͸� ���)
    INSERT  OR UPDATE OR DELETE  ON  EMP_DETAILS
    FOR EACH ROW  --> view�� ����Ʈ���� �ȵ�
BEGIN
  /* CASE #1. EMP_DETAILS���� �߰�(:NEW.) */
  IF INSERTING THEN 
      
      /* NEW_EMPS���� �ڵ��߰� */
    	INSERT INTO new_emps
     	VALUES (:NEW.employee_id, :NEW.last_name, :NEW.salary, :NEW.department_id, :NEW.email, :NEW.job_id, SYSDATE);
      
      /* NEW_DEPTS���� �ش� �μ� tot_dept_sal �ڵ����� */
    	UPDATE new_depts
     	SET  tot_dept_sal = tot_dept_sal + :NEW.salary
     	WHERE department_id = :NEW.department_id;
      
  /* CASE #2. EMP_DETAILS���� ����(:OLD.) */    
  ELSIF DELETING  THEN 
      
      /* NEW_EMPS���� �ڵ����� */
    	DELETE FROM new_emps 
     	WHERE employee_id = :OLD.employee_id;

    	/* NEW_DEPTS���� �ش� �μ� tot_dept_sal �ڵ����� */
      UPDATE new_depts
     	SET  tot_dept_sal = tot_dept_sal - :OLD.salary
     	WHERE department_id = :OLD.department_id;
      
  /* CASE #3. EMP_DETAILS���� �޿� ����(:NEW. & :OLD.) */     
  ELSIF UPDATING ('salary')  THEN
    	
      /* NEW : SALARY | OLD : EMP_ID(����� ����) */
      UPDATE new_emps
 	    SET  salary = :NEW.salary
     	WHERE employee_id = :OLD.employee_id;
    	
      /* NEW : ������ SALARY | OLD : ������ SALARY, DEPT_ID(����� ����) */
	    UPDATE new_depts
 	    SET  tot_dept_sal = tot_dept_sal + (:NEW.salary - :OLD.salary)
     	WHERE department_id = :OLD.department_id;

  /* CASE #4. EMP_DETAILS���� �μ����� */
  ELSIF UPDATING ('department_id')  THEN
      
      /* NEW : ������ DEPT_ID | OLD : EMP_ID(����� ����) */
    	UPDATE new_emps
 	    SET department_id = :NEW.department_id
     	WHERE employee_id = :OLD.employee_id;
    	
      /* NEW_DEPTS ���� �μ� ���ձ޿��� -, �� �μ� ���ձ޿��� + */
	    UPDATE new_depts	
      SET  tot_dept_sal = tot_dept_sal - :OLD.salary
     	WHERE department_id = :OLD.department_id;
    	
	    UPDATE new_depts	
 	    SET tot_dept_sal = tot_dept_sal + :NEW.salary
     	WHERE department_id = :NEW.department_id;
  END IF;    
END;
/
/* Ʈ���� ���ο����� rollback, commit ����ϸ� �ȵ�(�ܺα��� ���� ��ħ) 
   PRAGMA_AUTONOMOUS_TRANSACTION ���� ��밡�� */

<<�׽�Ʈ>>
select * from new_emps;
select * from new_depts;

/* CASE #1. EMP_DETAILS���� �߰�(:NEW.) */ 
INSERT INTO emp_details (employee_id, last_name, salary, department_id, email, job_id) 
VALUES (9001,'ABBOTT',1000,10,'abbott.mail','HR_MAN');
     --> new_emps : insert & new_depts : update
     --> �̰� ������ transaction ������ �ؾ���

/* CASE #2. EMP_DETAILS���� ����(:OLD.) */
delete from emp_details 
where employee_id = 9001;

/* CASE #3. EMP_DETAILS���� �޿� ����(:NEW. & :OLD.) */ 
update emp_details 
set salary = salary * 1.1 
where department_id = 10;

/* CASE #4. EMP_DETAILS���� �μ����� */
update emp_details
set department_id = 50
where employee_id = 9001;

select * from new_emps;
select * from new_depts;

rollback;

--------------------------------------------------------------------------------

/* TRIGGER_AUTONOMOUS */

/* TEST�� ���̺� */                                  
create table trigger_tab (id number, name char(10), day timestamp default systimestamp);


/* �αױ�� ���� ���̺� */
create table trigger_log(id number, name char(10), log_day timestamp default systimestamp);


/* CASE #1. ������ �αױ�� ���ܾ� �Ѵٸ� */

CREATE OR REPLACE TRIGGER trigger_log
    AFTER INSERT OR UPDATE OR DELETE ON trigger_tab FOR EACH ROW
DECLARE
       PRAGMA AUTONOMOUS_TRANSACTION; /* transaction �и� */
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

/* �αױ�� ���̺��� rollback�� ���� �� ���� �� Ȯ�� */
select * from trigger_log;

        ID NAME                 LOG_DAY
---------- -------------------- ------------------------------
         1 HR                   14/10/17 11:38:27.607000


/* CASE #2. commit�� �αױ�ϸ� ������� */

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