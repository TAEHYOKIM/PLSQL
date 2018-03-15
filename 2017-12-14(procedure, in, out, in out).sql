[����32] ��ü ��� ���� ���, �̸�, �޿�, �Ի���, �ٹ������� ����մϴ�.
���� �ٹ������� 13�� �̻��̰� �޿��� 10000 �̸��� ������� ���ܻ����� �߻��ϵ��� �� �� 
�޽��� ����ϰ�  ���α׷� ������ �Ϸ�� �Ŀ� �м��Ҽ��ֵ���  years ���̺� ������ �Է��� 
�ǵ��� ���α׷��� �ۼ��մϴ�. �ٹ������� �Ҽ����� ��������

SQL> create table years(id number, name varchar2(30), sal number, year number);


<ȭ�� ���>
....

201, Hartstein, 13000, 04/02/17, 12
202, Fay, 6000, 05/08/17, 10
203, Mavris, 6500, 02/06/07, 13
��� 203 �ٹ������� 13 ���̰� �޿��� 6500 �Դϴ�.
204, Baer, 10000, 02/06/07, 13
205, Higgins, 12008, 02/06/07, 13
206, Gietz, 8300, 02/06/07, 13
��� 206 �ٹ������� 13 ���̰� �޿��� 8300 �Դϴ�.

....


SQL> select * from years;


-- �ٹ����� >= 13 and �޿� < 10000
-- user-defined exception
-- subblock or 

create table years(id number, name varchar2(30), sal number, year number);

declare
     u_def_e1 exception;
     type rec_type is record(id number, lname varchar2(30), sal number, 
                             hdate date, year number);
     type tab_type is table of rec_type;
     v_tab tab_type;
begin
       select employee_id, last_name, salary, hire_date,
              trunc((months_between(sysdate,hire_date))/12)
       bulk collect into v_tab
       from employees;
       
       for i in v_tab.first..v_tab.last loop          
         dbms_output.put_line(v_tab(i).id||', '||v_tab(i).lname||
         ', '||v_tab(i).sal||', '||v_tab(i).hdate||', '||v_tab(i).year);       
    
    begin
      if v_tab(i).year >= 13 and v_tab(i).sal < 10000 then
          raise u_def_e1;
      end if; 
    exception
      when u_def_e1 then
         dbms_output.put_line('��� '||v_tab(i).id||' �ٹ������� '||v_tab(i).year||
         '���̰� �޿��� '||v_tab(i).sal||'�Դϴ�.');
         insert into years(id, name, sal, year)
         values(v_tab(i).id, v_tab(i).lname, v_tab(i).sal, v_tab(i).year);
    end;
   
      end loop;
end;
/

select * from years;
rollback;


/* ������ Ǯ�� */

SELECT employee_id,last_name, salary, hire_date, trunc(months_between(sysdate,hire_date)/12) year
FROM employees;

DECLARE
	e_raise EXCEPTION;
BEGIN
  FOR emp_rec IN (SELECT employee_id,last_name, salary, hire_date, trunc(months_between(sysdate,hire_date)/12) year
		  FROM employees) LOOP
	DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id||', '||emp_rec.last_name||', '||emp_rec.salary||', '
			     ||emp_rec.hire_date||', '||emp_rec.year);

	BEGIN
	 IF  emp_rec.year >= 13 AND emp_rec.salary < 10000 THEN
		RAISE e_raise;
         END IF;

        EXCEPTION
	  WHEN e_raise THEN
 		DBMS_OUTPUT.PUT_LINE('��� '||emp_rec.employee_id 
                                  ||' �ٹ������� '||emp_rec.year||' ���̰� �޿��� '
                                  || emp_rec.salary||' �Դϴ�.');
                insert into years(id,name,sal,year)
                values(emp_rec.employee_id,emp_rec.last_name,emp_rec.salary,emp_rec.year);
                commit;
       END;

  END LOOP;
END;
/


SQL> select * from years;


SQL> truncate table years;


BEGIN
  FOR emp_rec IN (SELECT employee_id,last_name, salary, hire_date, trunc(months_between(sysdate,hire_date)/12) year
		  FROM employees) LOOP
	DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id||', '||emp_rec.last_name||', '||emp_rec.salary||', '
			     ||emp_rec.hire_date||', '||emp_rec.year);

	
	 IF  emp_rec.year >= 13 AND emp_rec.salary < 10000 THEN
		DBMS_OUTPUT.PUT_LINE('��� '||emp_rec.employee_id 
                                  ||' �ٹ������� '||emp_rec.year||' ���̰� �޿��� '
                                  || emp_rec.salary||' �Դϴ�.');
                insert into years(id,name,sal,year)
                values(emp_rec.employee_id,emp_rec.last_name,emp_rec.salary,emp_rec.year);
                commit;
         END IF;
    
  END LOOP;
END;
/


[����33] ��ü ��� ���� ���, �̸�, �޿�, �Ի���, �ٹ������� ����մϴ�.
���� �ٹ������� 13�� �̻��̰� �޿��� 10000 �̸��� ������� �޽��� ����ϰ�  
���α׷� ������ �Ϸ�� �Ŀ� �м��Ҽ��ֵ���  years ���̺� ������ �Է��� �ǵ��� 
���α׷��� �ۼ��մϴ�. �ٹ������� �Ҽ����� ��������. 
(bulk collect into ���� �̿��ϼ���./exception �̿����);


declare
     type rec_type is record(id number, lname varchar2(30), sal number, 
                             hdate date, year number);
     type tab_type is table of rec_type index by binary_integer;
     v_tab tab_type;
begin
       select /*+ full(e) parallel(e,2) */employee_id, last_name, salary, hire_date,
              trunc((months_between(sysdate,hire_date))/12)
       bulk collect into v_tab --> bulk�� ��ҹ�ȣ 1���� ����(ũ�� 2GB), �� �̻��� �ڵ� ����¡ ó��
       from employees e;
       
       for i in v_tab.first..v_tab.last loop          
         dbms_output.put_line(v_tab(i).id||', '||v_tab(i).lname||
         ', '||v_tab(i).sal||', '||v_tab(i).hdate||', '||v_tab(i).year);       
    
         if v_tab(i).year >= 13 and v_tab(i).sal < 10000 then
           dbms_output.put_line('��� '||v_tab(i).id||' �ٹ������� '||v_tab(i).year||
           '���̰� �޿��� '||v_tab(i).sal||'�Դϴ�.');
           insert into years(id, name, sal, year)
           values(v_tab(i).id, v_tab(i).lname, v_tab(i).sal, v_tab(i).year);
         end if; 
      end loop;
end;
/

select * from years;
rollback;

/*
# bulk collect into �� ������ ������ �ε��ϸ� 20�ﰳ(2G��) �����ۿ� �ȵǹǷ� ������ 
  �ɰ��� ó���ؾ� ��(��Ʈ: rownum)
  ��뷮�̸� full paralled ��Ʈ /*+ full(e) parallel(e.2n) */ -- n����


================================================================================

/* �����ȣ�� �Է°����� �޾Ƽ� �� ��� ������ ����ϴ� ���α׷� */


select * from employees where employee_id = �Էº���;  --> �Ͻ��� Ŀ��
select * from employees where department_id = 20;     --> ����� Ŀ��

/* �͸�� ���� : �Էº��� ó���ϴ� ��� ����? */

var b_id number
exec :b_id := 500 --> ���ε庯���� ���� ���ӵǴ� ������ ����

declare
   v_rec employees%rowtype;  
begin
   select * 
   into v_rec
   from employees where employee_id = :b_id;
      dbms_output.put_line(v_rec.last_name||v_rec.first_name);
exception
   when no_data_found then
      dbms_output.put_line(:b_id||' ����� �����ϴ�.');
end;
/
/* �� ���α׷��� ���� ���� �ִ°� ����, ���������� ����
shared pool meemory - library cache �� ���๮ ����(����� ���, ������ ������ �ؾ���) 
�͸�� ������ �Ź� ������ �� ���� ������ �ؾߵǴ� ������ ����
(��쿡 ���� ���� ����ϸ� �޸𸮿� ������ ������� ������ LRU�� ������) 
�׷��� ������Ʈ ������ �����ϸ� ������ �����ǹǷ� �ӵ��� ������(����Ŭ DB �ȿ� �����ϴ� �۾�) */

--------------------------------------------------------------------------------
/* PROCEDURE */

/*create : �ʼ�, replace : �����ȵ�(drop-create������)*/
create or replace procedure emp_proc(p_id in number) --> p_id : ���� �Ű�����(������ ���� �ȵ�)
is                         /* in : �Է°� ó���ϴ� ���(�⺻��), ���ó��, �Լ��� ���� �̸�� */
   v_rec employees%rowtype;  
begin
   select * 
   into v_rec
   from employees where employee_id = p_id;
      dbms_output.put_line(v_rec.last_name||v_rec.first_name);
exception
   when no_data_found then
      dbms_output.put_line(p_id||' ����� �����ϴ�.');
end;
/

/* ���ε� ��� �Ұ� */
show error 
--> ���� Ȯ��

/* ȣ���Ѵ�(������ ���Ѵ�), �ҽ��ڵ�� ����(������ ����), ������ �����ϸ� 
   �ڵ尪(P-CODE(parse code), M-CODE(machine code)���� ���� */
exec emp_proc(100)
exec emp_proc(103)
exec emp_proc(200)
exec emp_proc(300)

/*
replace �ɼ�: drop�ϰ� create�ϴ� ����
emp_proc(p_id in number) ��ȣ �ȿ� �ִ� ��: ���� �Ű�����. ������ ���� �ȵ�. Ÿ�Ը�.
(parameter �� �̿��� cursor ���� ���� ��������) in ���� ���� �ʾƵ� �⺻. �Է°� ó���ϴ� ���.
���� ���� �� Ȯ���Ϸ��� show error
bind ������ procedure���� �� �� ����(�Լ��� ��Ű�������� �� ��). ���ε� ���� �ڸ��� ���� �Ű������� �޲���.


�͸��ϱ���   			     <-> 		    ������ ���� ���α׷�
������ ������ �ҽ� ����.			        �ҽ��ڵ� �����.
						                      ������ �����ϸ� (m-code; p-code)�� ����
						                      ����� ������ ���ϰ� p-code �� ������ ����.
*/

================================================================================
/* ����¡ ó�� */

-- ex) �޿��� ���� ���� �޴� ��� 10�� �̾ƶ�

/* �߸��� ��� */
select rownum, last_name, salary /*rownum : fetch��ȣ*/
from employees
where rownum <= 10 --> ���ø� �� ȿ���� �߸����
order by salary desc;

/* �� ������� : rownum �̿��� paging ó�� */
select *
from (select rownum no, e.last_name, e.salary
      from (select last_name, salary
            from employees
            order by salary desc) e
      where rownum <= 10 --> �� fetch ��ȣ(����¡ ó�� �غ��� ����Ŭ~)
      )
where no >= 1;


select *
from (select rownum no, e.last_name, e.salary
      from (select last_name, salary
            from employees
            order by salary desc) e
      where rownum <= 50 --> �� fetch ��ȣ(����¡ ó�� �غ��� ����Ŭ~)
      )
where no >= 10; --> ���� fetch ��ȣ


select *
from (select rownum no, e.last_name, e.salary
      from (select last_name, salary
            from employees
            order by salary desc) e
      where rownum <= 107 --> �� fetch ��ȣ (������ ǥ���ϸ� count()�� ���)
      )
where no >= 51; --> ���� fetch ��ȣ


================================================================================

[����34] �����ȣ�� �Է°����� �޾Ƽ� �� ����� �޿��� 10% �λ��ϴ� ���ν����� �����ϼ���.
        ���ν��� �̸��� raise_sal�� ����
        
        
create or replace procedure raise_sal(p_id number) --> �����ȣ
is --> is ������ ���
begin
   update employees
   set salary = salary * 1.1
   where employee_id = p_id;
   if sql%found then
     dbms_output.put_line('�޿� 10% �̻� ������');
   else 
     dbms_output.put_line('�����ȣ �ٽ� �����ÿ�');
   end if;
end;
/

exec raise_sal(100)
/* # �ٸ����α׷����� ���ν��� ȣ��� �Ʒ��� ���� ���(�Լ��� �ٸ� := ��� �ȵ�)
begin
     raise_sal(103);
end;
/
*/
rollback; --> �� ���α׷��� ȣ�� ���α׷����� ȣ���ڰ� rollback commit ���ϵ��� ��

--------------------------------------------------------------------------------

/* �ҽ��ڵ� ���� ���� �� : �����ֿ� �ҽ� ��ȣȭ ���*/
select text
from user_source
where name = 'RAISE_SAL'
order by line;


================================================================================

[����35] �����ȣ, �λ� %�� �Է°����� �޾Ƽ� �� ����� �޿��� �λ��ϴ� ���ν����� �����ϼ���.
        ���ν��� �̸��� raise_sal_per�� ����

exec raise_sal_per(100,10) 
exec raise_sal_per(200,20)

create or replace procedure raise_sal_per(p_id number, p_per number)
is
begin
   update employees
   set salary = salary * (1 + p_per/100)
   where employee_id = p_id;
   if sql%found then
     dbms_output.put_line(p_id||'���, �޿� '||p_per||'% �̻� ������');
   else 
     dbms_output.put_line('�����ȣ �ٽ� �����ÿ�');
   end if;
end;
/
/* ���� */
select text
from user_source
where name = 'RAISE_SAL_PER'
order by line;

exec raise_sal_per(100,10) 
exec raise_sal_per(200,20)
select salary from employees where employee_id = 100;
select salary from employees where employee_id = 200;
rollback;

============================================================================

/* �����ϰ� ������ */

create or replace procedure emp_query
(p_id in number, p_name out varchar2, p_sal out number)
is
begin
     /*p_id := 200; 
      ����� �۵��ϱ� ������ ���α׷� ���ο��� ��ü �Ұ�(��ó�� �ۼ� �ȵ�)
      out���� ����ó�� ��밡��
       */ 
     select last_name, salary 
     into p_name, p_sal
     from employees
     where employee_id = p_id;

end emp_query;
/
/* ���� �Ű����� Ȯ�� */
desc emp_query;

/* out��� �ڸ����� ���� �޾��� ������ ��ġ��Ų�� */
var b_name varchar2(30)
var b_sal number
exec emp_query(100,:b_name,:b_sal)
print :b_sal :b_name

declare
      v_name varchar2(30);
      v_sal number;
begin
      emp_query(100,v_name,v_sal);
      dbms_output.put_line(v_name||' '||v_sal);
end;
/

declare
     v_id number := 200;
     v_name varchar2(30);
     v_sal number;
begin
     emp_query(v_id, v_name, v_sal);
     dbms_output.put_line(v_name||' '||v_sal);
end;
/

/* in out : �Է°� ����� ȥ�յǾ ������ ������*/
create or replace procedure format_phone
(p_phone_no in out varchar2) --> ���ĸŰ�����
is
begin
     p_phone_no := substr(p_phone_no, 1, 3) ||'-'||substr(p_phone_no, 4, 4)
                   ||'-'||substr(p_phone_no, 8);
end;
/

var b_phone varchar2(30)
exec :b_phone := '01012345678'

exec format_phone(:b_phone) --> �����Ű�����(�ʱⰪ ����ִ� ����)

print :b_phone

010-1234-5678

================================================================================
/* ��������
# �͸� ���                                       
- �̸��� ���� PL/SQL ����                          
- �Ź� ����� ������ �Ѵ�(�޸𸮿� ������)                                                  
- �����ͺ��̽��� ���� �� ��                         
- �ٸ� ���α׷����� ȣ�� �Ұ�                        
- �Է�ó��, return �� ó�� (X)                      
  (tool���� �����ϴ� ���ε庯�� ���)
  
# �������α׷�(���ν���, �Լ�)
- �̸��� �ִ� PL/SQL ����
- �ѹ��� ������ �Ѵ�(parse�� �ڵ� DBMS����, �޸𸮿� ��� �÷��� �ٷ� ���)
- �����ͺ��̽��� ������
- �ٸ� ���α׷����� ȣ�� ����
- �Է�ó��, return �� ó�� (O)  
  
mode --> ���ĸŰ������� �ɼ� �ʿ������ ���ص� ��
in : �Է°�(ȣ���ڰ� ���α׷����� ���� �ִ´�), ����� ����
out : ���ϰ�(���α׷����� ȣ���ڿ��� ���� �����Ѵ�), ������ ����
in out : �Է°��� ���ϰ��� �����Ѵ�. �ʱⰪ�� �ִ� ������ ����

              in             out       in out
ȣ����     ��, �ʱⰪ�ִ� ����
���ν���       

*/

drop procedure emp_proc;
