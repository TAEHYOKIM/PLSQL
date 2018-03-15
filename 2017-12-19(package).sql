/* package 
- 논리적으로 관련된 pl/sql 변수, 타입, 서브프로그램(프로시저, 함수)을 
  그룹화하는 객체 프로그램이다. 
  (관련성 있는 생성자들 모아둠, 찾기편해 수정편해 유지관리 좋아 종속관계도 좋아)
- 배열 리턴 안되기 때문에 이 걸 사용하자!

- 두가지 구조 만든다
  1. specification(spec) : public
  2. body : private
*/

-- 1. spec(public) 선언만 한다 : 필수(바디없는 스팩 가능), 공개가능만 작성
create or replace package comm_package
is 
    g_comm number := 0.1;
    procedure reset_comm(v_comm in number);
end comm_package;
/

-- 2. body(private) 정의한다 : 옵션, 비공개 내용
create or replace package body comm_package
is
     function validate_comm(v_c in number)
           return boolean
     is 
           v_max_comm number;
     begin 
           select max(commission_pct)
           into v_max_comm
           from employees;
           if v_c > v_max_comm then return(FALSE);
           else return(TRUE);
           end if;
     end validate_comm;
     
     procedure reset_comm(v_comm in number)
     is
     begin
         if validate_comm(v_comm) /*전방참조만 가능(바깥도 가능) 만약 뒤에 있어도 헤드부분만이라도*/
         then
            dbms_output.put_line('old : '||g_comm);
            g_comm := v_comm;
            dbms_output.put_line('new : '||g_comm);
         else 
            raise_application_error(-20000,'invalid commission');
         end if;
     end reset_comm;
end comm_package;
/

    
create or replace package body comm_package
is
     function validate_comm(v_c in number) --> 헤드만 있어도 컴파일 오류 안남
           return boolean;
     procedure reset_comm(v_comm in number)
     is
     begin
         if validate_comm(v_comm) /* 표현식 함수라서 가능 프로시저는 안됨 */
         then
            dbms_output.put_line('old : '||g_comm);
            g_comm := v_comm;
            dbms_output.put_line('new : '||g_comm);
         else 
            raise_application_error(-20000,'invalid commission');
         end if;
     end reset_comm;
     
     function validate_comm(v_c in number)
           return boolean
     is 
           v_max_comm number;
     begin 
           select max(commission_pct)
           into v_max_comm
           from employees;
           if v_c > v_max_comm then return(FALSE);
           else return(TRUE);
           end if;
     end validate_comm;
     
end comm_package;
/ 
show error

desc comm_package; /*spec 내용만 보임*/

-- reset_comm() 호출
exec comm_package.reset_comm(0.15)


--------------------------------------------------------------------------------

/* 상수 표준화

1 mile = 1.6093 kilo
1 kilo = 0.6214 mile
1 yard = 0.9144 meter
1 meter = 1.0936 yard
*/

/* spec 만 만든경우 : 상수를 표준화 해야 할 때 */

CREATE OR REPLACE PACKAGE global_consts IS
	c_mile_2_kilo  CONSTANT NUMBER := 1.6093;
	c_kilo_2_mile  CONSTANT NUMBER := 0.6214;
	c_yard_2_meter CONSTANT NUMBER := 0.9144;
	c_meter_2_yard CONSTANT NUMBER := 1.0936;
END global_consts;
/



BEGIN
	DBMS_OUTPUT.PUT_LINE('20 mile = ' || 20 * global_consts.c_mile_2_kilo || ' km');
END;
/

20 mile = 32.186 km


BEGIN
	DBMS_OUTPUT.PUT_LINE('20 Kilo = ' || 20 * global_consts.c_kilo_2_mile || ' mi');
END;
/

20 Kilo = 12.428 mi



BEGIN
	DBMS_OUTPUT.PUT_LINE('20 yard = ' || 20 * global_consts.c_yard_2_meter || ' m');
END;
/

20 yard = 18.288 m



BEGIN
	DBMS_OUTPUT.PUT_LINE('20 meter = ' || 20 * global_consts.c_meter_2_yard || ' yd');
END;
/


20 meter = 21.872 yd





CREATE OR REPLACE FUNCTION mtr_to_yrd(p_m NUMBER) RETURN NUMBER IS
BEGIN
	RETURN (p_m * global_consts.c_meter_2_yard);
END mtr_to_yrd;
/



EXECUTE DBMS_OUTPUT.PUT_LINE(mtr_to_yrd(100))

109.36


/* 오류번호는 있는데 이름이 없는 예외사항 처리도 표준화 작업 */

--------------------------------------------------------------------------------
/*
<Package Overloading> : 객체지향 특징, 동일한 이름의 생성자를 만들수 있음
                        단, 패키지 내부에서 있어야지 됨
*/

CREATE OR REPLACE PACKAGE pack_over_init
IS
	TYPE date_tab_type IS TABLE OF TIMESTAMP INDEX BY BINARY_INTEGER;
	TYPE num_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	PROCEDURE init(tab OUT date_tab_type, n number); /* 형식매개변수 갯수, 모드, 타입이 틀려야 오버로딩 가능*/
	PROCEDURE init(tab OUT num_tab_type, n number); /* to_charactor*/
END pack_over_init;
/


CREATE OR REPLACE PACKAGE BODY pack_over_init
IS
	PROCEDURE init(tab OUT date_tab_type, n number)
	IS
	BEGIN
		FOR i IN 1..n LOOP
			tab(i) := SYSTIMESTAMP;
		END LOOP;
	END init;

	PROCEDURE init(tab OUT num_tab_type, n number)
	IS
	BEGIN
		FOR i IN 1..n LOOP
			tab(i) := i;
		END LOOP;
	END init;
END pack_over_init;	
/

<<Package 실행>> 
SQL> set serveroutput on

DECLARE
	hiredate_tab	pack_over_init.date_tab_type; /* package.data type */
	sal_tab		pack_over_init.num_tab_type;
	indx		BINARY_INTEGER;
BEGIN
	indx := 5;
	pack_over_init.init(hiredate_tab, indx);
	pack_over_init.init(sal_tab, indx);
	FOR i IN 1..indx LOOP
		dbms_output.put_line(TO_CHAR(hiredate_tab(i)));
		dbms_output.put_line(TO_CHAR(sal_tab(i)));
	END LOOP;
END;
/


================================================================================

[문제47] 사원번호 또는 사원이름을 입력값으로 받아서 사원번호, 이름, 부서이름을 출력하는 패키지를 생성하세요.
       

SQL> execute emp_find.find(100)
사원번호: 100 사원이름: King 부서이름: Executive

PL/SQL procedure successfully completed.

SQL> execute emp_find.find(500)
500사원은 존재하지 않습니다.

PL/SQL procedure successfully completed.


SQL> execute emp_find.find('king')
사원번호: 156 사원이름: King 부서이름: Sales
사원번호: 100 사원이름: King 부서이름: Executive

PL/SQL procedure successfully completed.

SQL> execute emp_find.find('de haan')
사원번호: 102 사원이름: De Haan 부서이름: Executive

PL/SQL procedure successfully completed.

SQL> execute emp_find.find('hong')
Hong사원은 존재하지 않습니다.

PL/SQL procedure successfully completed.


-- procedure

create or replace package emp_find
is 
  procedure find(p_id number);
  procedure find(p_nm varchar2);
end emp_find;
/

create or replace package body emp_find
is
  procedure find(p_id number)
  is
      type rec_type is record(l_nm varchar2(30), d_nm varchar2(30));
      type tab_type is table of rec_type;
      v_tab tab_type;
  begin
      select last_name, (select department_name
                         from departments
                         where department_id = e.department_id)
      bulk collect into v_tab
      from employees e
      where employee_id = p_id;
      
      if sql%notfound then
         raise no_data_found;
      end if;
      
      for i in v_tab.first..v_tab.last loop
         dbms_output.put_line('사원번호: '||p_id||' 사원이름: '||v_tab(i).l_nm||' 부서이름: '||v_tab(i).d_nm);
      end loop;
  exception
      when no_data_found then
         dbms_output.put_line(p_id||'사원은 존재하지 않습니다.');
  end find;

  procedure find(p_nm varchar2)
  is
      type rec_type is record(e_id number, d_nm varchar2(30));
      type tab_type is table of rec_type;
      v_tab tab_type;
  begin
      select employee_id, (select department_name
                         from departments
                         where department_id = e.department_id)
      bulk collect into v_tab
      from employees e
      where last_name = initcap(p_nm);
      
      if sql%notfound then
         raise no_data_found;
      end if;
      
      for i in v_tab.first..v_tab.last loop
         dbms_output.put_line('사원번호: '||v_tab(i).e_id||' 사원이름: '||p_nm||' 부서이름: '||v_tab(i).d_nm);
      end loop;
  exception
      when no_data_found then
         dbms_output.put_line(p_nm||'사원은 존재하지 않습니다.');
  end find;
end emp_find;
/
show error
execute emp_find.find(100)
execute emp_find.find(500)
execute emp_find.find('king')
execute emp_find.find('de haan')
execute emp_find.find('hong')
execute emp_find.find('grant')


/* 선생님 풀이 */

create or replace package emp_find
is
  procedure find(p_id    in  number);
  procedure find(p_name  in  varchar2);
end emp_find;
/

create or replace package body emp_find
is
  procedure find(p_id in number)
  is
    v_name          employees.last_name%type;
    v_dept_name	departments.department_name%type;
   begin
    select e.last_name, d.department_name
    into v_name, v_dept_name
    from employees e, departments d
    where e.department_id = d.department_id
    and e.employee_id = p_id;
    
    dbms_output.put_line('사원번호 : '||p_id||'  사원 이름 : '||v_name||'  부서이름 : '||v_dept_name);
  exception
    when no_data_found then 
      dbms_output.put_line(p_id||'사원은 존재하지 않습니다.');
    when others then 
      dbms_output.put_line(SQLERRM);
  end find;
  
  procedure find(p_name varchar2) 
  is
    cursor c1 is 
        select employee_id, last_name, (select department_name from departments 
						where department_id = e.department_id) department_name
        from  employees e
        where last_name = initcap(p_name);
     v_rec c1%rowtype;
  begin
    open c1;
 
    fetch c1 into v_rec;
      if c1%notfound then 
         dbms_output.put_line(initcap(p_name) || ' 사원은 존재하지 않습니다.');
      else
         dbms_output.put_line('사원번호 : '||rpad(v_rec.employee_id,20)
                                           ||' 사원 이름 : '||rpad(v_rec.last_name,20)
                                           ||' 부서이름 : '||rpad(v_rec.department_name,20));
         loop
            fetch c1 into v_rec;
              if  c1%found then  
                dbms_output.put_line('사원번호 : '||rpad(v_rec.employee_id,20)
                                           ||' 사원 이름 : '||rpad(v_rec.last_name,20)
                                           ||' 부서이름 : '||rpad(v_rec.department_name,20));
              else
                exit;
              end if;
         end loop;
       end if;
    close c1;
  end find;
end emp_find;
/

[문제48]
emp_find package 프로그램에 년월일을 입력하면 그 년도에 입사한 사원들의 정보를 출력하는 
find 프로그램을 추가해주세요.

SQL> exec emp_find.find('2003-01-01')
2003-01-01 사원은 존재하지 않습니다.


SQL> exec emp_find.find(to_date('2003-01-01','yyyy-mm-dd'))
사원번호 : 200                  사원 이름 : Whalen               부서이름 : Administration       입사일 : 03/09/17
사원번호 : 115                  사원 이름 : Khoo                 부서이름 : Purchasing           입사일 : 03/05/18
사원번호 : 141                  사원 이름 : Rajs                 부서이름 : Shipping             입사일 : 03/10/17
사원번호 : 137                  사원 이름 : Ladwig               부서이름 : Shipping             입사일 : 03/07/14
사원번호 : 122                  사원 이름 : Kaufling             부서이름 : Shipping             입사일 : 03/05/01
사원번호 : 100                  사원 이름 : King                 부서이름 : Executive            입사일 : 03/06/17


SQL> exec emp_find.find(to_date('2000-01-01','yyyy-mm-dd'))
2000 년도의 사원은 존재하지 않습니다.

PL/SQL procedure successfully completed.


-- 주의 overload 형식매개변수 갯수, 모드, 타입 달라야 함

create or replace package emp_find
is 
  procedure find(p_id number);
  procedure find(p_nm varchar2);
  procedure find(p_hd date);
end emp_find;
/

create or replace package body emp_find
is
  procedure find(p_id number)
  is
      type rec_type is record(l_nm varchar2(30), d_nm varchar2(30));
      type tab_type is table of rec_type;
      v_tab tab_type;
  begin
      select last_name, (select department_name
                         from departments
                         where department_id = e.department_id)
      bulk collect into v_tab
      from employees e
      where employee_id = p_id;
      
      if sql%notfound then
         raise no_data_found;
      end if;
      
      for i in v_tab.first..v_tab.last loop
         dbms_output.put_line('사원번호: '||p_id||' 사원이름: '||v_tab(i).l_nm||' 부서이름: '||v_tab(i).d_nm);
      end loop;
  exception
      when no_data_found then
         dbms_output.put_line(p_id||'사원은 존재하지 않습니다.');
  end find;

  procedure find(p_nm varchar2)
  is
      type rec_type is record(e_id number, d_nm varchar2(30));
      type tab_type is table of rec_type;
      v_tab tab_type;
  begin
      select employee_id, (select department_name
                         from departments
                         where department_id = e.department_id)
      bulk collect into v_tab
      from employees e
      where last_name = initcap(p_nm);
      
      if sql%notfound then
         raise no_data_found;
      end if;
      
      for i in v_tab.first..v_tab.last loop
         dbms_output.put_line('사원번호: '||v_tab(i).e_id||' 사원이름: '||p_nm||' 부서이름: '||v_tab(i).d_nm);
      end loop;
  exception
      when no_data_found then
         dbms_output.put_line(p_nm||'사원은 존재하지 않습니다.');
  end find;
  
  procedure find(p_hd date)
  is
      type rec_type is record(e_id number, l_nm varchar2(30), d_nm varchar2(30), h_dt date);
      type tab_type is table of rec_type;
      v_tab tab_type;
  begin
      select employee_id, last_name,
                        (select department_name
                         from departments
                         where department_id = e.department_id),
                         hire_date
      bulk collect into v_tab
      from employees e
      where hire_date >= trunc(p_hd,'year') /* 해당 년도의 1월 1일 */ 
      and hire_date < trunc(add_months(p_hd,12),'year'); /* 해당 년도의 내년 1월 1일 */
      
      if sql%notfound then
         raise no_data_found;
      end if;
      
      for i in v_tab.first..v_tab.last loop
         dbms_output.put_line('사원번호: '||v_tab(i).e_id||' 사원이름: '||v_tab(i).l_nm||' 부서이름: '||v_tab(i).d_nm||
                              '입사일 : '||v_tab(i).h_dt);
      end loop;
  exception
      when no_data_found then
         dbms_output.put_line(to_char(p_hd,'yyyy')||'년도의 사원은 존재하지 않습니다.');
  end find;  
end emp_find;
/
show error

exec emp_find.find(to_date('2003-12-19','yyyy-mm-dd'))
exec emp_find.find(to_date('2000-10-01','yyyy-mm-dd'))
exec emp_find.find(to_date('2007-01-01','yyyy-mm-dd'))

exec emp_find.find('king')
exec emp_find.find('2003-12-19')

select to_date('2003-03-16','yyyy-mm-dd') from dual;

select
to_date(to_char(to_date('2003-12-19','yyyy-mm-dd'),'yyyy'),'yy')
from dual;
select trunc(to_date('2003-12-19','yyyy-mm-dd'), 'year') from dual;
select add_months(trunc(to_date('2003-12-30','yyyy-mm-dd'), 'year'), 12) from dual;

select to_date('2003','yyyy') from dual; --> 시스템 작동한 해당월 1일로 나옴

/* 선생님 풀이 */
  procedure find(p_day date) 
  is
  
    cursor c1 is 
        select employee_id, last_name, (select department_name from departments 
						where department_id = e.department_id) department_name, hire_date
        from  employees e
        where hire_date  >= trunc(p_day,'year')
        and hire_date < trunc(add_months(p_day,12),'year');
     v_rec c1%rowtype;
  begin
    open c1;
 
    fetch c1 into v_rec;
      if c1%notfound then 
         dbms_output.put_line(to_char(p_day,'yyyy') || ' 년도의 사원은 존재하지 않습니다.');
      else
          dbms_output.put_line('사원번호 : '||rpad(v_rec.employee_id,20)
                                           ||' 사원 이름 : '||rpad(v_rec.last_name,20)
                                           ||' 부서이름 : '||rpad(nvl(v_rec.department_name,' '),20)
                                           ||' 입사일 : '  || v_rec.hire_date);
         loop
            fetch c1 into v_rec;
              if  c1%found then  
                 dbms_output.put_line('사원번호 : '||rpad(v_rec.employee_id,20)
                                           ||' 사원 이름 : '||rpad(v_rec.last_name,20)
                                           ||' 부서이름 : '||rpad(nvl(v_rec.department_name,' '),20)
                                           ||' 입사일 : '  || v_rec.hire_date);
              else
                exit;
              end if;
         end loop;
       end if;
    close c1;
  end find;
  
================================================================================

/* 패키지 커서 지속상태 : 커서가 exec 끝나고 자동 닫히는게 아니라 계속 열려있어라 참깨
<瘤加惑?-菩虐瘤 目?>
*/

CREATE OR REPLACE PACKAGE pack_cur
IS	
  PROCEDURE open;
	PROCEDURE next(p_num1 number,p_num2 number);
	PROCEDURE close;
END pack_cur;
/

CREATE OR REPLACE PACKAGE BODY pack_cur
IS
	CURSOR c1 IS  
		SELECT  employee_id, last_name
		FROM    employees
		ORDER BY employee_id DESC;
	v_empno NUMBER;
	v_ename VARCHAR2(10);
  
  PROCEDURE open 
  IS  
	BEGIN  
			IF NOT c1%isopen then
          OPEN c1; /*c1이름으로 메모리 활당 ->...->active set 결과*/
          dbms_output.put_line('c1 cursor open');
      END IF;
  END open;
/*
	PROCEDURE next(p_num number)
  IS  
	BEGIN  
		LOOP 
		    FETCH c1 INTO v_empno, v_ename;
		    DBMS_OUTPUT.PUT_LINE('Id :' ||v_empno||'  Name :' ||v_ename);
		    EXIT WHEN c1%ROWCOUNT >= p_num;
		END LOOP;
	END next;
*/
	PROCEDURE next(p_num1 number, p_num2 number)
  IS 
	BEGIN
    if p_num1 < p_num2 then
		  for i in p_num1..p_num2 loop
		    FETCH c1 INTO v_empno, v_ename;
		    DBMS_OUTPUT.PUT_LINE('Id :' ||v_empno||'  Name :' ||v_ename);
		  END LOOP;
    else 
      dbms_output.put_line(p_num2||','||p_num1||'순서로 재기입');
    end if;
	END next;

	PROCEDURE close IS /* 패키지 내에서는 커서 계속 열려 있음(세션이 켜저 있는 동안) */
	BEGIN
			IF c1%isopen then
          			close c1;
				dbms_output.put_line('c1 cursor close');
      			END IF;
	END close;
END pack_cur;
/

show error
<<Package 실행>>
/*
SQL> SET SERVEROUTPUT ON 
         
SQL> EXECUTE pack_cur.open
c1 cursor open

PL/SQL procedure successfully completed.
   
SQL> EXECUTE pack_cur.next(3)
Id :206  Name :Gietz
Id :205  Name :Higgins
Id :204  Name :Baer

PL/SQL procedure successfully completed.


SQL> EXECUTE pack_cur.next(6)
Id :203  Name :Mavris
Id :202  Name :Fay
Id :201  Name :Hartstein

PL/SQL procedure successfully completed.

SQL> EXECUTE pack_cur.close
c1 cursor close

PL/SQL procedure successfully completed.  
*/

exec pack_cur.open
exec pack_cur.next(1,5)
exec pack_cur.close

================================================================================

/* PRAGMA_SERIALLY_REUSABLE */

CREATE OR REPLACE PACKAGE  comm_package 
IS
	PRAGMA SERIALLY_REUSABLE; --> 지시어(명령어), 스펙에서 선언한 글로벌 변수 유효기간 호출하는 동안만!

	g_comm	NUMBER := 0.1;
	PROCEDURE  reset_comm (v_comm   in  NUMBER);
  FUNCTION  validate_comm (v_comm   IN   NUMBER)
    return boolean;
END comm_package;
/
show error
CREATE OR REPLACE PACKAGE BODY comm_package
IS
  	PRAGMA SERIALLY_REUSABLE; --> 스펙&바디 같이 기술해야 함

	FUNCTION  validate_comm (v_comm   IN   NUMBER)
    	  RETURN BOOLEAN
  	IS
    		v_max_comm    NUMBER;
  	BEGIN        
    		SELECT   max(commission_pct)  INTO     v_max_comm
    		FROM     employees; /* max(commission_pct) : 0.4 */
    		
 		IF   v_comm > v_max_comm 
    		THEN   RETURN(FALSE);
    		ELSE   RETURN(TRUE);
    		END IF;
  	END validate_comm;

  	PROCEDURE  reset_comm (v_comm   IN  NUMBER)
 	IS
   	BEGIN
    		IF  validate_comm(v_comm) 
   		THEN
			dbms_output.put_line('OLD: '||g_comm);
			g_comm:=v_comm;
			dbms_output.put_line('NEW: '||g_comm);
		ELSE
       			RAISE_APPLICATION_ERROR (-20210,'Invalid commission');
    		END IF;
  	END reset_comm;

END comm_package;
/


SQL> SET SERVEROUTPUT ON

SQL> EXECUTE comm_package.reset_comm(0.15)
OLD: .1
NEW: .15

PL/SQL procedure successfully completed.

SQL> EXECUTE comm_package.reset_comm(0.25)
OLD: .1
NEW: .25

PL/SQL procedure successfully completed.

SQL> EXECUTE comm_package.g_comm := 0.3

PL/SQL procedure successfully completed.

SQL>  EXECUTE comm_package.reset_comm(0.2)
OLD: .1
NEW: .2

PL/SQL procedure successfully completed.

/*test*/
select max(commission_pct) from employees;
exec comm_package.reset_comm(0.39)
exec dbms_output.put_line(comm_package.validate_comm(0.1))

begin
dbms_output.put_line(comm_package.validate_comm(0.1));
end;
/

/* function만 별도로 */
begin
if comm_package.validate_comm(1.1) then
  dbms_output.put_line('TRUE');
else
  dbms_output.put_line('FALSE');
end if;
end;
/

select * from user_objects;