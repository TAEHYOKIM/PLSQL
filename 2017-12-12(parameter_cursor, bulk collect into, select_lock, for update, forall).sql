[����27] ����� last_name ���� �Է� �޾Ƽ� �� ����� employee_id, last_name, department_name ����ϰ� 
������ ���� last_name�� �Է� �Ұ�쿡��  "Hong �̶�� ����� �������� �ʽ��ϴ�."  ��� �ϴ� ���α׷��� ���弼��. 
�� ������� Ŀ�� FOR���� �̿��ϼ���.

SQL> execute :b_name := 'king'

Employee Id = 156 Name = King Department Name = Sales
Employee Id = 100 Name = King Department Name = Executive
King �̶�� ����� 2 �� �Դϴ�.


SQL> execute :b_name := 'hong'

Hong �̶�� ����� �������� �ʽ��ϴ�.

select employee_id, last_name, department_name
from employees e, departments d
where e.department_id = d.department_id
and e.last_name = 'King';

var b_name varchar2(30)
exec :b_name := 'king'
exec :b_name := 'hong'

declare
    cursor emp_cur is
      select employee_id, last_name, department_name
      from employees e, departments d
      where e.department_id = d.department_id
      and e.last_name = initcap(:b_name);
    v_c number := 0;
begin
    for v_rec in emp_cur loop
      dbms_output.put_line('Employee Id = ' || v_rec.employee_id 
                           ||' Name = ' || v_rec.last_name 
		                       ||'Department Name = '||v_rec.department_name);
      v_c := emp_cur%rowcount;  
       --> �ٽ� : for loop���� ������ ����� Ŀ�� close �Ǳ⶧���� ���⿡�� %rowcount �Ӽ��� ���
    end loop;
    if v_c = 0 then
      dbms_output.put_line(initcap(:b_name)||' �̶�� ����� �������� �ʽ��ϴ�.'); --> ����� ������
    else 
      dbms_output.put_line(initcap(:b_name)||' �̶�� ����� '||v_c||'�� �Դϴ�.');
    end if;
end;
/


================================================================================

-- parameter�� ���� cursor : ������ �����ȹ�� �����ϱ� ����

/* 
�����ȹ�� ��� ���� �и��ؾ� ���� �Ǵ��ؾ���(���� �������� ������� ū���� �ٷ� ����
active set �޶�� ��!! ������ ������ index, ������ ũ�� full�� ȿ����)
*/
declare
  cursor parm_cur_80 is
       select employee_id, last_name, job_id
       from employees
       where department_id = 80
       and job_id = 'SA_MAN';
       
  cursor parm_cur_50 is
       select employee_id, last_name, job_id
       from employees
       where department_id = 50
       and job_id = 'ST_MAN';
       
  v_rec1 parm_cur_80%rowtype;
  
begin
  open parm_cur_80;
  loop
       fetch parm_cur_80 into v_rec1;
       exit when parm_cur_80%notfound;
           dbms_output.put_line('Emp Name1 : '||v_rec1.last_name);
  end loop;
  close parm_cur_80;
  
  for v_rec2 in parm_cur_50 loop
    dbms_output.put_line('Emp Name2 : '||v_rec2.last_name);
  end loop;
end;
/
/*
������: cursor 2�� �����, �����ȹ�� 2�� ����
�ذ�: ���ε庯�� ó��, �Էº��� ó��. �Ķ���� ���� Ŀ�� �����
parameter�� ���� Ŀ���� ����: �����ȹ�� �����ϱ� ���ؼ�.
(�����ȹ sharing ���� ���ƾ� �ϴ� ���: 
 - key���� �ε��� �ɷ��ְ�, 
 - key���� ���� ���� �������� �ұյ��ϰ� ����ִ� ���, 
 - �μ� ���� ���� � ��쿡�� rowid scan�� ����, � ���� full table scan�� ���� ���� ����. 
 - �̷� ��� �ǵ������� hard parsing �� �����ؾ� ��. �Ǽ��� ī���� �غ��� ��. �̰� Ʃ����.)
*/

--------------------------------------------------------------------------------

/* �� �������(Ʃ��) */

declare
  cursor parm_cur(p_id number, p_job varchar2) is --> ���ĸŰ����� : Ÿ�Ը� �ۼ�, ������ X
       select employee_id, last_name, job_id
       from employees
       where department_id = p_id
       and job_id = p_job;
       
  v_rec1 parm_cur%rowtype; --> record ��������
  
begin
  open parm_cur(80,'SA_MAN'); --> �����Ű����� : ���ĸŰ����� Ÿ�Լ����� ��ġ�ǰ� ����(���ε� ������ ����)
  loop
       fetch parm_cur into v_rec1; --> loop 1 ȸ���� 1 row�� fetch ��Ŵ
       exit when parm_cur%notfound;
           dbms_output.put_line('Emp Name1 : '||v_rec1.last_name);
  end loop;
  close parm_cur;
  
  for v_rec2 in parm_cur(50,'ST_MAN') loop
    dbms_output.put_line('Emp Name2 : '||v_rec2.last_name);
  end loop;
end;
/

-- ��ȸ�� lock �ɱ�(select - for update)

/* �߸��� ���� */
declare
     cursor sal_cur is
            select e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20;
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where last_name = emp_rec.last_name; --> ������(���������̸� ��¥��?)
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------

/* �� ��������(by index rowid) */
declare
     cursor sal_cur is
            select e.employee_id, e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20;
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where employee_id = emp_rec.employee_id;  --> by index rowid scan�� ����
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------

/* �� ��������(by user rowid) : ���������� I/O */
declare
     cursor sal_cur is
            select e.rowid, e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20;
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where rowid = emp_rec.rowid;  --> �ش� row���� lock
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------

/* for update : DML ���� */
declare
     cursor sal_cur is
            select e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20
            for update; --> �̸� lock(cursor open��), rowid ������ ���� 
                        --> 20�� �μ� ��� row ��ü �� 20�� �μ� dept ���̺� row�� lock
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where current of sal_cur; 
         --> rowid = emp_rec.rowid; (update or delete��� / insert�� where���� ��� �ȵ�)
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------
/* for update of ���(3����) */

declare
  ��������������
for update of e.last_name; 
/* 
lock ����(������ �ǹ� : �� �÷��� �ִ� ���̺��� row�� ����)
�̷��� �ϸ� ���εǴ� dept ���̺��� lock �Ȱɸ��� emp ���̺� �ɸ�
(�ٵ� ���̺�� �ƴϰ� �÷��� �ƹ��ų� ��. select ���� �ֵ� ���� �������. 
�� �÷��� �ִ� ���̺��� row�� ���ؼ� lock�� �ɸ�.)
*/

declare
  ��������������
for update of e.first_name wait 5;	
/*
���� ���� lock �ɾ���� ��� 5�ʸ� ��ٸ���, 5�� ���� lock �� Ǯ���� ����. 
�⺻���� wait, ������ ��ٸ�.
*/

declare
  ��������������
for update of e.first_name nowait;	
/* ���� ���� lock �ɾ���� ��� �� ��ٸ��� ������ �����޽��� */


/*
# ���� : lock�� Ŀ���� �����ϴ� ���� �ɸ�. ���� update �����ؾ� �ϴ� row ���� �Ϻο��� 
        ��ü lock�� �ɸ��� ������, dml ����� �Ϻ��� ��쿣 rowid�� ���� �� ����. 
        for update�� ���� ���� dml �ؾ� �� ��츸. 
*/

================================================================================

[����28] 30�� �μ� ������� �̸�, �޿�, �ٹ�������, �μ��̸��� ����ϰ� �� ����� �߿� 
        �ٹ��������� 150���� �̻��� ������� �޿��� 10%�λ��ϴ� ���α׷��� �ۼ��ϼ���.

/*
<ȭ�� ���>

����̸� : Raphaely �޿� : 11000 �ٹ������� : 172 �μ� �̸� :  Purchasing
Raphaely 10%�λ� �޿��� �����߽��ϴ�.
����̸� : Khoo �޿� : 3100 �ٹ������� : 167 �μ� �̸� :  Purchasing
Khoo 10%�λ� �޿��� �����߽��ϴ�.
����̸� : Baida �޿� : 2900 �ٹ������� : 136 �μ� �̸� :  Purchasing
����̸� : Tobias �޿� : 2800 �ٹ������� : 141 �μ� �̸� :  Purchasing
����̸� : Himuro �޿� : 2600 �ٹ������� : 125 �μ� �̸� :  Purchasing
����̸� : Colmenares �޿� : 2500 �ٹ������� : 116 �μ� �̸� :  Purchasing
*/


select e.last_name, 
       e.salary, 
       trunc(months_between(sysdate,e.hire_date)), 
       d.department_name
from employees e, departments d
where e.department_id = 30
and d.department_id = 30; --> ī�׽þ� ������ ������ ���� 1�� : M�� �̾ ��������


declare
  cursor v_cur is
    select e.rowid,
       e.last_name, 
       e.salary, 
       trunc(months_between(sysdate,e.hire_date)) hdate, 
       d.department_name
    from employees e, departments d
    where e.department_id = 30
    and d.department_id = 30;  
begin
  for v_rec in v_cur loop
      dbms_output.put_line('����̸� : '||v_rec.last_name||' �޿� : '||v_rec.salary||
      '�ٹ������� : '||v_rec.hdate||' �μ� �̸� : '||v_rec.department_name);
      
      if v_rec.hdate >= 150 then
           update employees
           set salary = salary * 1.1
           where rowid = v_rec.rowid;
           dbms_output.put_line(v_rec.last_name||' 10%�λ� �޿��� �����߽��ϴ�.');
      end if;
      
  end loop;
  rollback;
end;
/

================================================================================

declare
     cursor emp_cur is
         select * from employees where department_id = 20;
     v_rec emp_cur%rowtype;
begin
     open emp_cur;
     fetch emp_cur into v_rec;
          dbms_output.put_line(v_rec.last_name);
     fetch emp_cur into v_rec;
          dbms_output.put_line(v_rec.last_name);          
     close emp_cur;
end;
/
/* NOTE
   fetch������ active set ��ŭ(���⼭ 2��) �ǽ��ؾ� ��. ���� active set�� ��������
   �����?? �׷� loop�� ������ �ذ�����(�Ʒ���) */
--------------------------------------------------------------------------------

declare
     cursor emp_cur is
         select * from employees where department_id = 20;
     v_rec emp_cur%rowtype;
begin
     open emp_cur; 
     loop
       fetch emp_cur into v_rec;
           exit when emp_cur%notfound;
           dbms_output.put_line(v_rec.last_name);
     end loop;
     close emp_cur;
end;
/
/* NOTE
   loop�� �ϴϱ� �Ѱ� ���ϱ�! �׷��� �������� �� ���� ���ɿ� ���� �ִٰ� �ϽŴ�.(�Ʒ���) */
--------------------------------------------------------------------------------
/* ������ �� : 
����� Ŀ���� declare, open, fetch, close�� ������ �ְ� �Ǵµ� 
�� �� fetch�� active set ��� ��ŭ �ؾ� ��
compile engine(virtual machine)�� sql����, plsql���� �� 2����
�� ������ plsql���̹Ƿ� ó���� plsql������ �޾� compile�ϴµ� �� �ȿ� �ִ� 
select���� plsql������ ó�� ���ؼ� sql������ ó���ϵ��� ��û. 
sql������ parse, bind, execute, fetch. ������ plsql���� ������ 
���� Ŀ�� ���� sql���� �����ϴ� ��ü�� sql����. �׷��� ������ plsql��
sql������ plsql���� ���̿� ���� ��ȯ�� �߻�(����� Ŀ������ fetch���� ���ư� ��). 
�����Ͱ� ���������� ������ȯ ���� �߻�(active set �����ŭ). 
������ȯ�� 1������ �������� ��� �ϸ� �ɱ�?
*/
--------------------------------------------------------------------------------
/* bulk collect into : 10g����
- active set ����� ������ �ѹ��� �ε�(fetch ������ȯ 1���� ����)
- ����� Ŀ���� ������ �ʿ䵵 ����, open/fetch/close �� �ʿ䵵 ����
*/

/* nested table style */
declare
    type tab_type is table of employees%rowtype; --> record Ÿ��, arr Ÿ��
    v_tab tab_type; --> v_tab : 2���� �迭
begin
    select * 
    bulk collect into v_tab
    from employees
    where department_id = 20;
       dbms_output.put_line(sql%rowcount);
    for i in v_tab.first..v_tab.last loop
       dbms_output.put_line(v_tab(i).last_name);
    end loop;
end;
/

/* ���� ����� Ŀ�������� �̸��� ��� �Ӽ��� �̿����� ����(�Ʒ� ��������) */
declare
     cursor emp_cur is
         select * from employees where department_id = 20;
     type tab_type is table of emp_cur%rowtype;
     v_arr2 tab_type;
begin
     open emp_cur; 
     fetch emp_cur bulk collect into v_arr2;
       for i in v_arr2.first..v_arr2.last loop
           dbms_output.put_line(v_arr2(i).last_name);
       end loop;
     close emp_cur;
end;
/

================================================================================

drop table emp purge;

create table emp as select * from employees;


begin
     delete from emp where department_id = 10;
     delete from emp where department_id = 20;
     delete from emp where department_id = 30;
end;
/
/* NOTE �����ȹ 1���� �� �� ������? (�Ʒ���) */
--------------------------------------------------------------------------------

/* �׳� loop */
declare 
    num number := 10;
begin 
    loop
     exit when num > 30;
     delete from emp where department_id = num;
     dbms_output.put_line(sql%rowcount || ' rows deleted');
     num := num + 10;
    end loop;
end;
/

--------------------------------------------------------------------------------
declare
    type num_list is table of number;
    v_num num_list := num_list(10,20,30);
begin
      delete from emp where department_id = v_num(1); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');
      delete from emp where department_id = v_num(2); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');
      delete from emp where department_id = v_num(3); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');      
end;
/
/* NOTE �����ȹ�� 1���� �ۼ�, �ڵ��ۼ� 1���� �Ϸ���? (�Ʒ���)*/
--------------------------------------------------------------------------------

declare
    type num_list is table of number;
    v_num num_list := num_list(10,20,30);
begin
    for i in v_num.first..v_num.last loop
      delete from emp where department_id = v_num(i); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');
    end loop;
end;
/
/* NOTE ���� �����ϰ� ������ȯ�� 3�� �߻��� */

--------------------------------------------------------------------------------

/* forall��(loop �ƴ�) */
declare
    type num_list is table of number;
    v_num num_list := num_list(10,20,30);
begin
    forall i in v_num.first..v_num.last 
    --> forall : DML���� ����(ȥ��ȵ�), �迭�ȿ� �ִ� �����ؼ� �Ҳ���(������ȯ ���Ҹ� ���� �Ѳ����� sql�� sql�������� ����)
        delete from emp where department_id = v_num(i);
    for i in v_num.first..v_num.last loop
        dbms_output.put_line(sql%bulk_rowcount(i) || ' rows deleted');
    --> sql%bulk_rowcount(i) ���ο� �Ӽ�(forall ����)
    end loop;
    rollback;
end;
/
/* NOTE ������ȯ�� 1���� �߻��� */

--------------------------------------------------------------------------------

declare
    type num_list is table of number;
    v_num num_list := num_list(10,11,12,6,20,50,5,30,40,7); 
     --> �μ��� 0�� �־ �����ϸ� �������� dml�۾��� ���� �ڵ��ѹ�
begin
    forall i in v_num.first..v_num.last 
        delete from emp where salary > 500000/v_num(i);
    for i in v_num.first..v_num.last loop
        dbms_output.put_line(sql%bulk_rowcount(i) || ' rows deleted');
    end loop;
    rollback;
end;
/