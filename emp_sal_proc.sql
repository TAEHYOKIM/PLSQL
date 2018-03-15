-- 소스코드 암호화 실습 --

create or replace procedure emp_sal_proc(p_id number, p_sal number)
is
	v_job varchar2(30);
	v_minsal number;
	v_maxsal number;
begin
 
	select e.job_id,j.min_salary, j.max_salary
	into v_job, v_minsal, v_maxsal
	from jobs j , employees e
	where e.job_id = j.job_id
	and e.employee_id = p_id;

  IF p_sal NOT BETWEEN v_minsal AND v_maxsal THEN
      RAISE_APPLICATION_ERROR(-20100, 'Invalid salary $' ||p_sal ||'. '
      || 'Salaries for job '|| v_job ||' must be between $'|| v_minsal ||' and $' || v_maxsal);
  ELSE
    update employees
    set salary = p_sal
    where employee_id = p_id;
  END IF;
END;
/