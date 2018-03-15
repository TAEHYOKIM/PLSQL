/*
function
 - return ���� ��ȯ�ϴ� �̸��� �ִ� pl/sql block �Դϴ�.
 - ǥ������ �Ϻη� ȣ���Ѵ�.
 
procedure
 - return���� ���α׷� �������� ����
 - pl/sql block���� ȣ�� �Ǵ� execute�ؼ� ȣ���ؾ� �Ѵ�.
*/
 
drop function tax;

create or replace function tax(p_value in number)--> out��� �ǹ̾���(����� ����)
return number
is
begin
    return(p_value * 0.08);
end tax;
/
/* ��� #1 */
exec dbms_output.put_line(tax(100))

/* ��� #2 */
var b_num number
exec :b_num := tax(100)
print :b_num

/* ��� #3 */
declare
     v_num number;
begin
     v_num := tax(100);
     dbms_output.put_line(v_num);
end;
/

select last_name, salary, tax(salary) from employees;

select employee_id, tax(salary)
from employees
where tax(salary) > (select max(tax(salary))
                     from employees
                     where department_id = 30);


[����40] �����ȣ�� �Է°����� �޾Ƽ� �� ����� �ٹ� ����� ���ϴ� �Լ��� �����ϼ���.
�� ���� �����ȣ�� ������ ���� ���� ������ȣ,�޽����� ��µǵ��� �ؾ��մϴ�.

<�Լ� ����>

SQL> execute dbms_output.put_line(get_year(100))
12


SQL> select employee_id, last_name, get_year(employee_id) years_func
     from employees;

EMPLOYEE_ID LAST_NAME  YEARS_FUNC
----------- ---------- ---------- 
        100 King               12       
        101 Kochhar            10         
        102 De Haan            15         
        103 Hunold             10         
     


SQL> execute dbms_output.put_line(get_year(300))
BEGIN dbms_output.put_line(get_year(300)); END;

*
ERROR at line 1:
ORA-20000: 300�� ����� �������� �ʽ��ϴ�.
ORA-06512: at "HR.GET_YEAR", line 14
ORA-01403: no data found
ORA-06512: at line 1


-- raise_application_error


create or replace function get_year (p_id number)
return number
is hdate date;
begin
   select hire_date 
   into hdate
   from employees where employee_id = p_id;
   return(trunc(months_between(sysdate,hdate)/12));
exception
   when no_data_found then
     raise_application_error(-20000,p_id||'�� ����� �������� �ʽ��ϴ�.',true);
   when others then
     dbms_output.put_line(sqlcode);
     dbms_output.put_line(sqlerrm);
end;
/

show error
exec dbms_output.put_line(get_year(100))

select employee_id, last_name, get_year(employee_id) years_func
from employees;

exec dbms_output.put_line(get_year(300))


[����41] �μ��ڵ带 �Է°����� �޾Ƽ� �μ��̸��� return �ϴ� �Լ��� ������ּ���.
�μ��ڵ尡 ���� ��� '�˼����� �μ�'�� return�ؾ� �մϴ�.

<�Լ� ������>

SQL> select employee_id, last_name, department_id, dept_name_func(department_id) dept_name
     from employees;

EMPLOYEE_ID LAST_NAME            DEPARTMENT_ID DEPT_NAME
----------- -------------------- ------------- --------------------
        177 Livingston                      80 Sales
        178 Grant                              �˼����� �μ�


SQL> exec dbms_output.put_line(dept_name_func(20))
Marketing

PL/SQL procedure successfully completed.


create or replace function dept_name_func (p_dept_id number)
return varchar2
deterministic /* PL/SQL �Լ����� ��Ʈ : cache ��� */
is dname varchar2(30):= '�˼� ���� �μ�';
begin
   select department_name
   into dname
   from departments
   where department_id = p_dept_id;

   return dname;
exception
   when no_data_found then
     return dname;
end;
/

show error

select employee_id, last_name, department_id, dept_name_func(department_id) dept_name
from employees;
================================================================================

[����42] ����Ÿ�� �÷� ������ ���̺� �ִ� �����ʹ� �������ĸ� ��� �� �־�� �ϴµ� 
        �׷��� �ʴ� �����͸� Ȯ�� �ϴ� �Լ��� �����ϼ���. 
        null �Ǵ� ���ڰ� ��� ������ 0��� ���ڴ� 1 ����ϼ���.

SQL> desc locations
 Name                                      Null?    Type
 ----------------------------------------- -------- -------------------------
 LOCATION_ID                               NOT NULL NUMBER(4)
 STREET_ADDRESS                                     VARCHAR2(40)
 POSTAL_CODE                                        VARCHAR2(12)
 CITY                                      NOT NULL VARCHAR2(30)
 STATE_PROVINCE                                     VARCHAR2(25)
 COUNTRY_ID                                         CHAR(2)


SQL> select postal_code, as_number(postal_code)  from locations;

POSTAL_CODE              AS_NUMBER(POSTAL_CODE)
------------------------ ----------------------
                                              0
00989                                         1
10934                                         1
1689                                          1
6823                                          1
26192                                         1
99236                                         1
50090                                         1
98199                                         1
M5V 2L7                                       0
YSW 9T2                                       0

create or replace function as_number(p_code varchar2)
return number
is num number := 0;
begin
   if to_number(p_code) > 0 then
     num := 1;
   end if;
   return num;
exception
   when others then
     return num;
end;
/

show error

select postal_code from locations;
select postal_code, as_number(postal_code) from locations;

/* �ٸ�Ǯ�� */
create or replace function as_number1(p_code varchar2)
return number
is num number := 0;
begin
   num := to_number(p_code);
   if num is not null then
   return 1;
   else 
   return 0;
   end if;
exception
   when others then
     return num;
end;
/
select postal_code, as_number1(postal_code) from locations;

/* ���Խ� */
select postal_code 
from locations 
where regexp_like(postal_code,'[^[:digit:]]') --> ���� �ƴ�
or postal_code is null;

select postal_code
from locations
where as_number(postal_code) = 0;

================================================================================

[����43] 1����100���� ���� ���ϴ� �Լ����α׷��� �ۼ��մϴ�.
�� �μ������� 0�� ������ ��ü ���� ���ϰ�, 1�� ������ Ȧ���� ���� ���ϰ�, 
2�� ������ ¦���� ���� ���ϰ�, �ٸ� ���ڰ��� ������ ������ ������ �ؾ� �մϴ�.


<�Լ� ȣ��>
SQL> exec dbms_output.put_line(calc(0))
5050

PL/SQL procedure successfully completed.

SQL> exec dbms_output.put_line(calc(1))
2500

PL/SQL procedure successfully completed.

SQL> exec dbms_output.put_line(calc(2))
2550

PL/SQL procedure successfully completed.

SQL> exec dbms_output.put_line(calc(3))
BEGIN dbms_output.put_line(calc(3)); END;

*
ERROR at line 1:
ORA-20000: �μ������� 0(��ü),1(Ȧ��),2(¦��)���� �Է°��Դϴ�.
ORA-06512: at "HR.CALC", line 23
ORA-06512: at line 1


create or replace function calc(p number)
return number
is sm number := 0;
begin
     for i in 1..100 loop
       if p = 0 then
         sm := sm + i;
       elsif p = 1 and mod(i,2)=1 then
         sm := sm + i;
       elsif p = 2 and mod(i,2)=0 then
         sm := sm + i;
       else
         raise_application_error(-20000,'�μ������� 0(��ü),1(Ȧ��),2(¦��)���� �Է°��Դϴ�.',true);
       end if;
     end loop;
     return sm;
end;
/


create or replace function calc1(p number)
return number
is sm number := 0;
   num number := 100;
begin
  if p = 0 then
    return num*(num+1)*(1/2);
  elsif p = 1 then
    return (num/2)*((num/2)+1)-50;
  elsif p = 2 then
    return (num/2)*((num/2)+1);
  else
    raise_application_error(-20000,'�μ������� 0(��ü),1(Ȧ��),2(¦��)���� �Է°��Դϴ�.',true);
  end if;
end;
/


show error
exec dbms_output.put_line(calc1(0))
exec dbms_output.put_line(calc1(1))
exec dbms_output.put_line(calc1(2))
exec dbms_output.put_line(calc1(3))

/* ������ Ǯ�� */
create or replace function calc(p_id number)
return number
is
	v_sum number := 0;
begin
   
	for i in 1..100 loop
		
		if p_id = 0 then
			v_sum := v_sum + i;
                elsif p_id = 1 and  mod(i,2) <> 0 then
			v_sum := v_sum + i;
		elsif p_id = 2 and mod(i,2) = 0 then
			v_sum := v_sum +i; 
		elsif p_id not in (0,1,2) then
			raise_application_error(-20000,'�μ������� 0(��ü),1(Ȧ��),2(¦��)���� �Է°��Դϴ�.');
		end if;
	end loop;
	return v_sum;
end;
/



create or replace function calc(p_id number)
return number
is
	v_sum number := 0;
begin
   	if p_id = 0 then
      		for i in 1..100 loop
        		v_sum := v_sum + i;
      		end loop;
    	elsif p_id = 1 then
     		for i in 1..100 loop     
        		if mod(i,2) <> 0 then
          			v_sum := v_sum + i;
        		end if;
     		end loop;
    	elsif p_id = 2  then
     		for i in 1..100 loop
       			if mod(i,2) = 0 then
        			v_sum := v_sum + i; 
       			end if;
     		end loop;
	else
		raise_application_error(-20000,'�μ������� 0(��ü),1(Ȧ��),2(¦��)���� �Է°��Դϴ�.');
	end if;
		return v_sum;
end;
/

show error


[����44] �����ȣ�� �Է°����� �޾Ƽ� �� ����� �ҵ������ �������� 1�� ~ 3�� ��ҵ�, 
4�� ~ 8�� �߼ҵ�, �׿� ������ ���ҵ��̶�� ���� ����Ѵ�.

SQL> select employee_id, salary, income(employee_id) income
     from employees;

EMPLOYEE_ID     SALARY INCOME
----------- ---------- ----------
        100      24000 ��ҵ�
        102      17000 ��ҵ�
        101      17000 ��ҵ�
        145      14000 ��ҵ�
        146      13500 �߼ҵ�
        108    13208.8 �߼ҵ�
        205      12008 �߼ҵ�
        
-- ������ ���� dense_rank() over



create or replace function income (p_id number)
return varchar2
is  v_rnk number;
begin
   select e.d_rnk
   into v_rnk
   from(select employee_id id, dense_rank() over(order by salary desc) d_rnk
        from employees) e
   where e.id = p_id;
 
   if v_rnk >= 1 and v_rnk <= 3 then
     return '��ӵ�';
   elsif v_rnk >= 4 and v_rnk <= 8 then
     return '�߼ҵ�';
   else 
     return '���ҵ�';
   end if;
end;
/

show error

select employee_id, salary, income(employee_id) income
from employees;

/* ������ Ǯ�� */
create  or  replace  function  income 
 ( p_id   in  number)
 return   varchar2 
is
     v_rank    number(10);
     v_msg     varchar2(20);
begin
  
   select  sal_rank  into  v_rank
   from (select  employee_id,  
                 dense_rank()  over (order by salary desc) sal_rank
         from  employees)
    where  employee_id = p_id;

   v_msg  :=  case when  v_rank <=3   then  '��ҵ�'  
                             when  v_rank >=4 and v_rank <= 8  then '�߼ҵ�'
                             else  '���ҵ�'  end;
   return v_msg ;
end income ;
/


[����45] factorial �Լ��� �����ϼ���.

0! = 1
1! = 1
2! = 2
3! = 3*2*1
4! = 4*3!

n! = n*(n-1)! /*���ȣ���*/

SQL> select factorial(5) from dual;

FACTORIAL(5)
-----------------------------------------
120

create or replace function factorial(p_n number)
return number
is fac number := 1;
begin
   if p_n = 0 then
     return fac;
   else
     for i in 1..p_n loop
       fac := fac * i;
     end loop;
     return fac;
   end if;
end;
/

show error
select factorial(5) from dual;

/* ���ȣ�� Ǯ�� */

create or replace function factorial(p_n number)
return number
is 
begin
   if p_n = 0 then --> ���ϸ� ���ѷ���
     return 1;
   else
     return p_n * factorial(p_n-1);
   end if;
end;
/

[����46] �Ʒ��� ���� ��� �Ǵ� ���ν����� �����ϼ���.

SQL> exec emp_sum_sal


�μ���ȣ : 10��
200         Whalen      4400      
10�μ� �޿� ����: 4400
=================================
	
�μ���ȣ : 20��
201         Hartstein   13000     
202         Fay         6000      
20�μ� �޿� ����: 19000
=================================
	
�μ���ȣ : 30��
114         Raphaely    11000     
115         Khoo        3100      
116         Baida       2900      
117         Tobias      2800      
118         Himuro      2600      
119         Colmenares  2500      
30�μ� �޿� ����: 24900
=================================
	
�μ���ȣ : 40��
203         Mavris      6500      
40�μ� �޿� ����: 6500
=================================


create or replace procedure emp_sum_sal
is 
   type rec1_type is record(d_id number, sum_sal number);
   type tab1_type is table of rec1_type;
   v_tab1 tab1_type;
begin
    select department_id, sum(salary)
    bulk collect into v_tab1 
    from employees
    group by department_id
    order by department_id;

    for i in v_tab1.first..v_tab1.last loop
    
    dbms_output.put_line('�μ���ȣ : '||v_tab1(i).d_id||'��');
       for v_rec in (select employee_id id, last_name lname, salary sal
                     from employees
                     where department_id = v_tab1(i).d_id) loop
           dbms_output.put_line(v_rec.id||'    '||v_rec.lname||'    '||v_rec.sal);
       end loop;
    dbms_output.put_line(v_tab1(i).d_id||'�μ� �޿� ����: '||v_tab1(i).sum_sal);
    dbms_output.put_line('=================================');
   end loop;
end;
/

show error
exec emp_sum_sal

select department_id, employee_id, last_name, salary
from employees
order by department_id;

select employee_id e_id, last_name lname, salary sal
                     from employees;
                     
select employee_id, salary sal, sum(salary) over(order by department_id) sum_sal
                 from employees;
                 order by department_id;
                 
                 
/* ������ Ǯ�� */

create  or  replace  procedure  emp_sum_sal
 is
 begin
 for  o  in  (select department_id, sum(salary) sumsal from employees
              group by department_id
              order by department_id ) loop
                                    
             dbms_output.put_line( chr(9) );  /* tab key */
 
             dbms_output.put_line('�μ���ȣ : ' || o.department_id ||'��'); 
                                                
  for  i  in  (select employee_id, last_name, salary from employees where department_id = o.department_id) loop

             dbms_output.put_line( rpad(i.employee_id,10,' ' ) || '  ' ||
                                   rpad(i.last_name, 10, ' ' ) || '  ' ||
                                   rpad(i.salary,10,' ') );
  end loop;
            dbms_output.put_line(o.department_id|| '�μ� �޿� ����: ' || o.sumsal );
            dbms_output.put_line('=================================');
end loop;
end emp_sum_sal;
/

exec emp_sum_sal