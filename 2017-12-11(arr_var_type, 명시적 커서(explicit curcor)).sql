[����22]
�迭�����ȿ� �ִ� ��� ��ȣ ���� �������� (100,110,200) �� ����� last_name, hire_date, department_name 
������ �迭������ ��Ƴ��� �� ȭ�鿡 ����ϴ� ���α׷��� �ۼ��ϼ���.
     

<ȭ����>
100 ����� �̸��� King, �Ի��� ��¥�� 2003-06-17, �ٹ� �μ��̸��� Executive �Դϴ�.
110 ����� �̸��� Chen, �Ի��� ��¥�� 2005-09-28, �ٹ� �μ��̸��� Finance �Դϴ�.
200 ����� �̸��� Whalen, �Ի��� ��¥�� 2003-09-17, �ٹ� �μ��̸��� Administration �Դϴ�.

desc departments;

/* ��Į�� �������� */
declare
    type rec_type is record(lname varchar2(30), hdate date, dname varchar2(30));
    type tab_type is table of rec_type index by binary_integer;
    v_tab tab_type;
    
    type id_type is table of number;
    v_id id_type := id_type(100,110,200);

begin
   for i in v_id.first..v_id.last loop
    select  last_name,
            hire_date, 
           (select department_name
            from departments
            where department_id = e.department_id)
    into v_tab(i)
    from employees e
    where employee_id = v_id(i);  
   end loop;
   
   for i in v_id.first..v_id.last loop
    dbms_output.put_line(v_id(i)||' ����� �̸��� '||v_tab(i).lname||', �Ի��� ��¥�� '
    ||to_char(v_tab(i).hdate,'yyyy-mm-dd')||', �ٹ� �μ��̸��� '||v_tab(i).dname||' �Դϴ�.');
   end loop;
   
end;
/

/* ���� */
declare
    type rec_type is record(lname varchar2(30), hdate date, dname varchar2(30));
    type tab_type is table of rec_type index by binary_integer;
    v_tab tab_type;
    
    type id_type is table of number;
    v_id id_type := id_type(100,110,200);

begin
   for i in v_id.first..v_id.last loop
    select  e.last_name,
            e.hire_date, 
            d.department_name
    into v_tab(i)
    from employees e, departments d
    where e.department_id = d.department_id 
    and employee_id = v_id(i);  
   end loop;
   
   for i in v_id.first..v_id.last loop
    dbms_output.put_line(v_id(i)||' ����� �̸��� '||v_tab(i).lname||', �Ի��� ��¥�� '
    ||to_char(v_tab(i).hdate,'yyyy-mm-dd')||', �ٹ� �μ��̸��� '||v_tab(i).dname||' �Դϴ�.');
   end loop;
end;
/

================================================================================
/* ������ Ÿ�� �迭���� */

declare
      type tab_char_type is table of varchar2(30) index by pls_integer;
      v_city tab_char_type;

begin
      v_city(1) := '����';
      v_city(2) := '����';
      v_city(3) := '�λ�';
      
      dbms_output.put_line('v_city.count : '||v_city.count);  --> �迭 �� ��ü �Ǽ� ���
      dbms_output.put_line(v_city.first);  --> min
      dbms_output.put_line(v_city.last);   --> max
      dbms_output.put_line(v_city.next(1)); --> 1�� �� ���� ��ȣ��? 2
      dbms_output.put_line(v_city.prior(2)); --> 2�� �� �� ��ȣ��? 1
      v_city.delete; --> �迭�� ���� ���� �����(�ʱ�ȭ)
      v_city.delete(1);
      v_city.delete(1,2); --> 1 ~ 2�� ���� ������
      
      dbms_output.put_line(v_city.count);
      
      for i in 1..3 loop
         if v_city.exists(i) then
          dbms_output.put_line(v_city(i));
         end if;
      end loop;
end;
/


declare
      type tab_char_type is table of varchar2(30);
      v_city tab_char_type := tab_char_type('����','�λ�','����'); --> nested Ȯ���� ������(index�� �ڵ�����)
      
begin
      v_city.extend; --> 1�� Ȯ��(�⺻��)
      v_city.extend(2); --> 2�� Ȯ��
      v_city(4) := '����';  --> extend ���� ������ �����߻�
      v_city(5) := '�뱸';
      
      for i in v_city.first..v_city.last loop
          dbms_output.put_line(v_city(i));
      end loop;
      
end;
/


declare
      type tab_char_type is varray(4) of varchar2(30); --> varray �迭�� �� ����(�迭�ȿ� ���� ����� ������ ����)
      v_city tab_char_type := tab_char_type('����','�λ�','����'); --> 3�� ����� 3�� ĭ�� ����
      
begin 
      v_city.extend(2); 
      v_city(4) := '����';  --> extend ���� ������ �����߻�
      v_city(5) := '���ֵ�'; --> varrar(4)�� ���� �߰��Ұ�, varrar(5)�� ���� �����ؾ���
      for i in v_city.first..v_city.last loop
          dbms_output.put_line(v_city(i));
      end loop;
      
end;
/


[����23]�迭 ������ �ִ� 100,101,102,103,104, 200 �����ȣ�� �������� ��� �̸�, 
       �ٹ������� 150�����̻� �Ǿ����� �޿�(salary)�� 10% �λ��� �޿��� ������ �� , �λ� �� �޿�, 
       �λ� �� �޿��� ����ϴ�  ���α׷��� �ۼ��ϼ���.

��� ��ȣ : 100 ��� �̸� :  King    �ٹ������� :  166 �λ� �� �޿� : 24000 �λ� �� �޿� : 26400
��� ��ȣ : 101 ��� �̸� :  Kochhar �ٹ������� :  139 17000 �޿��� �λ��� �� �����ϴ�.
��� ��ȣ : 102 ��� �̸� :  De Haan �ٹ������� :  195 �λ� �� �޿� : 17000 �λ� �� �޿� : 18700
��� ��ȣ : 103 ��� �̸� :  Hunold  �ٹ������� :  135 9000 �޿��� �λ��� �� �����ϴ�.
��� ��ȣ : 104 ��� �̸� :  Ernst   �ٹ������� :  119 6000 �޿��� �λ��� �� �����ϴ�.
��� ��ȣ : 200 ��� �̸� :  Whalen  �ٹ������� :  163 �λ� �� �޿� : 4400 �λ� �� �޿� : 4840


declare
     type arr_type is table of number;
     v_id arr_type := arr_type(100,101,102,103,104,200);
     
     type rec_type is record(lname varchar2(30),hdate number, sal_bf number, sal_af number);
     type emp_arr_type is table of rec_type index by binary_integer;
     v_tab emp_arr_type;
     
begin
     for i in v_id.first..v_id.last loop
       select last_name, trunc(months_between(sysdate,hire_date)), salary
       into v_tab(i).lname, v_tab(i).hdate, v_tab(i).sal_bf
       from employees
       where employee_id = v_id(i);
       
       if v_tab(i).hdate >= 150 then
         v_tab(i).sal_af := v_tab(i).sal_bf * 1.1;
         update employees
         set salary = v_tab(i).sal_af
         where employee_id = v_id(i);
       end if;      
     end loop;
     
     for i in v_id.first..v_id.last loop
       if v_tab(i).sal_af is not null then
       dbms_output.put_line('��� ��ȣ : '||v_id(i)||
       '��� �̸� :  '||v_tab(i).lname||' �ٹ������� : '||v_tab(i).hdate||' �λ� �� �޿� : '
       ||v_tab(i).sal_bf||' �λ� �� �޿� : '||v_tab(i).sal_af);
       else
        dbms_output.put_line('��� ��ȣ : '||v_id(i)||'��� �̸� :  '
        ||v_tab(i).lname||' �ٹ������� : '||v_tab(i).hdate||''||v_tab(i).sal_bf
        ||' �޿��� �λ��Ҽ� �����ϴ�.');
       end if;
     end loop;
     rollback;
end;
/


/* returning ��� */

declare
     type arr_type is table of number;
     v_id arr_type := arr_type(100,101,102,103,104,200);
     
     type rec_type is record(lname varchar2(30),hdate number, sal number);
     type emp_arr_type is table of rec_type index by binary_integer;
     v_tab emp_arr_type;
     
     v_sal_af number;
begin
     for i in v_id.first..v_id.last loop
       select last_name, trunc(months_between(sysdate,hire_date)), salary
       into v_tab(i)
       from employees
       where employee_id = v_id(i);
       
       if v_tab(i).hdate >= 150 then
         update employees
         set salary = salary * 1.1
         where employee_id = v_id(i)
         returning salary into v_sal_af;
        
        dbms_output.put_line('��� ��ȣ : '||v_id(i)||
       '��� �̸� :  '||v_tab(i).lname||' �ٹ������� : '||v_tab(i).hdate||' �λ� �� �޿� : '
       ||v_tab(i).sal||' �λ� �� �޿� : '||v_sal_af);
       
       else
        dbms_output.put_line('��� ��ȣ : '||v_id(i)||'��� �̸� :  '
        ||v_tab(i).lname||' �ٹ������� : '||v_tab(i).hdate||''||v_tab(i).sal
        ||' �޿��� �λ��Ҽ� �����ϴ�.');
       
       end if;      
     end loop;
     rollback;
end;
/

/* procedure ����(2017-12-17) */
create or replace procedure emp_pro (p_id number)
is
   type rec_type is record(hdate number, sal number,
                           lname varchar2(30), id varchar2(30));
   v_rec rec_type;
   v_sal_af number;
begin
   select trunc(months_between(sysdate, hire_date)) hdate,
          salary, last_name, rowid
   into v_rec
   from employees
   where employee_id = p_id;
   
   if v_rec.hdate >= 150 then
      update employees
      set salary = salary * 1.1
      where rowid = v_rec.id
      returning salary into v_sal_af;
       dbms_output.put_line('��� ��ȣ : '||p_id||
       '��� �̸� :  '||v_rec.lname||' �ٹ������� : '||v_rec.hdate||' �λ� �� �޿� : '
       ||v_rec.sal||' �λ� �� �޿� : '||v_sal_af);
       else
        dbms_output.put_line('��� ��ȣ : '||p_id||'��� �̸� :  '
        ||v_rec.lname||' �ٹ������� : '||v_rec.hdate||' '||v_rec.sal
        ||' �޿��� �λ��Ҽ� �����ϴ�.');   
   end if;
   rollback;
exception
   when no_data_found then
      dbms_output.put_line(p_id||' ����� �����ϴ�');
end;
/
show error

select text
from user_source
where name = 'EMP_PRO'
order by line;

declare
  type arr_type is table of number;
  v_arr arr_type := arr_type(100,101,102,103,104,200);
begin
  for i in v_arr.first..v_arr.last loop
    emp_pro(v_arr(i));
  end loop;
end;
/


[����24] �迭�� 1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9 ���� �ֽ��ϴ�.
	 ã�� ������ �迭 ��ġ ���� �Ѱ��� ������ ����ϼ���.

<ȭ����>

20 ���� �迭�� 7,15 ��ġ�� ������ �� 2 �� �ֽ��ϴ�.

100 ���� �����ϴ�.

var b_num number
exec :b_num := 20

-- sql%found
/* Ư��ȭ */
declare
    type arr1_type is table of number;
    v_id_1 arr1_type := arr1_type(1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9);
    
   type arr2_type is table of number index by binary_integer;
    v_id_2 arr2_type;
    
    v_cn number := 0;
begin
    for i in v_id_1.first..v_id_1.last loop
      if v_id_1(i) = :b_num then
        v_id_2(i) := i;
        v_cn := v_cn + 1;
      end if;
    end loop;
    
    for i in v_id_2.first..v_id_2.last loop
     if v_id_2.exists(i) then
     dbms_output.put_line(:b_num ||' '||v_id_2(i)||' '||v_cn);
     end if;
    end loop;
end;
/

/* �Ϲ�ȭ(������) */
declare
    type arr1_type is table of number;
    v_id_1 arr1_type := arr1_type(1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9);
    
    type arr2_type is table of number index by binary_integer;
    v_id_2 arr2_type;
    
begin
    for i in v_id_1.first..v_id_1.last loop
     for j in v_id_1.first..v_id_1.last loop
      if v_id_1(i) = v_id_1(j) then
        v_id_2(j) := j;
      end if;
      end loop;
    end loop;
    
    for i in v_id_2.first..v_id_2.last loop
     dbms_output.put_line(v_id_1(i) ||' '||v_id_2(i));
    end loop;
end;
/

/* ������ Ǯ�� */
declare
    type arr1_type is table of number;
    v_id_1 arr1_type := arr1_type(1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9);
    v_find number := 20;
    v_position varchar2(100);
    v_cn number := 0;
    
beginim
    for i in v_id_1.first..v_id_1.last loop
      if v_id_1(i) = v_find then
        v_position := v_position ||','|| i ;
        v_cn := v_cn + 1;
      end if;
    end loop;
    
    if v_cn > 0 then
      dbms_output.put_line(v_find||' ���� �迭�� '||ltrim(v_position,',')||
      ' ��ġ�� ������ �� '||v_cn||'�� �ֽ��ϴ�.');
    else
      dbms_output.put_line(v_find ||' ���� �����ϴ�');
    end if;
end;
/


================================================================================
/*
cursor : sql�� ����޸� ����

select
1. parse
2. bind
3. execute
4. fetch

dml
1. parse
2. bind
3. execute

implicit cursor(�Ͻ��� Ŀ��) : Ŀ���� ����Ŭ�� �������� �Ѵ�.
 * select into(�ݵ�� 1���� row�� fetch�ؾ� �Ѵ�), DML��
�� �Ͻ��� cursor �Ӽ� 3����(DML ����� �Ǵ��ϴ� �Ӽ����θ� ����(select�� �������� �������� ��, ������))
   1. sql%rowcount : DML������ �������� row�� �Ǽ��� ������
   2. sql%found : DML������ �������� row�� ������ True, ������ False
   3. sql%notfound : DML������ �������� row�� ������ True, ������ False

explicit curcor(����� Ŀ��) : �������� row�� fetch�ؾ� �Ѵٸ� �̰� ����ؾ� �ȴ�.
                             ���α׷��Ӱ� Ŀ���� ���������ؾ� �Ѵ�.
*/
select * from employees where department_id = 20;

declare
     /* 1. Ŀ������ */
     cursor emp_cur is
           select employee_id, last_name, salary
           from employees
           where department_id = 20;  
           
     v_id employees.employee_id%type;
     v_name employees.last_name%type;
     v_sal employees.salary%type;
begin
     /* 2. Ŀ������ : �޸� �Ҵ�, parse, bind, execute, fetch */ --> ��뷮 �ѹ��� Ŀ���� �ε��Ű�°� �ƴ϶� �Դٰ���
      if emp_cur%isopen then --> open���� Ȯ��(open�̸� true)
             null;
      else
           open emp_cur;     --> �׳� �̰͸� �ص� �ǰ�
     end if;
     /* 3. fetch : Ŀ���� active set ����� ������ �ε��۾� */
     loop
         fetch emp_cur into v_id, v_name, v_sal;
         exit when emp_cur%notfound; /* > 2 or emp_cur%rowcount */ /* emp_cur%found �� �ִ� */
         dbms_output.put_line(v_id);
         dbms_output.put_line(v_name);
         dbms_output.put_line(v_sal);
        
     end loop;
         dbms_output.put_line(emp_cur%rowcount); --> fetch�� ��
         
     /* 4. close : Ŀ�� �ݱ� */
     close emp_cur;
end;
/

/* ����� Ŀ�� �Ӽ�
1. Ŀ����%isopen : �� �̸����� memory�� open�������� true.
2. Ŀ����%notfound : fetch�Ѱ� ������ true, ������ false
3. Ŀ����%rowcount : fetch�� ����
4. Ŀ����%found : fetch�Ѱ� ������ true, ������ false
*/

--------------------------------------------------------------------------------

[����25]
2006�⵵�� �Ի��� ������� �ٹ� �����̸����� �޿��� �Ѿ�, ����� ����ϼ���.

<ȭ�����>

Seattle ���ÿ� �ٹ��ϴ� ������� �Ѿױ޿��� ��10,400 �̰� ��ձ޿��� ��5,200 �Դϴ�.
South San Francisco ���ÿ� �ٹ��ϴ� ������� �Ѿױ޿��� ��37,800 �̰� ��ձ޿��� ��2,907 �Դϴ�.
Southlake ���ÿ� �ٹ��ϴ� ������� �Ѿױ޿��� ��13,800 �̰� ��ձ޿��� ��6,900 �Դϴ�.
Oxford ���ÿ� �ٹ��ϴ� ������� �Ѿױ޿��� ��59,100 �̰� ��ձ޿��� ��8,442 �Դϴ�.


select l.city, sum(e.salary), avg(e.salary)
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id
and (e.hire_date >= to_date(20060101,'yyyymmdd')
and e.hire_date < to_date(20070101,'yyyymmdd'))
group by l.city;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));

select l.city, e.sum, e.avg
from (select sum(salary) sum ,avg(salary) avg , department_id
      from employees
      where hire_date >= to_date(20060101,'yyyymmdd')
      and hire_date < to_date(20070101,'yyyymmdd')
      group by department_id) e,
     (select department_id, location_id
      from departments) d,
      locations l
where e.department_id = d.department_id
and d.location_id = l.location_id;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


declare
     cursor emp_cur is
       select l.city, sum(e.salary), trunc(avg(e.salary))
       from employees e, departments d, locations l
       where e.department_id = d.department_id
       and d.location_id = l.location_id
       and (e.hire_date >= to_date(20060101,'yyyymmdd')
       and e.hire_date < to_date(20070101,'yyyymmdd'))
       group by l.city;
     v_city locations.city%type;
     v_sum_sal employees.salary%type;
     v_avg_sal number(8,1);
begin
     open emp_cur;
     loop 
       fetch emp_cur into v_city, v_sum_sal, v_avg_sal;
       exit when emp_cur%notfound;
       dbms_output.put_line(v_city||' ���ÿ� �ٹ��ϴ� ������� �Ѿױ޿��� '||
       ltrim(to_char(v_sum_sal,'l999,999'))||' �̰� ��ձ޿��� '||
       ltrim(to_char(v_avg_sal,'l999,999'))||'�Դϴ�.');
     end loop;
     
     close emp_cur;
end;
/

--------------------------------------------------------------------------------

/* record Ȱ�� */
declare
     /* 1. Ŀ������ */
     cursor emp_cur is
           select *
           from employees
           where department_id = 20;  
           
     v_rec emp_cur%rowtype; --> record ����
begin
     /* 2. Ŀ������ : �޸� �Ҵ�, parse, bind, execute, fetch */ --> ��뷮 �ѹ��� Ŀ���� �ε��Ű�°� �ƴ϶� �Դٰ���
      if emp_cur%isopen then --> open���� Ȯ��(open�̸� true)
             null;
      else
           open emp_cur;
     end if;
     /* 3. fetch : Ŀ���� active set ����� ������ �ε��۾� */
     loop
         fetch emp_cur into v_rec;
         exit when emp_cur%notfound;
         dbms_output.put_line(v_rec.employee_id);
         dbms_output.put_line(v_rec.last_name);
         dbms_output.put_line(v_rec.salary);
        
     end loop;
         dbms_output.put_line(emp_cur%rowcount); --> fetch�� ��
         
     /* 4. close : Ŀ�� �ݱ� */
     close emp_cur;
end;
/

/* for�� Ȱ�� : ���ڵ�, ����� Ŀ�� �Ϻ� �ڵ� */
declare
     /* 1. Ŀ������ */
     cursor emp_cur is
           select *
           from employees
           where department_id = 20;  
           
begin
     /* 2.open, 3.fetch, 4.close + ���ڵ庯�� �ڵ����� */
     for emp_rec in emp_cur loop --> ����� for��
         dbms_output.put_line(emp_rec.employee_id);
         dbms_output.put_line(emp_rec.last_name);
         dbms_output.put_line(emp_rec.salary);
     end loop;
end;
/


/* �������� Ȱ�� */
begin
     /* 2.open, 3.fetch, 4.close + ���ڵ庯�� �ڵ����� */
     for emp_rec in (select *
                     from employees
                     where department_id = 20) --> �̸��� ���� �޸�(����Ŭ ����) : ����� Ŀ�� �Ӽ� �̿����
     loop
         dbms_output.put_line(emp_rec.employee_id);
         dbms_output.put_line(emp_rec.last_name);
         dbms_output.put_line(emp_rec.salary);
     end loop;
end;
/
/*
# (����)�ڵ����� �ϸ� ��(active set ���)�� ���� �� �ڵ����� close��(�ƿ� for���� ������ Ÿ�� ����). 
   �׷��� ���������� active set ��� ���� �� � �׼��� ���ؾ� �Ѵٸ� manual�ϰ� �����ؾ� ��. 
*/

[����26]
����� last_name ���� �Է� �޾Ƽ� �� ����� employee_id, last_name, department_name ����ϰ� 
������ ���� last_name�� �Է� �Ұ�쿡��  "Hong �̶�� ����� �������� �ʽ��ϴ�."  ��� �ϴ� ���α׷��� ���弼��.


�Է°� : king

Employee Id = 156 Name = King Department Name = Sales
Employee Id = 100 Name = King Department Name = Executive


�Է°� : hong

Hong �̶�� ����� �������� �ʽ��ϴ�.

select count(*) from employees where last_name = 'King';
var b_lname varchar2(30)
exec :b_lname := 'king'
print :b_lname

declare
    cursor emp_cur is
      select e.employee_id, d.department_name
      from employees e, departments d
      where e.department_id = d.department_id 
      and last_name = initcap(:b_lname);
begin
     for rec in emp_cur loop
       if 
         dbms_output.put_line('Employee Id = '||rec.employee_id||' Name = '||
         initcap(:b_lname)||' Department Name = '||rec.department_name);

   else dbms_output.put_line(1);
   end if;
        end loop;
end;
/

/* ������ Ǯ�� */

-- King, Hong ������ ��ȸ

SELECT e.employee_id, e.last_name, d.department_name 
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND e.last_name = initcap('king');

SELECT e.employee_id, e.last_name, d.department_name 
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND e.last_name = initcap('hong');

--------------------------------------------------------------------------------
/* �߸��� ���� */

var b_name varchar2(10)

execute :b_name := 'king'

DECLARE
  CURSOR c1 IS 
	      SELECT e.employee_id, e.last_name, d.department_name
	      FROM employees e, departments d
        WHERE e.department_id = d.department_id
        AND e.last_name = initcap(:b_name);
BEGIN
  FOR v_rec IN c1 LOOP
    IF c1%NOTFOUND THEN  
	        DBMS_OUTPUT.PUT_LINE(:b_name || '  �̶�� ����� �������� �ʽ��ϴ�.');
    ELSE
          DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                               ||' Name = ' || v_rec.last_name 
		                           ||' Department Name = '||v_rec.department_name);
    END IF;
  END LOOP;
END;
/


execute :b_name := 'hong'

DECLARE
 CURSOR c1 IS 
	      SELECT e.employee_id, e.last_name, d.department_name
	      FROM employees e, departments d
        WHERE e.department_id = d.department_id
        AND e.last_name = initcap(:b_name);
BEGIN
  FOR v_rec IN c1 LOOP
    IF c1%NOTFOUND THEN --> �߸� ���� ��. �������� ����. ��� ������ �ƿ� �ȵ�.
	      DBMS_OUTPUT.PUT_LINE(:b_name || '  �̶�� ����� �������� �ʽ��ϴ�.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                             ||' Name = ' || v_rec.last_name 
		                         ||' Department Name = '||v_rec.department_name);
    END IF;
  END LOOP;
END;
/
--------------------------------------------------------------------------------
/* �� ������ ���� */

DECLARE
 CURSOR c1 IS
	 SELECT e.employee_id, e.last_name, d.department_name 
	 FROM employees e, departments d
   WHERE e.department_id = d.department_id
   AND e.last_name = initcap(:b_name);

 v_rec c1%rowtype;

BEGIN
  OPEN c1;
  
  FETCH c1 INTO v_rec; --> active set �߻��ǰų� �߻����� �ʴ� ��츦 ���� �̳�
  	
  IF c1%NOTFOUND THEN 
		  DBMS_OUTPUT.PUT_LINE(:b_name || '  �̶�� ����� �������� �ʽ��ϴ�.');
  ELSE
   		DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                           ||' Name = ' || v_rec.last_name 
		                       ||'Department Name = '||v_rec.department_name);
	    LOOP
		    FETCH c1 INTO v_rec;
		      IF c1%FOUND THEN  
  			     DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                      		   ||' Name = ' || v_rec.last_name 
		                         ||' Department Name = '||v_rec.department_name);
		      ELSE  
			       EXIT;
		      END IF;
	     END LOOP;
  END IF; 
  CLOSE c1;
  
END;
/


