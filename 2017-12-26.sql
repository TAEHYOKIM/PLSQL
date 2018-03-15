[문제57] 부서 코드를 입력값으로 받아서 그 부서 사원들의 번호, 급여, 근무년수, 부서이름을 
        출력하는 프로시저를 만드세요. (단, bulk collect into 절을 사용하세요.)


<화면 출력>

SQL> exec dept_year_proc(30)

번호: 114 급여: 11000 근무년수: 15 부서이름: Purchasing
번호: 115 급여: 3100 근무년수: 14 부서이름: Purchasing
번호: 116 급여: 2900 근무년수: 12 부서이름: Purchasing
번호: 117 급여: 2800 근무년수: 12 부서이름: Purchasing
번호: 118 급여: 2600 근무년수: 11 부서이름: Purchasing
번호: 119 급여: 2500 근무년수: 10 부서이름: Purchasing

SQL> exec dept_year_proc(120)

120 부서는 존재하지 않습니다.

PL/SQL procedure successfully completed.

SELECT employee_id,
  salary,
  TRUNC(months_between(sysdate,hire_date)/12),
  (SELECT department_name
  FROM departments
  WHERE department_id = e.department_id
  )
FROM employees e
WHERE department_id = 30;

SELECT e.employee_id,
  e.salary,
  TRUNC(months_between(sysdate,e.hire_date)/12),
  d.department_name
FROM employees e,
  departments d
WHERE e.department_id = 30
AND d.department_id   = 30;

create or replace procedure dept_year_proc(p_num number)
is
   type rec_type is record(e_id employees.employee_id%type,
                           sal employees.salary%type,
                           years number,
                           dname departments.department_name%type);
   type tab_type is table of rec_type;
   v_tab tab_type;
begin
   select employee_id, salary, trunc(months_between(sysdate,hire_date)/12), 
       (select department_name
        from departments
        where department_id = e.department_id)
   bulk collect into v_tab
   from employees e
   where department_id = p_num;
   
   if sql%found then
      for i in v_tab.first..v_tab.last loop
         dbms_output.put_line('번호: '||v_tab(i).e_id||' 급여: '||v_tab(i).sal||
                           ' 근무년수: '||v_tab(i).years||' 부서이름: '||v_tab(i).dname);
      end loop;
   else
      dbms_output.put_line(p_num||' 부서는 존재하지 않습니다.');
   end if;
end;
/

show error
exec dept_year_proc(30)
exec dept_year_proc(120)