/*
function
 - return 값을 반환하는 이름이 있는 pl/sql block 입니다.
 - 표현식의 일부로 호출한다.
 
procedure
 - return문은 프로그램 정상적인 종료
 - pl/sql block에서 호출 또는 execute해서 호출해야 한다.
*/
 
drop function tax;

create or replace function tax(p_value in number)--> out모드 의미없음(사용은 가능)
return number
is
begin
    return(p_value * 0.08);
end tax;
/
/* 출력 #1 */
exec dbms_output.put_line(tax(100))

/* 출력 #2 */
var b_num number
exec :b_num := tax(100)
print :b_num

/* 출력 #3 */
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


[문제40] 사원번호를 입력값으로 받아서 그 사원의 근무 년수를 구하는 함수를 생성하세요.
단 없는 사원번호가 들어오면 내가 만든 오류번호,메시지가 출력되도록 해야합니다.

<함수 수행>

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
ORA-20000: 300번 사원은 존재하지 않습니다.
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
     raise_application_error(-20000,p_id||'번 사원은 존재하지 않습니다.',true);
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


[문제41] 부서코드를 입력값으로 받아서 부서이름을 return 하는 함수를 만들어주세요.
부서코드가 없을 경우 '알수없는 부서'가 return해야 합니다.

<함수 수행결과>

SQL> select employee_id, last_name, department_id, dept_name_func(department_id) dept_name
     from employees;

EMPLOYEE_ID LAST_NAME            DEPARTMENT_ID DEPT_NAME
----------- -------------------- ------------- --------------------
        177 Livingston                      80 Sales
        178 Grant                              알수없는 부서


SQL> exec dbms_output.put_line(dept_name_func(20))
Marketing

PL/SQL procedure successfully completed.


create or replace function dept_name_func (p_dept_id number)
return varchar2
deterministic /* PL/SQL 함수전용 힌트 : cache 기능 */
is dname varchar2(30):= '알수 없는 부서';
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

[문제42] 문자타입 컬럼 이지만 테이블에 있는 데이터는 숫자형식만 들어 가 있어야 하는데 
        그렇지 않는 데이터를 확인 하는 함수를 생성하세요. 
        null 또는 문자가 들어 있으면 0출력 숫자는 1 출력하세요.

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

/* 다른풀이 */
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

/* 정규식 */
select postal_code 
from locations 
where regexp_like(postal_code,'[^[:digit:]]') --> 숫자 아닌
or postal_code is null;

select postal_code
from locations
where as_number(postal_code) = 0;

================================================================================

[문제43] 1부터100까지 합을 구하는 함수프로그램을 작성합니다.
단 인수값으로 0이 들어오면 전체 합을 구하고, 1이 들어오면 홀수만 합을 구하고, 
2가 들어오면 짝수만 합을 구하고, 다른 숫자값이 들어오면 오류가 나도록 해야 합니다.


<함수 호출>
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
ORA-20000: 인수값으로 0(전체),1(홀수),2(짝수)값만 입력값입니다.
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
         raise_application_error(-20000,'인수값으로 0(전체),1(홀수),2(짝수)값만 입력값입니다.',true);
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
    raise_application_error(-20000,'인수값으로 0(전체),1(홀수),2(짝수)값만 입력값입니다.',true);
  end if;
end;
/


show error
exec dbms_output.put_line(calc1(0))
exec dbms_output.put_line(calc1(1))
exec dbms_output.put_line(calc1(2))
exec dbms_output.put_line(calc1(3))

/* 선생님 풀이 */
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
			raise_application_error(-20000,'인수값으로 0(전체),1(홀수),2(짝수)값만 입력값입니다.');
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
		raise_application_error(-20000,'인수값으로 0(전체),1(홀수),2(짝수)값만 입력값입니다.');
	end if;
		return v_sum;
end;
/

show error


[문제44] 사원번호를 입력값으로 받아서 그 사원의 소득순위를 기준으로 1위 ~ 3위 고소득, 
4위 ~ 8위 중소득, 그외 순위는 저소득이라는 값을 출력한다.

SQL> select employee_id, salary, income(employee_id) income
     from employees;

EMPLOYEE_ID     SALARY INCOME
----------- ---------- ----------
        100      24000 고소득
        102      17000 고소득
        101      17000 고소득
        145      14000 고소득
        146      13500 중소득
        108    13208.8 중소득
        205      12008 중소득
        
-- 연이은 순위 dense_rank() over



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
     return '고속득';
   elsif v_rnk >= 4 and v_rnk <= 8 then
     return '중소득';
   else 
     return '저소득';
   end if;
end;
/

show error

select employee_id, salary, income(employee_id) income
from employees;

/* 선생님 풀이 */
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

   v_msg  :=  case when  v_rank <=3   then  '고소득'  
                             when  v_rank >=4 and v_rank <= 8  then '중소득'
                             else  '저소득'  end;
   return v_msg ;
end income ;
/


[문제45] factorial 함수를 생성하세요.

0! = 1
1! = 1
2! = 2
3! = 3*2*1
4! = 4*3!

n! = n*(n-1)! /*재귀호출식*/

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

/* 재귀호출 풀이 */

create or replace function factorial(p_n number)
return number
is 
begin
   if p_n = 0 then --> 안하면 무한루프
     return 1;
   else
     return p_n * factorial(p_n-1);
   end if;
end;
/

[문제46] 아래와 같이 출력 되는 프로시저를 생성하세요.

SQL> exec emp_sum_sal


부서번호 : 10번
200         Whalen      4400      
10부서 급여 총합: 4400
=================================
	
부서번호 : 20번
201         Hartstein   13000     
202         Fay         6000      
20부서 급여 총합: 19000
=================================
	
부서번호 : 30번
114         Raphaely    11000     
115         Khoo        3100      
116         Baida       2900      
117         Tobias      2800      
118         Himuro      2600      
119         Colmenares  2500      
30부서 급여 총합: 24900
=================================
	
부서번호 : 40번
203         Mavris      6500      
40부서 급여 총합: 6500
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
    
    dbms_output.put_line('부서번호 : '||v_tab1(i).d_id||'번');
       for v_rec in (select employee_id id, last_name lname, salary sal
                     from employees
                     where department_id = v_tab1(i).d_id) loop
           dbms_output.put_line(v_rec.id||'    '||v_rec.lname||'    '||v_rec.sal);
       end loop;
    dbms_output.put_line(v_tab1(i).d_id||'부서 급여 총합: '||v_tab1(i).sum_sal);
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
                 
                 
/* 선생님 풀이 */

create  or  replace  procedure  emp_sum_sal
 is
 begin
 for  o  in  (select department_id, sum(salary) sumsal from employees
              group by department_id
              order by department_id ) loop
                                    
             dbms_output.put_line( chr(9) );  /* tab key */
 
             dbms_output.put_line('부서번호 : ' || o.department_id ||'번'); 
                                                
  for  i  in  (select employee_id, last_name, salary from employees where department_id = o.department_id) loop

             dbms_output.put_line( rpad(i.employee_id,10,' ' ) || '  ' ||
                                   rpad(i.last_name, 10, ' ' ) || '  ' ||
                                   rpad(i.salary,10,' ') );
  end loop;
            dbms_output.put_line(o.department_id|| '부서 급여 총합: ' || o.sumsal );
            dbms_output.put_line('=================================');
end loop;
end emp_sum_sal;
/

exec emp_sum_sal