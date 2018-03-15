<����5> �μ����̺� �ű� �μ��� �Է��ϴ� ���α׷��� �ۼ��Ϸ��� �մϴ�.
       �μ� �̸��� �Է°����� �ް� �μ��ڵ�� ������ �μ� �ڵ忡 10�� �����ؼ� �μ��ڵ带
       �ְ� �����ڹ�ȣ, �μ� ��ġ�� null������ �Է��ϴ� ���α׷��� �ۼ��ϼ���.
       ȭ����� ó�� ����ϼ���.(dept ���̺��� �������� ���α׷��� ���弼��) 


<ȭ�����>

�ű� �μ� ��ȣ�� 280, �μ� �̸� It �Դϴ�.


drop table dept purge;

create table dept as select * from departments;

select * from dept;

desc dept;

var b_dept_name varchar2(30)
exec :b_dept_name := 'It'
print :b_dept_name

declare
      v_dept_id dept.department_id%type;
      v_mgr_id dept.manager_id%type;
      v_loc_id dept.location_id%type;
begin
      select max(department_id)
      into v_dept_id
      from dept;
      v_dept_id := v_dept_id + 10;
      insert into dept
      values(v_dept_id, :b_dept_name, v_mgr_id, v_loc_id);
      dbms_output.put_line('�ű� �μ� ��ȣ�� '||v_dept_id||', �μ� �̸� '||:b_dept_name||'�Դϴ�.');
      commit;
end;
/

select * from dept;

/* bind������ �̿��ؾ��� ���α׷� 1���� ���� �� �ִ�. */

[����6]�����ȣ�� �Է°����� �޾Ƽ� �� ����� �޿��� 10%�λ��ϴ� ���α׷��� �����ϼ���.
      ȭ���� ��µǴ� ����� ���� �� ���ް� ���� �� ������ �Ʒ��� ���� ��� �� transaction�� rollback �ϼ���.


var b_id number
execute :b_id := 100
print :b_id

���� �� ���� : 24000
���� �� ���� : 26400


drop table emp purge;
create table emp as select * from employees;

declare
       v_sal emp.salary%type;
begin
       select salary
       into v_sal
       from emp
       where employee_id = :b_id;
       
       dbms_output.put_line('���� �� ���� : '||v_sal);
       
       v_sal := v_sal * 1.10;
       
       update emp
       set salary = v_sal;
       dbms_output.put_line('���� �� ���� : '||v_sal);
       rollback;
end;
/

/* returning : Ʃ��(update + select ���) */

declare
       v_sal emp.salary%type;
       v_name emp.last_name%type;
begin
       select salary
       into v_sal
       from emp
       where employee_id = :b_id; 
       
       dbms_output.put_line('���� �� ���� : '||v_sal);
       
       update emp
       set salary = salary * 1.1
       where employee_id = :b_id
       returning last_name, salary into v_name, v_sal;
       
       dbms_output.put_line(v_name||'���� �� ���� : '||v_sal);
       
       rollback;
end;
/       

[����7] �����ȣ�� �Է°����� �޾Ƽ� �� ����� �����ϴ� ���α׷��� �����ϼ���.
ȭ���� ��µǴ� ����� �Ʒ��� ���� ��� �� transaction�� rollback �ϼ���.
(emp ���̺� ����ϼ���.)

<ȭ�����>

������ ����� ��� ��ȣ�� 100 �̰�  ����� �̸��� King �Դϴ�.

var b_id number
execute :b_id := 100

declare
       v_name emp.last_name%type;
begin
       delete from emp
       where employee_id = :b_id
       returning last_name into v_name; --> delete�� ���� �������� �� fetch

       dbms_output.put_line('������ ����� ��� ��ȣ�� '||:b_id||
       ' �̰�  ����� �̸��� '||v_name||' �Դϴ�.');       
       rollback;
end;
/

[����8] �μ��ڵ带 �Է°����� �޾Ƽ� �� �μ��� �ٹ��ϴ� ����� �ο����� ����Ͻð� 
        �� �μ� ������� �޿��߿� 10000 �̸��� ����� 10% �λ��� �޿��� �����ϴ� ���α׷��� �ۼ��ϼ���.
        ȭ������� �� rollback �ϼ���.(emp ���̺� ����ϼ���)


<ȭ�����>

20 �μ��� �ο�����  2�� �Դϴ�.
20 �μ��� ������ ROW�� ���� 1 �Դϴ�.

desc emp;
var b_id number
execute :b_id := 20

declare
       v_cnt emp.employee_id%type; --> �׳� number�� �ϴ°� ���ƺ���
begin
       select count(*)
       into v_cnt
       from emp
       where department_id = :b_id;
       dbms_output.put_line(:b_id||' �μ��� �ο����� '||v_cnt||'�� �Դϴ�.');
       
       update emp
       set salary = salary * 1.10
       where salary < 10000
       and department_id = :b_id;
       dbms_output.put_line(:b_id||' �μ��� ������ ROW�� ���� '||sql%rowcount||' �Դϴ�.');
       
       rollback;
end;
/


================================================================================

/* ������� */

-- if��

IF ���� THEN
  ����
ELSIF ���� THEN --> elsif : �ɼ�
  ����
ELSIF ���� THEN
  ����
ELSE
  �⺻��
END IF;

[����9] ���̿� ���� ����, ���, û�ҳ�, ���� ����Ͻÿ�
���� : 1�� �̻� 6�� �̸�
��� : 6�� �̻� 13�� �̸�
û�ҳ� : 13�� �̻� 19�� �̸�
���� : 19�� �̻�

declare
     v_myage number := 19;
begin
     if v_myage >= 1 and v_myage < 6 then
            dbms_output.put_line('����');     
     elsif v_myage >= 6 and v_myage < 13 then
            dbms_output.put_line('���');
     elsif v_myage >= 13 and v_myage < 19 then
            dbms_output.put_line('û�ҳ�');
     else   dbms_output.put_line('����');
     end if;
end;
/

[����10] ���ڸ� �Է°� �޾Ƽ� ¦�� ���� Ȧ�� ������ ����ϴ� ���α׷��� �ۼ��ϼ���.

var v_a number
execute :v_a := 7

Ȧ���Դϴ�.


var v_num number
exec :v_num := 7

begin
    if mod(:v_num,2) = 0 then
       dbms_output.put_line('¦���Դϴ�');
    else 
       dbms_output.put_line('Ȧ���Դϴ�');       
    end if;
end;
/

[����11]�ΰ��� ���ڸ� �Է��ؼ� �ش� ������ ���̰��� ����ϼ���.
���ڸ� ��� �Է��ϴ� ū ���ڿ��� ���� ���ڸ� ���� if ���� �����ϼ���.

var v_a number
var v_b number
execute :v_a := 10
execute :v_b := 7

print v_a v_b

declare
     v_c number;
begin
     if :v_a < :v_b then
        v_c := :v_b - :v_a;
        dbms_output.put_line('���̰� : '||v_c);
     elsif :v_a > :v_b then
        v_c := :v_a - :v_b;
        dbms_output.put_line('���̰� : '||v_c);
     else 
        dbms_output.put_line('���̰� : 0');  
     end if;
end;
/

declare
     v_c number;
begin
     if :v_a <= :v_b then
        v_c := :v_b - :v_a;
        dbms_output.put_line('���̰� : '||v_c);
     elsif :v_a > :v_b then
        v_c := :v_a - :v_b;
        dbms_output.put_line('���̰� : '||v_c);
     end if;
end;
/

[����12] �����ȣ�� �Է°����� �޾Ƽ� �� ����� �ٹ��������� ����ϰ� �ٹ���������
150���� �̻��̸� �޿��� 20% �λ��� �޿��� ����, 
149���� ���� �۰ų� ���� 100���� ���� ũ�ų� ������  10%�λ��� �޿��� ����,
100���� �̸��� �ٹ��ڴ� �ƹ� �۾��� �������� �ʴ� ���α׷��� �ۼ��ϼ���.
�׽�Ʈ�� ������ rollback �մϴ�.(emp ���̺� ���)

<ȭ�� ���>
100 ����� �ٹ��������� 154 �Դϴ�. �޿��� 20% �����Ǿ����ϴ�.

<ȭ�� ���>
166 ����� �ٹ��������� 97 �Դϴ�. 100 ���� �̸��̹Ƿ�  �޿� ���� �ȵ˴ϴ�.


-- months_between
-- if�� ���
select employee_id, hire_date, sysdate, round(months_between(sysdate, hire_date))
from emp;

var b_id number
exec :b_id := 166

declare
     v_wk number;
     v_sal emp.salary%type;
begin
     select round(months_between(sysdate, hire_date)), salary 
     into v_wk, v_sal
     from emp 
     where employee_id = :b_id;
     
     if v_wk >= 150 then
             v_sal := v_sal * 1.2;
             dbms_output.put_line(:b_id||'����� �ٹ��������� '||v_wk||'�Դϴ�. �޿��� 20% �����Ǿ����ϴ�.');
     elsif v_wk >= 100 and v_wk <= 149 then
             v_sal := v_sal * 1.1;
             dbms_output.put_line(:b_id||'����� �ٹ��������� '||v_wk||'�Դϴ�. �޿��� 10% �����Ǿ����ϴ�.');  
     else 
             dbms_output.put_line(:b_id||'����� �ٹ��������� '||v_wk||'�Դϴ�. 100���� �̸��̹Ƿ�  �޿� ���� �ȵ˴ϴ�.');
     end if; 
     
     update emp
     set salary = v_sal
     where employee_id = :b_id;
     rollback;
end;
/

================================================================================

/* case ǥ����(�Լ�) */

case ���ذ�
       when ��1 then ����1
       when ��2 then ����2
       else
            �⺻��
end

-- ��Ģ. v_a := 'a' ���ν�����(�������Լ�(decode ������) ��밡��, �׷��Լ� ���Ұ�)

var b_name varchar2(20)
begin                   
   :b_name := '����ǥ';  --> exec ����
end;
/
print :b_name


declare
      v_grade char(1) := upper('c'); --> ���ν�����
      v_appraisal varchar2(30);
begin
      v_appraisal := case v_grade
                        when 'A' then '�����߾��'
                        when 'B' then '���߾��'
                        when 'C' then '���������ؿ�'
                        else '�ϰ�����̾�!!'
                     end;
      dbms_output.put_line('�����' || v_grade ||', �򰡴�' || v_appraisal);
end;
/


declare
      v_grade char(1) := upper('d'); --> ���ν�����
      v_appraisal varchar2(30);
begin
      v_appraisal := case
                        when v_grade = 'A' then '�����߾��'
                        when v_grade in ('B','C') then '���߾��'
                        else '�ϰ�����̾�!!'
                     end;
      dbms_output.put_line('�����' || v_grade ||', �򰡴�' || v_appraisal);
end;
/

/* case������ Ǯ���� ���� 12 : then ���� sql�� ���ü� ���� */

declare
	v_mon number;
begin
	SELECT trunc(months_between(sysdate, hire_date))
	INTO v_mon
	FROM emp
	WHERE employee_id = :b_id;

	case  
	 when v_mon >= 150 then

		UPDATE emp
		SET salary = salary * 1.20
		WHERE employee_id = :b_id;

		dbms_output.put_line(:b_id||' ����� �ٹ��������� '
                                 ||v_mon||' �Դϴ�. �޿��� 20% �����Ǿ����ϴ�.');
	 when v_mon between 100 and 149 then

		UPDATE emp
		SET salary = salary * 1.10
		WHERE employee_id = :b_id;
			dbms_output.put_line(:b_id||' ����� �ٹ��������� '
                                 ||v_mon||' �Դϴ�. �޿��� 10% �����Ǿ����ϴ�.');
	 else
		
		dbms_output.put_line(:b_id||' ����� �ٹ��������� '||v_mon||' �Դϴ�. 100 ���� �̸��̹Ƿ�  �޿� ���� �ȵ˴ϴ�.');

	end case;
	
	rollback;
	
end;
/


================================================================================

/* �ݺ��� 
1. loop��
2. while��
3. for��
*/

/* �⺻ loop ���� : 1 ~ 10 ����ϱ� */
declare
     i number := 1;
begin
     loop 
        dbms_output.put_line(i);
        i := i + 1; 
        if i > 10 then
             exit; --> pl/sql������ loop ����(�⺻,while,for) �ȿ����� ����ؾ���(���ѷ��� ����)
        end if;
     end loop;
end;
/


declare
     i number := 1;
begin

     loop 
        dbms_output.put_line(i);
        i := i + 1; 
        exit when i > 10; --> ��� when ����
     end loop;
     
end;
/


/* while loop ���� */

declare 
      i number := 1;
begin
      while i <= 10 loop
              dbms_output.put_line(i);
              i := i + 1;
      end loop;
end;
/

/* for loop ���� */

begin
      for i in 1..10 loop               --> i : count ����, ������ �ʿ� ����
              dbms_output.put_line(i);   --> i := i + 1 (�Ͻ������� �̷��� ����)
      end loop;
end;
/

begin
      for i in reverse 1..10 loop         --> reverse : ��������
              dbms_output.put_line(i);  
      end loop;
end;
/
[����13]
ȭ���� ���� 1 ���� 10 ���� ����ϴ� ���α׷��� �ۼ��մϴ�. �� 4,8���� ������� ������.

<ȭ�����>
1
2
3
5
6
7
9
10

/* Ǯ��1. �⺻ loop */
declare
     i number := 1;
begin
     loop 
        dbms_output.put_line(i);
        i := i + 1; 
        if i > 3 then exit;
        end if;
     end loop;
     
      loop
        i := i + 1;
        dbms_output.put_line(i); 
        if i > 6 then exit;
        end if;
     end loop;

      loop
        i := i + 2;
        dbms_output.put_line(i);   
        i := i - 1;
        if i = 9 then exit;
        end if;
     end loop;
end;
/

/* Ǯ��2. for loop */
begin
      for i in 1..10 loop    
       if i = 4 or i = 8 then
          null;
       else  
          dbms_output.put_line(i);
       end if;   
      end loop;
end;
/


begin
     for i in 1..10 loop
         if i<> 4 and i<>8 then
          dbms_output.put_line(i);
         else
            null;
         end if;
     end loop;
end;
/

begin 
    for i in 1..10 loop
      if i <> 4 and i<> 8 then
        dbms_output.put_line(i);
      end if;
    end loop;
end;
/

/* Ǯ��3. while */

declare
      i number := 1;
begin
      while i <= 10 loop
        if i = 4 or i = 8 then
          null;
        else 
          dbms_output.put_line(i);
        end if;
          i := i + 1;
      end loop;
end;
/

/* Ǯ��4. �⺻ ���� */

declare
      i number := 1;
begin
    loop
      if i = 4 or i = 8 then
         null;
      else
         dbms_output.put_line(i);
      end if;  
      i := i + 1;
        exit when i > 10;
    end loop; 
end;
/


/* reverse */
declare 
      v_a number := 1;
      v_b number := 10;
begin
      for i in reverse v_a..v_b loop
          if i=4 or i=8 then
             null;
          else 
             dbms_output.put_line(i);
          end if;
      end loop;
end;
/


