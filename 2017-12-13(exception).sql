[����29] ������̺� �μ��ڵ尪�� �������� �����ȹ�� �и��ϴ� ���α׷��� �����ϼ���. 
         �μ��ڵ��߿� 50,80, null ���� �ԷµǸ� full table scan 
         �׿� �μ� �ڵ尪�� �Է� �ԷµǸ� index range scan �Ҽ� �ֵ��� �ϼ���.

var b_id number

execute :b_id := 50

execute :b_id := 10

execute :b_id := null

-- ����ó�� ��Ƽ������ ������ �յ��ϴٰ� �Ǵ��ϴ� �����ؼ� �۵��ϰ� ����� ���α׷�
-- ����� Ŀ��, ��Ʈ���, ������ �� 3��

/* employees table�� index ��ȸ */
select ix.index_name, ix.uniqueness, ic.column_name
from user_indexes ix, user_ind_columns ic
where ix.index_name = ic.index_name
and ix.table_name = 'EMPLOYEES';

/* �ʾ� */
declare 
  cursor c_full1 is
      select /*+ full(e) parallel(e,2) */ *
      from employees
      where department_id = :b_id;
  cursor c_full2 is
      select /*+ full(e) parallel(e,2) */ *
      from employees
      where department_id is null;      
  cursor c_idx is
      select /*+ index(e emp_department_ix) */ *
      from employees e
      where department_id = :b_id;     
begin
  if :b_id = 50 or :b_id = 80 then
    for rec_f in c_full1 loop
      dbms_output.put_line(rec_f.last_name);
    end loop;
  elsif :b_id is null then
    for rec_f in c_full2 loop
      dbms_output.put_line(rec_f.last_name);  
    end loop;
  else 
    for rec_ix in c_idx loop
      dbms_output.put_line(rec_ix.last_name);
    end loop;
  end if;
end;
/
/* NOTE Ŀ���� ���ʿ��ϰ� 3���� ���� ���α׷��� �޸� ���ɿ� ���ڰ� �ۿ��� ������ �Ǵ� */

/* �� ������� */
begin
end;
/


/* ������ Ǯ�� */
SQL> col index_name format a20
SQL> col column_name format a20
SQL> select ix.index_name, ix.uniqueness, ic.column_name
     from user_indexes ix, user_ind_columns ic
     where ix.index_name = ic.index_name
     and ix.table_name = 'EMPLOYEES';

INDEX_NAME           UNIQUENESS         COLUMN_NAME
-------------------- ------------------ --------------------
EMP_DEPARTMENT_IX    NONUNIQUE          DEPARTMENT_ID
EMP_EMAIL_UK         UNIQUE             EMAIL
EMP_EMP_ID_PK        UNIQUE             EMPLOYEE_ID
EMP_HIRE_IDX         NONUNIQUE          HIRE_DATE
EMP_JOB_IX           NONUNIQUE          JOB_ID
EMP_MANAGER_IX       NONUNIQUE          MANAGER_ID
EMP_NAME_IX          NONUNIQUE          FIRST_NAME
EMP_NAME_IX          NONUNIQUE          LAST_NAME

set serveroutput on

var b_id number

execute :b_id := 50

execute :b_id := 10

execute :b_id := null


begin
 if :b_id in (50,80) then 
    for emp_rec in (select /*+ full(e) */ * 
                    from employees e 
                    where department_id = :b_id) loop
        dbms_output.put_line(emp_rec.employee_id ||' '||emp_rec.last_name);
    end loop;
  elsif :b_id is null then
    for emp_rec in (select /*+ full(e) */ * 
                    from employees e 
                    where department_id is null) loop
       dbms_output.put_line(emp_rec.employee_id ||' '||emp_rec.last_name);    
    end loop;   
 else                          
    for emp_rec in (select /*+ index(e emp_department_ix) */ * 
                    from employees e 
                    where department_id = :b_id) loop
        dbms_output.put_line(emp_rec.employee_id ||' '||emp_rec.last_name);     
    end loop;
 end if;
end;
/

/* bulk collect into Ȱ�� */
declare
	type emp_tab_type is table of employees%rowtype;
	v_tab emp_tab_type;
begin
 if :b_id in (50,80) then 
    select /*+ full(e) */ * 
    bulk collect into v_tab
    from employees e 
    where department_id = :b_id;
   
   for i in v_tab.first..v_tab.last loop
     dbms_output.put_line(v_tab(i).employee_id ||' '||v_tab(i).last_name);
   end loop;
  
 elsif :b_id is null then
    select /*+ full(e) */ * 
    bulk collect into v_tab
    from employees e 
    where department_id is null;

    for i in v_tab.first..v_tab.last loop
     dbms_output.put_line(v_tab(i).employee_id ||' '||v_tab(i).last_name);
    end loop;

 else                          
    select /*+ index(e emp_department_ix) */ * 
    bulk collect into v_tab
    from employees e 
    where department_id = :b_id; 
 
    for i in v_tab.first..v_tab.last loop
     dbms_output.put_line(v_tab(i).employee_id ||' '||v_tab(i).last_name);
    end loop;
   
 end if;
end;
/

/* ���� ������ */
select * from employees where department_id = 10; --> index 
select * from employees where department_id = 50; --> full
select * from employees where department_id = :b_id; 
 --> ������ ó���ϸ� �������� �յ��ϰ� �����ؼ� ���� ���� ��� I/O �߻� ������ �� ����

select department_id, count(*)
from employees
group by department_id;

================================================================================

-- exception ���ܻ��� : �����߿� �߻��� ����Ŭ�� ����

/* 1. predefined exception : ����Ŭ�� ������ȣ�� ���� ���ܻ��� �̸��� �ִ� ��� */

declare
     v_rec employees%rowtype;
begin
     /* �Ͻ��� Ŀ������ �ǵ������� �����߻� */
     select *
     into v_rec --> �����ุ ����
     from employees
     where department_id = 20;
     dbms_output.put_line(v_rec.last_name);
exception
    /* �������Ḧ ��Ű�� ���� */
     when no_data_found then
       dbms_output.put_line('����� ���� �μ��ڵ带 �Է� �߽��ϴ�.');
     when too_many_rows then
       dbms_output.put_line('�Ҽӻ���� ������ �Դϴ�.');
end;
/



/* ������ ����� ���� �ڵ� rollback */
declare
     v_rec employees%rowtype;
begin
     update employees
     set salary = salary * 1.1
     where employee_id = 100;
     
     select *
     into v_rec
     from employees
     where department_id = 20;
     
     dbms_output.put_line(v_rec.last_name);
end;
/
/* test : 24000 ���� ���� */
select salary from employees where employee_id = 100; 


/* exception�� ���ؼ� �������ᰡ �Ǿ DML���� ���� �������� �� �ؾ��� */
declare
     v_rec employees%rowtype;
begin
     update employees
     set salary = salary * 1.1
     where employee_id = 100;
     
     select *
     into v_rec
     from employees
     where department_id = 20;
     
     dbms_output.put_line(v_rec.last_name);
exception
     when no_data_found then
       dbms_output.put_line('����� ���� �μ��ڵ带 �Է� �߽��ϴ�.');
     when too_many_rows then
       dbms_output.put_line('�Ҽӻ���� ������ �Դϴ�.');
     rollback; --> �� �������(�Ǵ� commit;)
end;
/

/* when others then : � ������ �߻��� �� �𸦶� ���� �������� �ۼ� */
declare
     v_rec employees%rowtype;
begin
   begin
     update employees
     set salary = salary * 1.1
     where employee_id = 100;
     
     select *
     into v_rec
     from employees
     where department_id = 20;
   exception
     when no_data_found then
       dbms_output.put_line('����� ���� �μ��ڵ带 �Է� �߽��ϴ�.');
     when others then
       dbms_output.put_line('������ȣ : '||sqlcode); --> ����߻��� ������ȣ ����
       dbms_output.put_line('�����޼��� : '||sqlerrm); --> ����߻��� �����޼��� ����
     rollback;
   end;
    dbms_output.put_line(v_rec.last_name);
end;
/


delete from departments where department_id = 10; --> pk�� ���ӵ� fk�� �־ ���� �ȵ�

/* 2. non-predefined exception : ������ȣ�� ������ ���ܻ��� �����̸� ���� ��� */
declare
    e_error exception; --> �̸�����
    pragma exception_init(e_error,-2292); 
begin
    delete from departments where department_id = 10;
    /*����: ORA-02292: integrity constraint (HR.EMP_DEPT_FK) violated - child record found*/
exception
    when e_error then
        dbms_output.put_line('������̺� �Ҽӻ���� �ֽ��ϴ�.');
end;
/


/* 3. user-defined exception : ����Ŭ���� ������ �ƴ����� ���������� ������ ��� */

declare
     e_invalid_id exception;
begin
     update employees
     set salary = salary * 1.1 
     where employee_id = 300; --> ������ ���� row�� ������ exception ������ �ƴ�
     
     if sql%notfound then
           raise e_invalid_id; --> raise�� ������ ������ exception���� ����(������)
     end if;
exception
     when e_invalid_id then
         dbms_output.put_line('�����ȣ�� �� �Է��ϼ���'); 
        --null;
     rollback;
end;
/


/* raise_application_error : ������ �����Ű�鼭 ����Ŭ�� �����ִ� ����ó�� ���̰� ����� ��� */
begin
     update employees
     set salary = salary * 1.1 
     where employee_id = 300;
     
     if sql%notfound then
        /* raise_application_error: ������ ���������� �߻���Ű�� ���ν���(������ȣ�� -20000~-20999)*/
           raise_application_error(-20000,'���� ��� �Դϴ�.');
     end if;
end;
/


declare
     v_rec employees%rowtype;
begin
     select * into v_rec from employees where employee_id = 300;
exception
     when no_data_found then
         raise_application_error(-20001,'���� ����Դϴ�',false); 
         --> �⺻�� : false(������), true�� ����Ŭ ������ �����ؼ� �� ����
end;
/

================================================================================

[����30] ��� ��ȣ�� �Է� ������ �޾Ƽ� ����� ��ȣ, �̸�, �μ��̸� ������ ����ϴ� ���α׷��� �ۼ��մϴ�.
�� 100�� ����� �Է°����� ������ ���ܻ����� �߻��ϵ��� �ؾ� �մϴ�.
���� ���� �����ȣ ���� ������ ���ܻ��� ó���� ����� �ּ���.


<ȭ�� ���>
SQL> var b_id number

SQL> execute :b_id := 200

Result=> �����ȣ : 200, ����̸� : Whalen, �μ��̸� : Administration

SQL> execute :b_id := 100

100 ����� ��ȸ�Ҽ� �����ϴ�.


SQL> execute :b_id := 300

300 ����� �������� �ʽ��ϴ�.


var b_id number
exec :b_id := 100

declare
    type rec_type is record( lname employees.last_name%type,
                             dname departments.department_name%type);
     v_rec rec_type;
     e_1 exception;
begin
     if :b_id = 100 then
       raise e_1;
     else
       select e.last_name, d.department_name
       into v_rec
       from employees e, departments d
       where e.department_id = d.department_id
       and e.employee_id = :b_id;
       
        dbms_output.put_line('Result=> �����ȣ : '||:b_id||', ����̸� : '||
        v_rec.lname||', �μ��̸� : '||v_rec.dname);
        
     end if;
exception
     when e_1 then /* 100 */
       dbms_output.put_line(:b_id||' ����� ��ȸ�Ҽ� �����ϴ�.');
     when no_data_found then /* 300 */
       dbms_output.put_line(:b_id||' ����� �������� �ʽ��ϴ�.');
end;
/


[����31] ����� �߿� job_id�� 'SA_REP' ������� �̸�, �μ� �̸��� ����ϰ� �μ� ��ġ�� ���� �ʴ�
����鿡 ���ؼ��� "�μ� ��ġ�� �� �޾ҽ��ϴ�." ����ؾ� �մϴ�.
���� ����Ҷ� ī���� ���� ������ּ���.(������ �̿����� ������)

1 ����̸� : Tucker, �μ��̸� : Sales
2 ����̸� : Bernstein, �μ��̸� : Sales
3 ����̸� : Hall, �μ��̸� : Sales
4 ����̸� : Olsen, �μ��̸� : Sales
5 ����̸� : Cambrault, �μ��̸� : Sales
6 ����̸� : Tuvault, �μ��̸� : Sales
7 ����̸� : King, �μ��̸� : Sales
8 ����̸� : Sully, �μ��̸� : Sales
9 ����̸� : McEwen, �μ��̸� : Sales
10 ����̸� : Smith, �μ��̸� : Sales
11 ����̸� : Doran, �μ��̸� : Sales
12 ����̸� : Sewall, �μ��̸� : Sales
13 ����̸� : Vishney, �μ��̸� : Sales
14 ����̸� : Greene, �μ��̸� : Sales
15 ����̸� : Marvins, �μ��̸� : Sales
16 ����̸� : Lee, �μ��̸� : Sales
17 ����̸� : Ande, �μ��̸� : Sales
18 ����̸� : Banda, �μ��̸� : Sales
19 ����̸� : Ozer, �μ��̸� : Sales
20 ����̸� : Bloom, �μ��̸� : Sales
21 ����̸� : Fox, �μ��̸� : Sales
22 ����̸� : Smith, �μ��̸� : Sales
23 ����̸� : Bates, �μ��̸� : Sales
24 ����̸� : Kumar, �μ��̸� : Sales
25 ����̸� : Abel, �μ��̸� : Sales
26 ����̸� : Hutton, �μ��̸� : Sales
27 ����̸� : Taylor, �μ��̸� : Sales
28 ����̸� : Livingston, �μ��̸� : Sales
29 ����̸� : Grant, �μ��̸� : �μ� ��ġ�� �� �޾ҽ��ϴ�.
30 ����̸� : Johnson, �μ��̸� : Sales

-- loop �ȿ� loop ���� ����
-- grant no_data_found
-- main sub block

select last_name, department_id
from employees
where job_id = 'SA_REP'; --> ����� Ŀ���� ����

select department_name
from departments
where department_id = ���ڵ� ����;


declare
     type rec_type is record(lname employees.last_name%type,
                             dname departments.department_name%type);
     type arr_type is table of rec_type;
     v_arr arr_type;
begin

     select last_name lname, 
            (select department_name
             from departments
             where department_id = e.department_id) dname
     bulk collect into v_arr
     from employees e
     where job_id = 'SA_REP';

     for i in v_arr.first..v_arr.last loop
     if v_arr(i).dname is not null then
     dbms_output.put_line(i||' ����̸� : '||v_arr(i).lname||', �μ��̸� : '||v_arr(i).dname);
     else
     dbms_output.put_line(i||' ����̸� : '||v_arr(i).lname||
                               ', �μ��̸� : �μ� ��ġ�� �� �޾ҽ��ϴ�.'); 
     end if;
     end loop;
end;
/


declare
     type rec_type is record(num number, lname varchar2(30), dname varchar2(100));
     type arr_type is table of rec_type;
     v_arr arr_type;
begin
     select rownum,
            e.last_name, 
            nvl((select department_name 
                 from departments 
                 where department_id = e.department_id),
                 '�μ� ��ġ�� �� �޾ҽ��ϴ�.') dname
     bulk collect into v_arr
     from employees e
     where e.job_id = 'SA_REP';

     for i in v_arr.first..v_arr.last loop
       dbms_output.put_line(v_arr(i).num||' ����̸� : '||v_arr(i).lname||', �μ��̸� : '||v_arr(i).dname);
     end loop;
end;
/


/* ������ Ǯ�� */

/* Ǯ�� 1
 �� ����� Ŀ�� ����
 �� dept_name �� ������ ���� ����
 �� ������ȣ ������ ���� ����
 �� for�� ���� ���ڵ� ���� ����
 �� ������ Ȱ�� : exception ��
 �� �������� �ۼ�(no_data_found)
 */
DECLARE
     CURSOR emp_cursor IS
	          SELECT last_name, department_id
            FROM  employees                              
  	        WHERE job_id = 'SA_REP'; /*��*/          
     v_dept_name departments.department_name%type; /*��*/ 
     v_c number := 1; /*��*/
BEGIN
    FOR c_rec IN emp_cursor LOOP  /*��*/
    
       BEGIN  /*��*/
			   SELECT department_name
         INTO v_dept_name
			   FROM departments
         WHERE department_id = c_rec.department_id;
			
			   dbms_output.put_line(v_c||' ����̸� : '||c_rec.last_name 
                                   ||', �μ��̸� : '||v_dept_name);
			   v_c := v_c + 1;
       EXCEPTION  /*��*/
         WHEN no_data_found THEN 
			     dbms_output.put_line(v_c||' ����̸� : '||c_rec.last_name 
                                ||', �μ��̸� : �μ� ��ġ�� �� �޾ҽ��ϴ�.');
		        v_c := v_c + 1;
       END;
       
    END LOOP;
END;
/



/* Ǯ�� 2
 �� dept_name �� ������ ���� ����
 �� ������ȣ ������ ���� ����
 �� for���� ���������� ���� ���ڵ� ���� ����(Ŀ�� �̼���)
 �� ������ Ȱ��
 �� �������� �ۼ�(no_data_found)
 */
DECLARE
    v_dept_name departments.department_name%type; /*��*/
    v_c number := 1; /*��*/

BEGIN
	  FOR c_rec IN (SELECT last_name, department_id  /*��*/
                  FROM  employees
                  WHERE job_id = 'SA_REP') LOOP
      BEGIN  /*��*/
			   SELECT department_name
         INTO v_dept_name
			   FROM departments
			   WHERE department_id = c_rec.department_id;
			
			    dbms_output.put_line(v_c||' ����̸� : '||c_rec.last_name 
                                ||', �μ��̸� : '||v_dept_name);

			    v_c := v_c+1;
      EXCEPTION  /*��*/
         WHEN no_data_found THEN 
			      dbms_output.put_line(v_c||' ����̸� : '||c_rec.last_name 
                                ||', �μ��̸� : �μ���ġ�� �� �޾ҽ��ϴ�.');
		     v_c := v_c + 1;
      END;
    END LOOP;
END;
/


/* Ǯ�� 3
 �� ����� Ŀ�� ����
 �� record ��������
 �� dept_name �� ������ ���� ����
 �� ������ȣ ������ ���� ����
 �� loop������ fetch
 �� ������ Ȱ��
 �� �������� �ۼ�(no_data_found)
*/
DECLARE
     CURSOR emp_cursor IS  /*��*/
	        SELECT last_name, department_id
          FROM  employees
  	      WHERE job_id = 'SA_REP';

     c_rec emp_cursor%rowtype;  /*��*/
     v_dept_name departments.department_name%type;  /*��*/
     v_c number := 1;  /*��*/

BEGIN
     OPEN emp_cursor;

     LOOP  
        FETCH emp_cursor INTO c_rec;  /*��*/
        EXIT WHEN emp_cursor%NOTFOUND;
    
         BEGIN  /*��*/
			      SELECT department_name
      			INTO v_dept_name
			      FROM departments
			      WHERE department_id = c_rec.department_id;
			
			      dbms_output.put_line(v_c||  ' ����̸� : '||c_rec.last_name 
                                        ||', �μ��̸� : '||v_dept_name);

			      v_c := v_c+1;
         EXCEPTION  /*��*/
           WHEN no_data_found THEN 
			          dbms_output.put_line(v_c||  ' ����̸� : '||c_rec.last_name 
                                        ||', �μ��̸� : �μ� ��ġ�� �� �޾ҽ��ϴ�.');
           v_c := v_c + 1;
         END;
    END LOOP;
    
    CLOSE emp_cursor;
END;
/


/* Ǯ�� 4
 �� ����� Ŀ�� ����
 �� 2���� �迭 ��������
 �� dept_name �� ������ ���� ����
 �� ������ȣ ������ ���� ����
 �� for - loop�� ���
 �� ������ Ȱ��
 �� �������� �ۼ�(no_data_found)
*/
DECLARE
     CURSOR emp_cursor IS  /*��*/
	         SELECT last_name, department_id
           FROM  employees
  	       WHERE job_id = 'SA_REP';	

     TYPE emp_tab_type IS TABLE OF emp_cursor%rowtype;  /*��*/
     v_tab emp_tab_type;  
     v_dept_name departments.department_name%type;  /*��*/
     v_c number := 1;  /*��*/

BEGIN
     OPEN emp_cursor;

     FETCH emp_cursor BULK COLLECT INTO v_tab;
    
     FOR i IN v_tab.first..v_tab.last LOOP  /*��*/
		     BEGIN  /*��*/
			      SELECT department_name
      			INTO v_dept_name
            FROM departments
			      WHERE department_id = v_tab(i).department_id;
			
			      dbms_output.put_line(v_c||  ' ����̸� : '||v_tab(i).last_name 
                                        ||', �μ��̸� : '||v_dept_name);
			      v_c := v_c+1;
         EXCEPTION  /*��*/
	           WHEN no_data_found THEN 
			            dbms_output.put_line(v_c||  ' ����̸� : '||v_tab(i).last_name 
                                        ||', �μ��̸� : �μ� ��ġ�� �� �޾ҽ��ϴ�.');
                  v_c := v_c + 1;
         END;
    END LOOP;

    CLOSE emp_cursor;
END;
/


/* ��Į�� �������� : cache ������� ���� ������ ���� */
DECLARE
     CURSOR emp_cursor IS
	        select rownum no, 
                 e.last_name, 
                 nvl((select  department_name
                      from departments
                      where department_id = e.department_id), '�μ� ��ġ�� ���޾ҽ��ϴ�.') dept_name
	        from employees e
	        where  e.job_id = 'SA_REP';
	
      TYPE emp_tab_type IS TABLE OF emp_cursor%rowtype;
          v_tab emp_tab_type;

BEGIN
      OPEN emp_cursor;
      FETCH emp_cursor BULK COLLECT INTO v_tab;
      FOR i IN v_tab.first..v_tab.last LOOP
				 dbms_output.put_line(v_tab(i).no||  ' ����̸� : '||v_tab(i).last_name 
                              ||', �μ��̸� : '||v_tab(i).dept_name);
	    END LOOP;
      CLOSE emp_cursor;
END;
/