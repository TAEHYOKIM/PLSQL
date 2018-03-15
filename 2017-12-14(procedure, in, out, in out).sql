[문제32] 전체 사원 들의 사번, 이름, 급여, 입사일, 근무연수를 출력합니다.
또한 근무연수가 13년 이상이고 급여는 10000 미만인 사원들은 예외사항이 발생하도록 한 후 
메시지 출력하고  프로그램 수행이 완료된 후에 분석할수있도록  years 테이블에 정보가 입력이 
되도록 프로그램을 작성합니다. 근무연수는 소수점은 버리세요

SQL> create table years(id number, name varchar2(30), sal number, year number);


<화면 출력>
....

201, Hartstein, 13000, 04/02/17, 12
202, Fay, 6000, 05/08/17, 10
203, Mavris, 6500, 02/06/07, 13
사원 203 근무연수는 13 년이고 급여는 6500 입니다.
204, Baer, 10000, 02/06/07, 13
205, Higgins, 12008, 02/06/07, 13
206, Gietz, 8300, 02/06/07, 13
사원 206 근무연수는 13 년이고 급여는 8300 입니다.

....


SQL> select * from years;


-- 근무연수 >= 13 and 급여 < 10000
-- user-defined exception
-- subblock or 

create table years(id number, name varchar2(30), sal number, year number);

declare
     u_def_e1 exception;
     type rec_type is record(id number, lname varchar2(30), sal number, 
                             hdate date, year number);
     type tab_type is table of rec_type;
     v_tab tab_type;
begin
       select employee_id, last_name, salary, hire_date,
              trunc((months_between(sysdate,hire_date))/12)
       bulk collect into v_tab
       from employees;
       
       for i in v_tab.first..v_tab.last loop          
         dbms_output.put_line(v_tab(i).id||', '||v_tab(i).lname||
         ', '||v_tab(i).sal||', '||v_tab(i).hdate||', '||v_tab(i).year);       
    
    begin
      if v_tab(i).year >= 13 and v_tab(i).sal < 10000 then
          raise u_def_e1;
      end if; 
    exception
      when u_def_e1 then
         dbms_output.put_line('사원 '||v_tab(i).id||' 근무연수는 '||v_tab(i).year||
         '년이고 급여는 '||v_tab(i).sal||'입니다.');
         insert into years(id, name, sal, year)
         values(v_tab(i).id, v_tab(i).lname, v_tab(i).sal, v_tab(i).year);
    end;
   
      end loop;
end;
/

select * from years;
rollback;


/* 선생님 풀이 */

SELECT employee_id,last_name, salary, hire_date, trunc(months_between(sysdate,hire_date)/12) year
FROM employees;

DECLARE
	e_raise EXCEPTION;
BEGIN
  FOR emp_rec IN (SELECT employee_id,last_name, salary, hire_date, trunc(months_between(sysdate,hire_date)/12) year
		  FROM employees) LOOP
	DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id||', '||emp_rec.last_name||', '||emp_rec.salary||', '
			     ||emp_rec.hire_date||', '||emp_rec.year);

	BEGIN
	 IF  emp_rec.year >= 13 AND emp_rec.salary < 10000 THEN
		RAISE e_raise;
         END IF;

        EXCEPTION
	  WHEN e_raise THEN
 		DBMS_OUTPUT.PUT_LINE('사원 '||emp_rec.employee_id 
                                  ||' 근무연수는 '||emp_rec.year||' 년이고 급여는 '
                                  || emp_rec.salary||' 입니다.');
                insert into years(id,name,sal,year)
                values(emp_rec.employee_id,emp_rec.last_name,emp_rec.salary,emp_rec.year);
                commit;
       END;

  END LOOP;
END;
/


SQL> select * from years;


SQL> truncate table years;


BEGIN
  FOR emp_rec IN (SELECT employee_id,last_name, salary, hire_date, trunc(months_between(sysdate,hire_date)/12) year
		  FROM employees) LOOP
	DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id||', '||emp_rec.last_name||', '||emp_rec.salary||', '
			     ||emp_rec.hire_date||', '||emp_rec.year);

	
	 IF  emp_rec.year >= 13 AND emp_rec.salary < 10000 THEN
		DBMS_OUTPUT.PUT_LINE('사원 '||emp_rec.employee_id 
                                  ||' 근무연수는 '||emp_rec.year||' 년이고 급여는 '
                                  || emp_rec.salary||' 입니다.');
                insert into years(id,name,sal,year)
                values(emp_rec.employee_id,emp_rec.last_name,emp_rec.salary,emp_rec.year);
                commit;
         END IF;
    
  END LOOP;
END;
/


[문제33] 전체 사원 들의 사번, 이름, 급여, 입사일, 근무연수를 출력합니다.
또한 근무연수가 13년 이상이고 급여는 10000 미만인 사원들은 메시지 출력하고  
프로그램 수행이 완료된 후에 분석할수있도록  years 테이블에 정보가 입력이 되도록 
프로그램을 작성합니다. 근무연수는 소수점은 버리세요. 
(bulk collect into 절을 이용하세요./exception 이용안함);


declare
     type rec_type is record(id number, lname varchar2(30), sal number, 
                             hdate date, year number);
     type tab_type is table of rec_type index by binary_integer;
     v_tab tab_type;
begin
       select /*+ full(e) parallel(e,2) */employee_id, last_name, salary, hire_date,
              trunc((months_between(sysdate,hire_date))/12)
       bulk collect into v_tab --> bulk는 요소번호 1부터 시작(크기 2GB), 그 이상은 자동 페이징 처리
       from employees e;
       
       for i in v_tab.first..v_tab.last loop          
         dbms_output.put_line(v_tab(i).id||', '||v_tab(i).lname||
         ', '||v_tab(i).sal||', '||v_tab(i).hdate||', '||v_tab(i).year);       
    
         if v_tab(i).year >= 13 and v_tab(i).sal < 10000 then
           dbms_output.put_line('사원 '||v_tab(i).id||' 근무연수는 '||v_tab(i).year||
           '년이고 급여는 '||v_tab(i).sal||'입니다.');
           insert into years(id, name, sal, year)
           values(v_tab(i).id, v_tab(i).lname, v_tab(i).sal, v_tab(i).year);
         end if; 
      end loop;
end;
/

select * from years;
rollback;

/*
# bulk collect into 로 변수에 데이터 로드하면 20억개(2G개) 까지밖에 안되므로 데이터 
  쪼개서 처리해야 함(힌트: rownum)
  대용량이면 full paralled 힌트 /*+ full(e) parallel(e.2n) */ -- n∈Ｎ


================================================================================

/* 사원번호를 입력값으로 받아서 그 사원 정보를 출력하는 프로그램 */


select * from employees where employee_id = 입력변수;  --> 암시적 커서
select * from employees where department_id = 20;     --> 명시적 커서

/* 익명블럭 구조 : 입력변수 처리하는 기능 없다? */

var b_id number
exec :b_id := 500 --> 바인드변수는 툴에 종속되는 단점이 있음

declare
   v_rec employees%rowtype;  
begin
   select * 
   into v_rec
   from employees where employee_id = :b_id;
      dbms_output.put_line(v_rec.last_name||v_rec.first_name);
exception
   when no_data_found then
      dbms_output.put_line(:b_id||' 사원은 없습니다.');
end;
/
/* 이 프로그램은 나만 쓸수 있는게 단점, 유지보수도 힘듬
shared pool meemory - library cache 에 실행문 저장(재실행 대비, 없으면 컴파일 해야함) 
익명블럭 구조는 매번 수행할 때 마다 컴파일 해야되는 단점이 있음
(경우에 따라 자주 사용하면 메모리에 있으나 사용하지 않으면 LRU로 없어짐) 
그래서 오브젝트 단위로 저장하면 컴파일 생략되므로 속도가 빨라짐(오라클 DB 안에 저장하는 작업) */

--------------------------------------------------------------------------------
/* PROCEDURE */

/*create : 필수, replace : 수정안됨(drop-create만가능)*/
create or replace procedure emp_proc(p_id in number) --> p_id : 형식 매개변수(사이즈 쓰면 안됨)
is                         /* in : 입력값 처리하는 기능(기본값), 상수처리, 함수들 전부 이모양 */
   v_rec employees%rowtype;  
begin
   select * 
   into v_rec
   from employees where employee_id = p_id;
      dbms_output.put_line(v_rec.last_name||v_rec.first_name);
exception
   when no_data_found then
      dbms_output.put_line(p_id||' 사원은 없습니다.');
end;
/

/* 바인드 사용 불가 */
show error 
--> 오류 확인

/* 호출한다(컴파일 안한다), 소스코드는 저장(오류에 무관), 컴파일 성공하면 
   코드값(P-CODE(parse code), M-CODE(machine code)까지 저장 */
exec emp_proc(100)
exec emp_proc(103)
exec emp_proc(200)
exec emp_proc(300)

/*
replace 옵션: drop하고 create하는 역할
emp_proc(p_id in number) 괄호 안에 있는 거: 형식 매개변수. 사이즈 쓰면 안됨. 타입만.
(parameter 를 이용한 cursor 만들 때와 마찬가지) in 모드는 쓰지 않아도 기본. 입력값 처리하는 기능.
에러 났을 때 확인하려면 show error
bind 변수는 procedure에서 쓸 수 없음(함수나 패키지에서도 못 씀). 바인드 변수 자리를 형식 매개변수가 메꿔줌.


익명블록구조   			     <-> 		    오브젝 단위 프로그램
실행할 때마다 소스 복붙.			        소스코드 저장됨.
						                      컴파일 성공하면 (m-code; p-code)도 저장
						                      실행시 컴파일 안하고 p-code 만 가지고 실행.
*/

================================================================================
/* 페이징 처리 */

-- ex) 급여를 제일 많이 받는 사람 10명만 뽑아라

/* 잘못된 방법 */
select rownum, last_name, salary /*rownum : fetch번호*/
from employees
where rownum <= 10 --> 샘플링 한 효과로 잘못사용
order by salary desc;

/* 위 개선방안 : rownum 이요한 paging 처리 */
select *
from (select rownum no, e.last_name, e.salary
      from (select last_name, salary
            from employees
            order by salary desc) e
      where rownum <= 10 --> 끝 fetch 번호(페이징 처리 준비해 오라클~)
      )
where no >= 1;


select *
from (select rownum no, e.last_name, e.salary
      from (select last_name, salary
            from employees
            order by salary desc) e
      where rownum <= 50 --> 끝 fetch 번호(페이징 처리 준비해 오라클~)
      )
where no >= 10; --> 시작 fetch 번호


select *
from (select rownum no, e.last_name, e.salary
      from (select last_name, salary
            from employees
            order by salary desc) e
      where rownum <= 107 --> 끝 fetch 번호 (변수로 표현하면 count()를 사용)
      )
where no >= 51; --> 시작 fetch 번호


================================================================================

[문제34] 사원번호를 입력값으로 받아서 그 사원의 급여를 10% 인상하는 프로시저를 생성하세요.
        프로시저 이름은 raise_sal로 생성
        
        
create or replace procedure raise_sal(p_id number) --> 사원번호
is --> is 무조건 기술
begin
   update employees
   set salary = salary * 1.1
   where employee_id = p_id;
   if sql%found then
     dbms_output.put_line('급여 10% 이상 수정됨');
   else 
     dbms_output.put_line('사원번호 다시 넣으시오');
   end if;
end;
/

exec raise_sal(100)
/* # 다른프로그램에서 프로시저 호출시 아래와 같이 사용(함수와 다름 := 사용 안됨)
begin
     raise_sal(103);
end;
/
*/
rollback; --> 위 프로그램은 호출 프로그램으로 호출자가 rollback commit 정하도록 함

--------------------------------------------------------------------------------

/* 소스코드 보고 싶을 때 : 다음주에 소스 암호화 배움*/
select text
from user_source
where name = 'RAISE_SAL'
order by line;


================================================================================

[문제35] 사원번호, 인상 %를 입력값으로 받아서 그 사원의 급여를 인상하는 프로시저를 생성하세요.
        프로시저 이름은 raise_sal_per로 생성

exec raise_sal_per(100,10) 
exec raise_sal_per(200,20)

create or replace procedure raise_sal_per(p_id number, p_per number)
is
begin
   update employees
   set salary = salary * (1 + p_per/100)
   where employee_id = p_id;
   if sql%found then
     dbms_output.put_line(p_id||'사원, 급여 '||p_per||'% 이상 수정됨');
   else 
     dbms_output.put_line('사원번호 다시 넣으시오');
   end if;
end;
/
/* 검토 */
select text
from user_source
where name = 'RAISE_SAL_PER'
order by line;

exec raise_sal_per(100,10) 
exec raise_sal_per(200,20)
select salary from employees where employee_id = 100;
select salary from employees where employee_id = 200;
rollback;

============================================================================

/* 전달하고 싶을때 */

create or replace procedure emp_query
(p_id in number, p_name out varchar2, p_sal out number)
is
begin
     /*p_id := 200; 
      상수로 작동하기 때문에 프로그램 내부에서 대체 불가(위처럼 작성 안됨)
      out모드는 변수처럼 사용가능
       */ 
     select last_name, salary 
     into p_name, p_sal
     from employees
     where employee_id = p_id;

end emp_query;
/
/* 형식 매개변수 확인 */
desc emp_query;

/* out모드 자리에는 값을 받아줄 변수를 위치시킨다 */
var b_name varchar2(30)
var b_sal number
exec emp_query(100,:b_name,:b_sal)
print :b_sal :b_name

declare
      v_name varchar2(30);
      v_sal number;
begin
      emp_query(100,v_name,v_sal);
      dbms_output.put_line(v_name||' '||v_sal);
end;
/

declare
     v_id number := 200;
     v_name varchar2(30);
     v_sal number;
begin
     emp_query(v_id, v_name, v_sal);
     dbms_output.put_line(v_name||' '||v_sal);
end;
/

/* in out : 입력과 출력이 혼합되어서 변수로 동작함*/
create or replace procedure format_phone
(p_phone_no in out varchar2) --> 형식매개변수
is
begin
     p_phone_no := substr(p_phone_no, 1, 3) ||'-'||substr(p_phone_no, 4, 4)
                   ||'-'||substr(p_phone_no, 8);
end;
/

var b_phone varchar2(30)
exec :b_phone := '01012345678'

exec format_phone(:b_phone) --> 실제매개변수(초기값 들어있는 변수)

print :b_phone

010-1234-5678

================================================================================
/* 개념정리
# 익명 블록                                       
- 이름이 없는 PL/SQL 구조                          
- 매번 수행시 컴파일 한다(메모리에 없으면)                                                  
- 데이터베이스에 저장 안 됨                         
- 다른 프로그램에서 호출 불가                        
- 입력처리, return 값 처리 (X)                      
  (tool에서 지원하는 바인드변수 사용)
  
# 서브프로그램(프로시저, 함수)
- 이름이 있는 PL/SQL 구조
- 한번만 컴파일 한다(parse된 코드 DBMS저장, 메모리에 없어도 올려서 바로 사용)
- 데이터베이스에 저장함
- 다른 프로그램에서 호출 가능
- 입력처리, return 값 처리 (O)  
  
mode --> 형식매개변수는 옵션 필요없으면 안해도 됨
in : 입력값(호출자가 프로그램으로 값을 넣는다), 상수로 동작
out : 리턴값(프로그램에서 호출자에게 값을 전달한다), 변수로 동작
in out : 입력값과 리턴값을 제공한다. 초기값이 있는 변수로 동작

              in             out       in out
호출자     값, 초기값있는 변수
프로시저       

*/

drop procedure emp_proc;
