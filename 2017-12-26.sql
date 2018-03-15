[����57] �μ� �ڵ带 �Է°����� �޾Ƽ� �� �μ� ������� ��ȣ, �޿�, �ٹ����, �μ��̸��� 
        ����ϴ� ���ν����� ���弼��. (��, bulk collect into ���� ����ϼ���.)


<ȭ�� ���>

SQL> exec dept_year_proc(30)

��ȣ: 114 �޿�: 11000 �ٹ����: 15 �μ��̸�: Purchasing
��ȣ: 115 �޿�: 3100 �ٹ����: 14 �μ��̸�: Purchasing
��ȣ: 116 �޿�: 2900 �ٹ����: 12 �μ��̸�: Purchasing
��ȣ: 117 �޿�: 2800 �ٹ����: 12 �μ��̸�: Purchasing
��ȣ: 118 �޿�: 2600 �ٹ����: 11 �μ��̸�: Purchasing
��ȣ: 119 �޿�: 2500 �ٹ����: 10 �μ��̸�: Purchasing

SQL> exec dept_year_proc(120)

120 �μ��� �������� �ʽ��ϴ�.

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
         dbms_output.put_line('��ȣ: '||v_tab(i).e_id||' �޿�: '||v_tab(i).sal||
                           ' �ٹ����: '||v_tab(i).years||' �μ��̸�: '||v_tab(i).dname);
      end loop;
   else
      dbms_output.put_line(p_num||' �μ��� �������� �ʽ��ϴ�.');
   end if;
end;
/

show error
exec dept_year_proc(30)
exec dept_year_proc(120)