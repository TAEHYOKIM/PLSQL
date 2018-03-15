[����14] 1������ 100���� ¦���� ����ϼ���.
/* Ǯ��1. for loop */
begin
  for i in 1..100 loop
   if mod(i,2)=0 then
    dbms_output.put_line(i);
   end if;
  end loop;
end;
/

/* Ǯ��2. while loop */
declare
     i number := 2;
begin
    while i <= 100 loop
     dbms_output.put_line(i);
     i := i + 2;
    end loop;
end;
/

/* Ǯ��3. �⺻ loop */
declare
      i number := 2;
begin
      loop 
        dbms_output.put_line(i);
        i := i + 2;
        exit when i > 100;
      end loop;
end;
/


[����15] 1������ 100���� Ȧ���� ����ϼ���.
/* Ǯ��1. for loop */
begin
  for i in 1..100 loop
   if mod(i,2)=1 then
    dbms_output.put_line(i);
   end if;
  end loop;
end;
/

/* Ǯ��2. while loop */
declare
     i number := 1;
begin
    while i <= 100 loop
     dbms_output.put_line(i);
     i := i + 2;
    end loop;
end;
/

/* Ǯ��3. �⺻ loop */
declare
      i number := 1;
begin
      loop 
        dbms_output.put_line(i);
        i := i + 2;
        exit when i > 100;
      end loop;
end;
/


[����16] ������ 2�� ����ϴ� ���α׷��� �ۼ��ϼ���.

2 * 1 = 2
2 * 2 = 4
2 * 3 = 6
2 * 4 = 8
2 * 5 = 10
2 * 6 = 12
2 * 7 = 14
2 * 8 = 16
2 * 9 = 18

begin
   for i in 1..9 loop
    dbms_output.put_line('2 * '||i||' = '||2 * i);
   end loop;
end;
/

[����17]
���� �Է°����� �޾Ƽ� �� �ܿ� ���ؼ��� ����Ͻð� ���࿡ �� �Է°��� ������ ��ü �������� ��µǵ��� �ۼ��ϼ���.

var b_dan number

execute :b_dan := 2

execute :b_dan := null

begin
    for i in 1..9 loop
      if :b_dan is not null then
        dbms_output.put_line(:b_dan||' * '||i||' = '||:b_dan*i);
      else
        for j in 1..9 loop
         dbms_output.put_line(i||' * '||j||' = '||i*j);
        end loop;
      end if;  
    end loop;
end;
/

/* �ٸ� loop���� ������ �۵��� �ȴ� */
declare
    i number := 1;
begin
    while i < 10 loop
      if :b_dan is not null then
        dbms_output.put_line(:b_dan||' * '||i||' = '||:b_dan*i);
      else
        for j in 1..9 loop
         dbms_output.put_line(i||' * '||j||' = '||i*j);
        end loop;
      end if;
      i := i + 1;
    end loop;
end;
/

begin
   for i in 1..10 loop
     dbms_output.put_line('*');
     for j in i..i+1 loop
       dbms_output.put_line(' *');
       dbms_output.put_line('*');
     end loop;
   end loop;
end;
/

DECLARE
    v_gogo number;
BEGIN
    FOR i IN 1..9 LOOP
        FOR v_gogo IN 1..9 LOOP
            IF i <= 9 THEN
                DBMS_OUTPUT.PUT_LINE( i ||'*'|| v_gogo ||'='|| (i * v_gogo));
            END IF;
        END LOOP;
    END LOOP;
END;
/

[����18]������ 2���� for loop ������ ����ϴµ� 2 * 6�� ���� �����ּ���.

2 * 1 = 2
2 * 2 = 4
2 * 3 = 6
2 * 4 = 8
2 * 5 = 10
2 * 7 = 14
2 * 8 = 16
2 * 9 = 18

begin
  for i in 1..9 loop
   if i<>6 then
    dbms_output.put_line('2 * '||i||' = '||2 * i);    
   end if;
  end loop;
end;
/

/* continue�� : 11g���� ���� ��� */
begin
  for i in 1..9 loop
    continue when i = 6; --> continue when ���� : ������ ���̸� ���� ���ϰ� ���� ����
    dbms_output.put_line('2 * '||i||' = '||2 * i);    
  end loop;
end;
/


[����19] ��� ���̺��� employee_id, last_name �� ����ϴ� ���α׷��Դϴ�.
       �����ȣ�� 100�� ���� �ؼ� 5�� ������ ������ ����Ͻð� 120������ �������� ���ּ���.
 
<ȭ�� ���>

100  King
105  Austin
110  Chen
115  Khoo
120  Weiss


declare
    v_lname employees.last_name%type;
begin
    for i in 100..120 loop
      if mod(i,5)=0 then
          select last_name
          into v_lname
          from employees
          where employee_id = i;
          
        dbms_output.put_line(i || ' ' || v_lname);
      end if;
    end loop;
end;
/

var v_id number
exec 

declare
    v_lname employees.last_name%type;
    v_id employees.employee_id%type := 100;
begin
    while v_id <= 120 loop
          select employee_id, last_name
          into v_id, v_lname
          from employees
          where employee_id = v_id;
      dbms_output.put_line(v_id || ' ' || v_lname);
      v_id := v_id + 5;
    end loop;
end;
/
set serveroutput off;

[����20] ��� ��ȣ�� �Է� ������ �޾Ƽ� �� ����� �޿��� ����ϴ� ���α׷��� �ۼ��մϴ�. 
       ���� �޿� 1000�� ��(*) �ϳ��� ������ּ���.

<ȭ�����>
employee_id => 200  salary => 4400
star is => **** 

-- lpad
var b_id number
exec :b_id := 200
print :b_id

select null||'*' from dual;

declare
    v_sal employees.salary%type;
    v_star varchar2(100);
begin
    select salary
    into v_sal
    from employees
    where employee_id = :b_id;
    
    dbms_output.put_line('employee_id => '||:b_id||' salary => '||v_sal);
    
    /* lpad */
    dbms_output.put_line('star is => '||lpad('*',(v_sal/1000),'*'));
    
    /* for loop #1 */
    for i in 1..trunc(v_sal/1000) loop
      v_star := v_star || '*';
    end loop;
      dbms_output.put_line('star is => '||v_star);
      
    /* for loop #2 */
    for i in 1..trunc(v_sal/1000) loop
      dbms_output.put('*');  --> �޸𸮿��� ����
    end loop;
      dbms_output.new_line;  --> ���
end;
/
/* put_line : put + new_line */

begin
    select salary
    into v_sal
    from employees
    where employee_id = :b_id;
    
    
end;
/

================================================================================

/* ���պ���(���ڵ� Ÿ��) */

declare
  v_id departments.department_id%type;
  v_name departments.department_name%type;
  v_mgr departments.manager_id%type;
  v_loc departments.location_id%type;
begin
  select department_id, department_name, manager_id, location_id
  into v_id, v_name, v_mgr, v_loc
  from departments
  where department_id = 10;
        dbms_output.put_line(v_id||' '||v_name||' '||v_mgr||' '||v_loc);
end;
/

/* Ư¡ : ���α�����Ҹ� ���� ����� */
declare
 type dept_record_type is record  --> ���ڵ� ���� ���α���(dept_record_type)
 (
  id number,
  name varchar2(30),
  mgr departments.manager_id%type,
  loc departments.location_id%type
 );
 v_rec dept_record_type;          --> ���ڵ� ���� ����(v_rec)
begin
  select department_id, department_name, manager_id, location_id
  into v_rec.id, v_rec.name, v_rec.mgr, v_rec.loc
  from departments
  where department_id = 10;
        dbms_output.put_line(v_rec.id||' '||v_rec.name||' '||v_rec.mgr||' '||v_rec.loc);
end;
/

declare
 type dept_record_type is record
 (
  id number,
  name varchar2(30),
  mgr departments.manager_id%type,
  loc departments.location_id%type
 );
 v_rec dept_record_type;
begin
  select department_id, department_name, manager_id, location_id
  into v_rec       --> ������ Ÿ�� ��ġ�Ǹ� �����ϰ� ����
  from departments
  where department_id = 10;
        dbms_output.put_line(v_rec.id||' '||v_rec.name||' '||v_rec.mgr||' '||v_rec.loc);
end;
/

declare 
    v_rec employees%rowtype;  --> %rowtype : �ش� ���̺�(employees)�� �÷��� ������� record type ���� ����
begin
  select *
  into v_rec
  from employees
  where employee_id = 100;
        dbms_output.put_line(v_rec.employee_id||' '||v_rec.last_name);
end;
/

declare
/*
 type dept_record_type is record
 (
  id number,
  name varchar2(30),
  mgr departments.manager_id%type,
  loc departments.location_id%type
 );
 v_rec dept_record_type;
*/
v_rec departments%rowtype;
 
begin
   select *
   into v_rec
   from departments
   where department_id = 10;
         dbms_output.put_line(v_rec.department_id||' '||v_rec.location_id);
end;
/
 

================================================================================

���ڵ� ����
--------------------
| ���� | ���� | ��¥ |
--------------------

�迭 ����
----
�� ��
----
�� ��
----
�� ��
----


begin
    update emp
    set salary = salary * 1.1
    where employee_id = 100;
                 /* �����ȹ 2�� �����.. */
    update emp
    set salary = salary * 1.1
    where employee_id = 200;
end;
/

/* �� ������� */
declare 
    type table_id_type is table of number --> table_id_type : �迭���� �̸�, ...of number 1����
    index by binary_integer;              --> binary_integer : �迭 ���ȣ, ���̺��� ����ϴ°� �ƴ�

  /*  
    type table_id_type is table of number
    index by pls_integer;         
  */  --> ��ȣ��Ʈ ������ �־� ���ڰ�꿡�� �� ���� (10g �̻����)
    
    v_tab table_id_type;
    
begin
    v_tab(1) := 100;
    v_tab(2) := 200;
  
    update emp
    set salary = salary * 1.1
    where employee_id = v_tab(1);       
 /* ���� update�� �� ������ �ڵ尡 ������� �޸� ��뷮 ����(shared pool-lib.cache) */
    update emp
    set salary = salary * 1.1
    where employee_id = v_tab(2);    
end;
/


/* �� ������� */

declare 
    type table_id_type is table of number 
    index by binary_integer;              
    v_tab table_id_type;   
begin
    v_tab(1) := 100;
    v_tab(2) := 200;
    
  for i in 1..2 loop
    update emp
    set salary = salary * 1.1
    where employee_id = v_tab(i);
  end loop;
    dbms_output.put_line(sql%rowcount);
  rollback;
end;
/


/* �� ������� */

declare 
    type table_id_type is table of number 
    index by binary_integer;              
    v_tab table_id_type;   
begin
    v_tab(1) := 100;
    v_tab(3) := 200;
    v_tab(5) := 101;
    
  for i in v_tab.first..v_tab.last loop --> v_tab.first : ���� ���� ���ȣ, v_tab.last : ���� ū ���ȣ
    if v_tab.exists(i) then  --> v_tab.exists(i) : i�� ��Ұ� v_tab�� �����ϸ� True (�迭������ ����ϴ� �޼ҵ�), not exists�� ����
      update emp
      set salary = salary * 1.1
      where employee_id = v_tab(i);
    else
      dbms_output.put_line(i||' ��ҹ�ȣ�� ����');
    end if;
  end loop;
    dbms_output.put_line(sql%rowcount);
  rollback;
end;
/

[����21]
�迭 ������ �ִ� 100,101,102,103,104,200 ������� �ٹ��� �������� ����ϰ� �ٹ��������� 
150�����̻� �Ǿ����� �޿�(salary)�� 10% �λ��� �޿��� �����ϴ� ���α׷� �ۼ��ϼ���.


<��� ���>

100�� �ٹ��������� 166 �Դϴ�. �޿��� 10% �λ�Ǿ����ϴ�.
101�� �ٹ��������� 139 �Դϴ�. �޿��� �λ��� �� �����ϴ�.
102�� �ٹ��������� 195 �Դϴ�. �޿��� 10% �λ�Ǿ����ϴ�.
103�� �ٹ��������� 135 �Դϴ�. �޿��� �λ��� �� �����ϴ�.
104�� �ٹ��������� 119 �Դϴ�. �޿��� �λ��� �� �����ϴ�.
200�� �ٹ��������� 163 �Դϴ�. �޿��� 10% �λ�Ǿ����ϴ�.


declare
    type table_id_type is table of number 
    index by binary_integer;              
    v_tab table_id_type;  
    
    v_wk number;
begin
    v_tab(1) := 100;
    v_tab(2) := 101;
    v_tab(3) := 102;
    v_tab(4) := 103;
    v_tab(5) := 104;
    v_tab(6) := 200;
  
    for i in v_tab.first..v_tab.last loop
      select trunc(months_between(sysdate,hire_date))
      into v_wk
      from emp
      where employee_id = v_tab(i);
      
      if v_wk >= 150 then
        update emp
        set salary = salary * 1.1
        where employee_id = v_tab(i);
        
        dbms_output.put_line(v_tab(i)||'�� �ٹ��������� '||v_wk||'�Դϴ�. �޿��� 10% �λ�Ǿ����ϴ�.');
      else 
        dbms_output.put_line(v_tab(i)||'�� �ٹ��������� '||v_wk||'�Դϴ�. �޿��� �λ��� �� �����ϴ�.');
      end if;
      
    end loop;
end;
/


/* 2���� �迭 */

declare
   type dept_rec_type is record(id number, name varchar2(30), mgr number, loc number);
   v_rec dept_rec_type;
   
   type dept_table_type is table of v_rec%type index by binary_integer; --> ������ ������ ���� �׷��� ��밡��
   v_tab dept_table_type;
   
   /*
   type dept_table_type is table of dept_rec_type index by binary_integer;
   v_tab dept_table_type;
   */
begin
   for i in 1..5 loop
     select *
     into v_tab(i)
     from departments
     where department_id = i*10;
   end loop;
   
   for i in v_tab.first..v_tab.last loop /*1..5*/
     dbms_output.put_line(v_tab(i).id||v_tab(i).name||v_tab(i).mgr||v_tab(i).loc);
   end loop;
end;
/


declare
   type dept_rec_type is record(id number, name varchar2(30), mgr number, loc number);
   v_rec dept_rec_type;

   type dept_table_type is table of dept_rec_type index by binary_integer;
   v_tab dept_table_type;

begin
   for i in 1..5 loop
     select *
     into v_tab(i)
     from departments
     where department_id = i*10;
   end loop;
   
   for i in 1..5 loop
     dbms_output.put_line(v_tab(i).id||v_tab(i).name||v_tab(i).mgr||v_tab(i).loc);
   end loop;
end;
/


/* �� ������� */
declare
   type emp_table_type is table of employees%rowtype index by binary_integer;
   v_tab emp_table_type;
 --> employees%rowtype : ���ڵ� ������ �Ŷ� ������ ȿ��
begin
   for i in 100..110 loop
     select *
     into v_tab(i)
     from employees
     where employee_id = i;
   end loop;
   
   for i in 100..110 loop
     dbms_output.put_line(v_tab(i).employee_id||' '||v_tab(i).salary);
   end loop;
end;
/


declare
   type emp_rec_type is record(name varchar2(30), sal number, day date); --> 1. record ����
   type emp_table_type is table of emp_rec_type index by binary_integer; --> 2. �迭 ����
   v_tab emp_table_type;
begin
   for i in 100..110 loop
     select last_name, salary, hire_date
     into v_tab(i)
     from employees
     where employee_id = i;
   end loop;
   
   for i in 100..110 loop
     dbms_output.put_line(v_tab(i).name||' '||v_tab(i).sal||' '||v_tab(i).day);
   end loop;
end;
/


/* �߰�����(�־�� �� ������ �˰� ���� ���) : nested table data type(��ø�迭Ÿ��) */
declare 
    type table_id_type is table of number; --> index by binary_integer ������
    v_tab table_id_type := table_id_type(100, 101, 200, 103);  --> ��� ��ȣ�� 1~2^31���� �Ͻ��� �Է�
begin
  for i in v_tab.first..v_tab.last loop
      dbms_output.put_line(i||' : '||v_tab(i));
  end loop;
end;
/
