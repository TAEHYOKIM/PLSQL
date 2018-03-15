[문제29] 사원테이블에 부서코드값을 기준으로 실행계획을 분리하는 프로그램을 생성하세요. 
         부서코드중에 50,80, null 값이 입력되면 full table scan 
         그외 부서 코드값이 입력 입력되면 index range scan 할수 있도록 하세요.

var b_id number

execute :b_id := 50

execute :b_id := 10

execute :b_id := null

-- 변수처리 옵티마이저 분포도 균등하다고 판단하니 구분해서 작동하게 만드는 프로그램
-- 명시적 커서, 힌트사용, 쿼리문 총 3개

/* employees table의 index 조회 */
select ix.index_name, ix.uniqueness, ic.column_name
from user_indexes ix, user_ind_columns ic
where ix.index_name = ic.index_name
and ix.table_name = 'EMPLOYEES';

/* 초안 */
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
/* NOTE 커서를 불필요하게 3개를 만든 프로그램은 메모리 성능에 나쁘게 작용할 것으로 판단 */

/* 위 개선방안 */
begin
end;
/


/* 선생님 풀이 */
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

/* bulk collect into 활용 */
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

/* 값의 분포도 */
select * from employees where department_id = 10; --> index 
select * from employees where department_id = 50; --> full
select * from employees where department_id = :b_id; 
 --> 변수로 처리하면 분포도를 균등하게 가정해서 값이 많은 경우 I/O 발생 증가될 수 있음

select department_id, count(*)
from employees
group by department_id;

================================================================================

-- exception 예외사항 : 실행중에 발생한 오라클의 오류

/* 1. predefined exception : 오라클의 오류번호에 따른 예외사항 이름이 있는 경우 */

declare
     v_rec employees%rowtype;
begin
     /* 암시적 커서에서 의도적으로 오류발생 */
     select *
     into v_rec --> 단일행만 저장
     from employees
     where department_id = 20;
     dbms_output.put_line(v_rec.last_name);
exception
    /* 정상종료를 시키는 거임 */
     when no_data_found then
       dbms_output.put_line('사원이 없는 부서코드를 입력 했습니다.');
     when too_many_rows then
       dbms_output.put_line('소속사원이 여러명 입니다.');
end;
/



/* 비정상 종료로 인한 자동 rollback */
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
/* test : 24000 변동 없음 */
select salary from employees where employee_id = 100; 


/* exception에 의해서 정상종료가 되어서 DML문에 대한 마무리를 꼭 해야함 */
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
       dbms_output.put_line('사원이 없는 부서코드를 입력 했습니다.');
     when too_many_rows then
       dbms_output.put_line('소속사원이 여러명 입니다.');
     rollback; --> 꼭 해줘야함(또는 commit;)
end;
/

/* when others then : 어떤 오류가 발생할 지 모를때 제일 마지막에 작성 */
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
       dbms_output.put_line('사원이 없는 부서코드를 입력 했습니다.');
     when others then
       dbms_output.put_line('오류번호 : '||sqlcode); --> 현재발생한 오류번호 리턴
       dbms_output.put_line('오류메세지 : '||sqlerrm); --> 현재발생한 오류메세지 리턴
     rollback;
   end;
    dbms_output.put_line(v_rec.last_name);
end;
/


delete from departments where department_id = 10; --> pk에 종속된 fk가 있어서 삭제 안됨

/* 2. non-predefined exception : 오류번호는 있으나 예외사항 오류이름 없을 경우 */
declare
    e_error exception; --> 이름선언
    pragma exception_init(e_error,-2292); 
begin
    delete from departments where department_id = 10;
    /*오류: ORA-02292: integrity constraint (HR.EMP_DEPT_FK) violated - child record found*/
exception
    when e_error then
        dbms_output.put_line('사원테이블에 소속사원이 있습니다.');
end;
/


/* 3. user-defined exception : 오라클에서 오류는 아니지만 업무에서는 오류인 경우 */

declare
     e_invalid_id exception;
begin
     update employees
     set salary = salary * 1.1 
     where employee_id = 300; --> 영향을 입은 row가 없지만 exception 오류는 아님
     
     if sql%notfound then
           raise e_invalid_id; --> raise문 만나면 무조건 exception절로 간다(막강함)
     end if;
exception
     when e_invalid_id then
         dbms_output.put_line('사원번호를 잘 입력하세요'); 
        --null;
     rollback;
end;
/


/* raise_application_error : 비정상 종료시키면서 오라클이 보여주는 오류처럼 보이게 만드는 방법 */
begin
     update employees
     set salary = salary * 1.1 
     where employee_id = 300;
     
     if sql%notfound then
        /* raise_application_error: 오류를 인위적으로 발생시키는 프로시저(오류번호는 -20000~-20999)*/
           raise_application_error(-20000,'없는 사원 입니다.');
     end if;
end;
/


declare
     v_rec employees%rowtype;
begin
     select * into v_rec from employees where employee_id = 300;
exception
     when no_data_found then
         raise_application_error(-20001,'없는 사원입니다',false); 
         --> 기본값 : false(내꺼만), true는 오라클 오류문 포함해서 다 나옴
end;
/

================================================================================

[문제30] 사원 번호를 입력 값으로 받아서 사원의 번호, 이름, 부서이름 정보를 출력하는 프로그램을 작성합니다.
단 100번 사원이 입력값으로 들어오면 예외사항이 발생하도록 해야 합니다.
또한 없는 사원번호 값이 들어오면 예외사항 처리을 만들어 주세요.


<화면 결과>
SQL> var b_id number

SQL> execute :b_id := 200

Result=> 사원번호 : 200, 사원이름 : Whalen, 부서이름 : Administration

SQL> execute :b_id := 100

100 사원은 조회할수 없습니다.


SQL> execute :b_id := 300

300 사원은 존재하지 않습니다.


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
       
        dbms_output.put_line('Result=> 사원번호 : '||:b_id||', 사원이름 : '||
        v_rec.lname||', 부서이름 : '||v_rec.dname);
        
     end if;
exception
     when e_1 then /* 100 */
       dbms_output.put_line(:b_id||' 사원은 조회할수 없습니다.');
     when no_data_found then /* 300 */
       dbms_output.put_line(:b_id||' 사원은 존재하지 않습니다.');
end;
/


[문제31] 사원들 중에 job_id가 'SA_REP' 사원들의 이름, 부서 이름을 출력하고 부서 배치를 받지 않는
사원들에 대해서는 "부서 배치를 못 받았습니다." 출력해야 합니다.
또한 출력할때 카운터 수를 출력해주세요.(조인은 이용하지 마세요)

1 사원이름 : Tucker, 부서이름 : Sales
2 사원이름 : Bernstein, 부서이름 : Sales
3 사원이름 : Hall, 부서이름 : Sales
4 사원이름 : Olsen, 부서이름 : Sales
5 사원이름 : Cambrault, 부서이름 : Sales
6 사원이름 : Tuvault, 부서이름 : Sales
7 사원이름 : King, 부서이름 : Sales
8 사원이름 : Sully, 부서이름 : Sales
9 사원이름 : McEwen, 부서이름 : Sales
10 사원이름 : Smith, 부서이름 : Sales
11 사원이름 : Doran, 부서이름 : Sales
12 사원이름 : Sewall, 부서이름 : Sales
13 사원이름 : Vishney, 부서이름 : Sales
14 사원이름 : Greene, 부서이름 : Sales
15 사원이름 : Marvins, 부서이름 : Sales
16 사원이름 : Lee, 부서이름 : Sales
17 사원이름 : Ande, 부서이름 : Sales
18 사원이름 : Banda, 부서이름 : Sales
19 사원이름 : Ozer, 부서이름 : Sales
20 사원이름 : Bloom, 부서이름 : Sales
21 사원이름 : Fox, 부서이름 : Sales
22 사원이름 : Smith, 부서이름 : Sales
23 사원이름 : Bates, 부서이름 : Sales
24 사원이름 : Kumar, 부서이름 : Sales
25 사원이름 : Abel, 부서이름 : Sales
26 사원이름 : Hutton, 부서이름 : Sales
27 사원이름 : Taylor, 부서이름 : Sales
28 사원이름 : Livingston, 부서이름 : Sales
29 사원이름 : Grant, 부서이름 : 부서 배치를 못 받았습니다.
30 사원이름 : Johnson, 부서이름 : Sales

-- loop 안에 loop 구조 생각
-- grant no_data_found
-- main sub block

select last_name, department_id
from employees
where job_id = 'SA_REP'; --> 명시적 커서로 구성

select department_name
from departments
where department_id = 레코드 변수;


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
     dbms_output.put_line(i||' 사원이름 : '||v_arr(i).lname||', 부서이름 : '||v_arr(i).dname);
     else
     dbms_output.put_line(i||' 사원이름 : '||v_arr(i).lname||
                               ', 부서이름 : 부서 배치를 못 받았습니다.'); 
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
                 '부서 배치를 못 받았습니다.') dname
     bulk collect into v_arr
     from employees e
     where e.job_id = 'SA_REP';

     for i in v_arr.first..v_arr.last loop
       dbms_output.put_line(v_arr(i).num||' 사원이름 : '||v_arr(i).lname||', 부서이름 : '||v_arr(i).dname);
     end loop;
end;
/


/* 선생님 풀이 */

/* 풀이 1
 ① 명시적 커서 선언
 ② dept_name 값 저장할 변수 선언
 ③ 누적번호 저장할 변수 선언
 ④ for문 으로 레코드 변수 생성
 ⑤ 서브블락 활용 : exception 땜
 ⑥ 오류구문 작성(no_data_found)
 */
DECLARE
     CURSOR emp_cursor IS
	          SELECT last_name, department_id
            FROM  employees                              
  	        WHERE job_id = 'SA_REP'; /*①*/          
     v_dept_name departments.department_name%type; /*②*/ 
     v_c number := 1; /*③*/
BEGIN
    FOR c_rec IN emp_cursor LOOP  /*④*/
    
       BEGIN  /*⑤*/
			   SELECT department_name
         INTO v_dept_name
			   FROM departments
         WHERE department_id = c_rec.department_id;
			
			   dbms_output.put_line(v_c||' 사원이름 : '||c_rec.last_name 
                                   ||', 부서이름 : '||v_dept_name);
			   v_c := v_c + 1;
       EXCEPTION  /*⑥*/
         WHEN no_data_found THEN 
			     dbms_output.put_line(v_c||' 사원이름 : '||c_rec.last_name 
                                ||', 부서이름 : 부서 배치를 못 받았습니다.');
		        v_c := v_c + 1;
       END;
       
    END LOOP;
END;
/



/* 풀이 2
 ① dept_name 값 저장할 변수 선언
 ② 누적번호 저장할 변수 선언
 ③ for문에 서브쿼리를 통해 레코드 변수 생성(커서 미선언)
 ④ 서브블락 활용
 ⑤ 오류구문 작성(no_data_found)
 */
DECLARE
    v_dept_name departments.department_name%type; /*①*/
    v_c number := 1; /*②*/

BEGIN
	  FOR c_rec IN (SELECT last_name, department_id  /*③*/
                  FROM  employees
                  WHERE job_id = 'SA_REP') LOOP
      BEGIN  /*④*/
			   SELECT department_name
         INTO v_dept_name
			   FROM departments
			   WHERE department_id = c_rec.department_id;
			
			    dbms_output.put_line(v_c||' 사원이름 : '||c_rec.last_name 
                                ||', 부서이름 : '||v_dept_name);

			    v_c := v_c+1;
      EXCEPTION  /*⑤*/
         WHEN no_data_found THEN 
			      dbms_output.put_line(v_c||' 사원이름 : '||c_rec.last_name 
                                ||', 부서이름 : 부서배치를 못 받았습니다.');
		     v_c := v_c + 1;
      END;
    END LOOP;
END;
/


/* 풀이 3
 ① 명시적 커서 선언
 ② record 변수선언
 ③ dept_name 값 저장할 변수 선언
 ④ 누적번호 저장할 변수 선언
 ⑤ loop문에서 fetch
 ⑥ 서브블락 활용
 ⑦ 오류구문 작성(no_data_found)
*/
DECLARE
     CURSOR emp_cursor IS  /*①*/
	        SELECT last_name, department_id
          FROM  employees
  	      WHERE job_id = 'SA_REP';

     c_rec emp_cursor%rowtype;  /*②*/
     v_dept_name departments.department_name%type;  /*③*/
     v_c number := 1;  /*④*/

BEGIN
     OPEN emp_cursor;

     LOOP  
        FETCH emp_cursor INTO c_rec;  /*⑤*/
        EXIT WHEN emp_cursor%NOTFOUND;
    
         BEGIN  /*⑥*/
			      SELECT department_name
      			INTO v_dept_name
			      FROM departments
			      WHERE department_id = c_rec.department_id;
			
			      dbms_output.put_line(v_c||  ' 사원이름 : '||c_rec.last_name 
                                        ||', 부서이름 : '||v_dept_name);

			      v_c := v_c+1;
         EXCEPTION  /*⑦*/
           WHEN no_data_found THEN 
			          dbms_output.put_line(v_c||  ' 사원이름 : '||c_rec.last_name 
                                        ||', 부서이름 : 부서 배치를 못 받았습니다.');
           v_c := v_c + 1;
         END;
    END LOOP;
    
    CLOSE emp_cursor;
END;
/


/* 풀이 4
 ① 명시적 커서 선언
 ② 2차원 배열 변수선언
 ③ dept_name 값 저장할 변수 선언
 ④ 누적번호 저장할 변수 선언
 ⑤ for - loop문 사용
 ⑥ 서브블락 활용
 ⑦ 오류구문 작성(no_data_found)
*/
DECLARE
     CURSOR emp_cursor IS  /*①*/
	         SELECT last_name, department_id
           FROM  employees
  	       WHERE job_id = 'SA_REP';	

     TYPE emp_tab_type IS TABLE OF emp_cursor%rowtype;  /*②*/
     v_tab emp_tab_type;  
     v_dept_name departments.department_name%type;  /*③*/
     v_c number := 1;  /*④*/

BEGIN
     OPEN emp_cursor;

     FETCH emp_cursor BULK COLLECT INTO v_tab;
    
     FOR i IN v_tab.first..v_tab.last LOOP  /*⑤*/
		     BEGIN  /*⑥*/
			      SELECT department_name
      			INTO v_dept_name
            FROM departments
			      WHERE department_id = v_tab(i).department_id;
			
			      dbms_output.put_line(v_c||  ' 사원이름 : '||v_tab(i).last_name 
                                        ||', 부서이름 : '||v_dept_name);
			      v_c := v_c+1;
         EXCEPTION  /*⑦*/
	           WHEN no_data_found THEN 
			            dbms_output.put_line(v_c||  ' 사원이름 : '||v_tab(i).last_name 
                                        ||', 부서이름 : 부서 배치를 못 받았습니다.');
                  v_c := v_c + 1;
         END;
    END LOOP;

    CLOSE emp_cursor;
END;
/


/* 스칼라 서브쿼리 : cache 기능으로 가장 성능이 좋음 */
DECLARE
     CURSOR emp_cursor IS
	        select rownum no, 
                 e.last_name, 
                 nvl((select  department_name
                      from departments
                      where department_id = e.department_id), '부서 배치를 못받았습니다.') dept_name
	        from employees e
	        where  e.job_id = 'SA_REP';
	
      TYPE emp_tab_type IS TABLE OF emp_cursor%rowtype;
          v_tab emp_tab_type;

BEGIN
      OPEN emp_cursor;
      FETCH emp_cursor BULK COLLECT INTO v_tab;
      FOR i IN v_tab.first..v_tab.last LOOP
				 dbms_output.put_line(v_tab(i).no||  ' 사원이름 : '||v_tab(i).last_name 
                              ||', 부서이름 : '||v_tab(i).dept_name);
	    END LOOP;
      CLOSE emp_cursor;
END;
/