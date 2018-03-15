[문제22]
배열변수안에 있는 사원 번호 값을 기준으로 (100,110,200) 그 사원의 last_name, hire_date, department_name 
정보를 배열변수에 담아놓은 후 화면에 출력하는 프로그램을 작성하세요.
     

<화면결과>
100 사원의 이름은 King, 입사한 날짜는 2003-06-17, 근무 부서이름은 Executive 입니다.
110 사원의 이름은 Chen, 입사한 날짜는 2005-09-28, 근무 부서이름은 Finance 입니다.
200 사원의 이름은 Whalen, 입사한 날짜는 2003-09-17, 근무 부서이름은 Administration 입니다.

desc departments;

/* 스칼라 서브쿼리 */
declare
    type rec_type is record(lname varchar2(30), hdate date, dname varchar2(30));
    type tab_type is table of rec_type index by binary_integer;
    v_tab tab_type;
    
    type id_type is table of number;
    v_id id_type := id_type(100,110,200);

begin
   for i in v_id.first..v_id.last loop
    select  last_name,
            hire_date, 
           (select department_name
            from departments
            where department_id = e.department_id)
    into v_tab(i)
    from employees e
    where employee_id = v_id(i);  
   end loop;
   
   for i in v_id.first..v_id.last loop
    dbms_output.put_line(v_id(i)||' 사원의 이름은 '||v_tab(i).lname||', 입사한 날짜는 '
    ||to_char(v_tab(i).hdate,'yyyy-mm-dd')||', 근무 부서이름은 '||v_tab(i).dname||' 입니다.');
   end loop;
   
end;
/

/* 조인 */
declare
    type rec_type is record(lname varchar2(30), hdate date, dname varchar2(30));
    type tab_type is table of rec_type index by binary_integer;
    v_tab tab_type;
    
    type id_type is table of number;
    v_id id_type := id_type(100,110,200);

begin
   for i in v_id.first..v_id.last loop
    select  e.last_name,
            e.hire_date, 
            d.department_name
    into v_tab(i)
    from employees e, departments d
    where e.department_id = d.department_id 
    and employee_id = v_id(i);  
   end loop;
   
   for i in v_id.first..v_id.last loop
    dbms_output.put_line(v_id(i)||' 사원의 이름은 '||v_tab(i).lname||', 입사한 날짜는 '
    ||to_char(v_tab(i).hdate,'yyyy-mm-dd')||', 근무 부서이름은 '||v_tab(i).dname||' 입니다.');
   end loop;
end;
/

================================================================================
/* 문자형 타입 배열변수 */

declare
      type tab_char_type is table of varchar2(30) index by pls_integer;
      v_city tab_char_type;

begin
      v_city(1) := '서울';
      v_city(2) := '대전';
      v_city(3) := '부산';
      
      dbms_output.put_line('v_city.count : '||v_city.count);  --> 배열 안 전체 건수 출력
      dbms_output.put_line(v_city.first);  --> min
      dbms_output.put_line(v_city.last);   --> max
      dbms_output.put_line(v_city.next(1)); --> 1번 방 다음 번호는? 2
      dbms_output.put_line(v_city.prior(2)); --> 2번 방 앞 번호는? 1
      v_city.delete; --> 배열안 값들 전부 지운다(초기화)
      v_city.delete(1);
      v_city.delete(1,2); --> 1 ~ 2번 값들 지워라
      
      dbms_output.put_line(v_city.count);
      
      for i in 1..3 loop
         if v_city.exists(i) then
          dbms_output.put_line(v_city(i));
         end if;
      end loop;
end;
/


declare
      type tab_char_type is table of varchar2(30);
      v_city tab_char_type := tab_char_type('서울','부산','대전'); --> nested 확장이 불편함(index는 자동가능)
      
begin
      v_city.extend; --> 1개 확장(기본값)
      v_city.extend(2); --> 2개 확장
      v_city(4) := '광주';  --> extend 하지 않으면 오류발생
      v_city(5) := '대구';
      
      for i in v_city.first..v_city.last loop
          dbms_output.put_line(v_city(i));
      end loop;
      
end;
/


declare
      type tab_char_type is varray(4) of varchar2(30); --> varray 배열의 한 종류(배열안에 들어가는 요소의 갯수를 제한)
      v_city tab_char_type := tab_char_type('서울','부산','대전'); --> 3개 만들면 3개 칸만 만듬
      
begin 
      v_city.extend(2); 
      v_city(4) := '광주';  --> extend 하지 않으면 오류발생
      v_city(5) := '제주도'; --> varrar(4)로 인해 추가불가, varrar(5)로 먼저 수정해야함
      for i in v_city.first..v_city.last loop
          dbms_output.put_line(v_city(i));
      end loop;
      
end;
/


[문제23]배열 변수에 있는 100,101,102,103,104, 200 사원번호를 기준으로 사원 이름, 
       근무개월수 150개월이상 되었으면 급여(salary)를 10% 인상한 급여로 수정한 후 , 인상 전 급여, 
       인상 후 급여를 출력하는  프로그램을 작성하세요.

사원 번호 : 100 사원 이름 :  King    근무개월수 :  166 인상 전 급여 : 24000 인상 후 급여 : 26400
사원 번호 : 101 사원 이름 :  Kochhar 근무개월수 :  139 17000 급여는 인상할 수 없습니다.
사원 번호 : 102 사원 이름 :  De Haan 근무개월수 :  195 인상 전 급여 : 17000 인상 후 급여 : 18700
사원 번호 : 103 사원 이름 :  Hunold  근무개월수 :  135 9000 급여는 인상할 수 없습니다.
사원 번호 : 104 사원 이름 :  Ernst   근무개월수 :  119 6000 급여는 인상할 수 없습니다.
사원 번호 : 200 사원 이름 :  Whalen  근무개월수 :  163 인상 전 급여 : 4400 인상 후 급여 : 4840


declare
     type arr_type is table of number;
     v_id arr_type := arr_type(100,101,102,103,104,200);
     
     type rec_type is record(lname varchar2(30),hdate number, sal_bf number, sal_af number);
     type emp_arr_type is table of rec_type index by binary_integer;
     v_tab emp_arr_type;
     
begin
     for i in v_id.first..v_id.last loop
       select last_name, trunc(months_between(sysdate,hire_date)), salary
       into v_tab(i).lname, v_tab(i).hdate, v_tab(i).sal_bf
       from employees
       where employee_id = v_id(i);
       
       if v_tab(i).hdate >= 150 then
         v_tab(i).sal_af := v_tab(i).sal_bf * 1.1;
         update employees
         set salary = v_tab(i).sal_af
         where employee_id = v_id(i);
       end if;      
     end loop;
     
     for i in v_id.first..v_id.last loop
       if v_tab(i).sal_af is not null then
       dbms_output.put_line('사원 번호 : '||v_id(i)||
       '사원 이름 :  '||v_tab(i).lname||' 근무개월수 : '||v_tab(i).hdate||' 인상 전 급여 : '
       ||v_tab(i).sal_bf||' 인상 후 급여 : '||v_tab(i).sal_af);
       else
        dbms_output.put_line('사원 번호 : '||v_id(i)||'사원 이름 :  '
        ||v_tab(i).lname||' 근무개월수 : '||v_tab(i).hdate||''||v_tab(i).sal_bf
        ||' 급여는 인상할수 없습니다.');
       end if;
     end loop;
     rollback;
end;
/


/* returning 사용 */

declare
     type arr_type is table of number;
     v_id arr_type := arr_type(100,101,102,103,104,200);
     
     type rec_type is record(lname varchar2(30),hdate number, sal number);
     type emp_arr_type is table of rec_type index by binary_integer;
     v_tab emp_arr_type;
     
     v_sal_af number;
begin
     for i in v_id.first..v_id.last loop
       select last_name, trunc(months_between(sysdate,hire_date)), salary
       into v_tab(i)
       from employees
       where employee_id = v_id(i);
       
       if v_tab(i).hdate >= 150 then
         update employees
         set salary = salary * 1.1
         where employee_id = v_id(i)
         returning salary into v_sal_af;
        
        dbms_output.put_line('사원 번호 : '||v_id(i)||
       '사원 이름 :  '||v_tab(i).lname||' 근무개월수 : '||v_tab(i).hdate||' 인상 전 급여 : '
       ||v_tab(i).sal||' 인상 후 급여 : '||v_sal_af);
       
       else
        dbms_output.put_line('사원 번호 : '||v_id(i)||'사원 이름 :  '
        ||v_tab(i).lname||' 근무개월수 : '||v_tab(i).hdate||''||v_tab(i).sal
        ||' 급여는 인상할수 없습니다.');
       
       end if;      
     end loop;
     rollback;
end;
/

/* procedure 생성(2017-12-17) */
create or replace procedure emp_pro (p_id number)
is
   type rec_type is record(hdate number, sal number,
                           lname varchar2(30), id varchar2(30));
   v_rec rec_type;
   v_sal_af number;
begin
   select trunc(months_between(sysdate, hire_date)) hdate,
          salary, last_name, rowid
   into v_rec
   from employees
   where employee_id = p_id;
   
   if v_rec.hdate >= 150 then
      update employees
      set salary = salary * 1.1
      where rowid = v_rec.id
      returning salary into v_sal_af;
       dbms_output.put_line('사원 번호 : '||p_id||
       '사원 이름 :  '||v_rec.lname||' 근무개월수 : '||v_rec.hdate||' 인상 전 급여 : '
       ||v_rec.sal||' 인상 후 급여 : '||v_sal_af);
       else
        dbms_output.put_line('사원 번호 : '||p_id||'사원 이름 :  '
        ||v_rec.lname||' 근무개월수 : '||v_rec.hdate||' '||v_rec.sal
        ||' 급여는 인상할수 없습니다.');   
   end if;
   rollback;
exception
   when no_data_found then
      dbms_output.put_line(p_id||' 사원은 없습니다');
end;
/
show error

select text
from user_source
where name = 'EMP_PRO'
order by line;

declare
  type arr_type is table of number;
  v_arr arr_type := arr_type(100,101,102,103,104,200);
begin
  for i in v_arr.first..v_arr.last loop
    emp_pro(v_arr(i));
  end loop;
end;
/


[문제24] 배열에 1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9 값이 있습니다.
	 찾는 숫자의 배열 위치 정보 총갯수 정보를 출력하세요.

<화면결과>

20 값은 배열에 7,15 위치에 있으며 총 2 개 있습니다.

100 값은 없습니다.

var b_num number
exec :b_num := 20

-- sql%found
/* 특수화 */
declare
    type arr1_type is table of number;
    v_id_1 arr1_type := arr1_type(1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9);
    
   type arr2_type is table of number index by binary_integer;
    v_id_2 arr2_type;
    
    v_cn number := 0;
begin
    for i in v_id_1.first..v_id_1.last loop
      if v_id_1(i) = :b_num then
        v_id_2(i) := i;
        v_cn := v_cn + 1;
      end if;
    end loop;
    
    for i in v_id_2.first..v_id_2.last loop
     if v_id_2.exists(i) then
     dbms_output.put_line(:b_num ||' '||v_id_2(i)||' '||v_cn);
     end if;
    end loop;
end;
/

/* 일반화(진행중) */
declare
    type arr1_type is table of number;
    v_id_1 arr1_type := arr1_type(1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9);
    
    type arr2_type is table of number index by binary_integer;
    v_id_2 arr2_type;
    
begin
    for i in v_id_1.first..v_id_1.last loop
     for j in v_id_1.first..v_id_1.last loop
      if v_id_1(i) = v_id_1(j) then
        v_id_2(j) := j;
      end if;
      end loop;
    end loop;
    
    for i in v_id_2.first..v_id_2.last loop
     dbms_output.put_line(v_id_1(i) ||' '||v_id_2(i));
    end loop;
end;
/

/* 선생님 풀이 */
declare
    type arr1_type is table of number;
    v_id_1 arr1_type := arr1_type(1,2,4,5,6,10,20,21,55,60,22,8,0,6,20,40,6,9);
    v_find number := 20;
    v_position varchar2(100);
    v_cn number := 0;
    
beginim
    for i in v_id_1.first..v_id_1.last loop
      if v_id_1(i) = v_find then
        v_position := v_position ||','|| i ;
        v_cn := v_cn + 1;
      end if;
    end loop;
    
    if v_cn > 0 then
      dbms_output.put_line(v_find||' 값은 배열에 '||ltrim(v_position,',')||
      ' 위치에 있으며 총 '||v_cn||'개 있습니다.');
    else
      dbms_output.put_line(v_find ||' 같은 없습니다');
    end if;
end;
/


================================================================================
/*
cursor : sql문 실행메모리 영역

select
1. parse
2. bind
3. execute
4. fetch

dml
1. parse
2. bind
3. execute

implicit cursor(암시적 커서) : 커서를 오라클이 생성관리 한다.
 * select into(반드시 1개의 row만 fetch해야 한다), DML문
※ 암시적 cursor 속성 3가지(DML 결과를 판단하는 속성으로만 쓰자(select은 쓸데없는 로직구현 됨, 사용금지))
   1. sql%rowcount : DML문으로 영향입은 row의 건수를 보여짐
   2. sql%found : DML문으로 영향입은 row가 있으면 True, 없으면 False
   3. sql%notfound : DML문으로 영향입은 row가 없으면 True, 있으면 False

explicit curcor(명시적 커서) : 여러개의 row를 fetch해야 한다면 이걸 사용해야 된다.
                             프로그래머가 커서를 생성관리해야 한다.
*/
select * from employees where department_id = 20;

declare
     /* 1. 커서선언 */
     cursor emp_cur is
           select employee_id, last_name, salary
           from employees
           where department_id = 20;  
           
     v_id employees.employee_id%type;
     v_name employees.last_name%type;
     v_sal employees.salary%type;
begin
     /* 2. 커서오픈 : 메모리 할당, parse, bind, execute, fetch */ --> 대용량 한번에 커서로 로드시키는게 아니라 왔다갔다
      if emp_cur%isopen then --> open여부 확인(open이면 true)
             null;
      else
           open emp_cur;     --> 그냥 이것만 해도 되고
     end if;
     /* 3. fetch : 커서의 active set 결과를 변수로 로드작업 */
     loop
         fetch emp_cur into v_id, v_name, v_sal;
         exit when emp_cur%notfound; /* > 2 or emp_cur%rowcount */ /* emp_cur%found 도 있다 */
         dbms_output.put_line(v_id);
         dbms_output.put_line(v_name);
         dbms_output.put_line(v_sal);
        
     end loop;
         dbms_output.put_line(emp_cur%rowcount); --> fetch한 수
         
     /* 4. close : 커서 닫기 */
     close emp_cur;
end;
/

/* 명시적 커서 속성
1. 커서명%isopen : 이 이름으로 memory가 open돼있으면 true.
2. 커서명%notfound : fetch한게 없으면 true, 있으면 false
3. 커서명%rowcount : fetch한 갯수
4. 커서명%found : fetch한게 있으면 true, 없으면 false
*/

--------------------------------------------------------------------------------

[문제25]
2006년도에 입사한 사원들의 근무 도시이름별로 급여의 총액, 평균을 출력하세요.

<화면출력>

Seattle 도시에 근무하는 사원들의 총액급여는 ￦10,400 이고 평균급여는 ￦5,200 입니다.
South San Francisco 도시에 근무하는 사원들의 총액급여는 ￦37,800 이고 평균급여는 ￦2,907 입니다.
Southlake 도시에 근무하는 사원들의 총액급여는 ￦13,800 이고 평균급여는 ￦6,900 입니다.
Oxford 도시에 근무하는 사원들의 총액급여는 ￦59,100 이고 평균급여는 ￦8,442 입니다.


select l.city, sum(e.salary), avg(e.salary)
from employees e, departments d, locations l
where e.department_id = d.department_id
and d.location_id = l.location_id
and (e.hire_date >= to_date(20060101,'yyyymmdd')
and e.hire_date < to_date(20070101,'yyyymmdd'))
group by l.city;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));

select l.city, e.sum, e.avg
from (select sum(salary) sum ,avg(salary) avg , department_id
      from employees
      where hire_date >= to_date(20060101,'yyyymmdd')
      and hire_date < to_date(20070101,'yyyymmdd')
      group by department_id) e,
     (select department_id, location_id
      from departments) d,
      locations l
where e.department_id = d.department_id
and d.location_id = l.location_id;

select * from table(dbms_xplan.display_cursor(null,null,'allstats last'));


declare
     cursor emp_cur is
       select l.city, sum(e.salary), trunc(avg(e.salary))
       from employees e, departments d, locations l
       where e.department_id = d.department_id
       and d.location_id = l.location_id
       and (e.hire_date >= to_date(20060101,'yyyymmdd')
       and e.hire_date < to_date(20070101,'yyyymmdd'))
       group by l.city;
     v_city locations.city%type;
     v_sum_sal employees.salary%type;
     v_avg_sal number(8,1);
begin
     open emp_cur;
     loop 
       fetch emp_cur into v_city, v_sum_sal, v_avg_sal;
       exit when emp_cur%notfound;
       dbms_output.put_line(v_city||' 도시에 근무하는 사원들의 총액급여는 '||
       ltrim(to_char(v_sum_sal,'l999,999'))||' 이고 평균급여는 '||
       ltrim(to_char(v_avg_sal,'l999,999'))||'입니다.');
     end loop;
     
     close emp_cur;
end;
/

--------------------------------------------------------------------------------

/* record 활용 */
declare
     /* 1. 커서선언 */
     cursor emp_cur is
           select *
           from employees
           where department_id = 20;  
           
     v_rec emp_cur%rowtype; --> record 변수
begin
     /* 2. 커서오픈 : 메모리 할당, parse, bind, execute, fetch */ --> 대용량 한번에 커서로 로드시키는게 아니라 왔다갔다
      if emp_cur%isopen then --> open여부 확인(open이면 true)
             null;
      else
           open emp_cur;
     end if;
     /* 3. fetch : 커서의 active set 결과를 변수로 로드작업 */
     loop
         fetch emp_cur into v_rec;
         exit when emp_cur%notfound;
         dbms_output.put_line(v_rec.employee_id);
         dbms_output.put_line(v_rec.last_name);
         dbms_output.put_line(v_rec.salary);
        
     end loop;
         dbms_output.put_line(emp_cur%rowcount); --> fetch한 수
         
     /* 4. close : 커서 닫기 */
     close emp_cur;
end;
/

/* for문 활용 : 레코드, 명시적 커서 일부 자동 */
declare
     /* 1. 커서선언 */
     cursor emp_cur is
           select *
           from employees
           where department_id = 20;  
           
begin
     /* 2.open, 3.fetch, 4.close + 레코드변수 자동생성 */
     for emp_rec in emp_cur loop --> 명시적 for문
         dbms_output.put_line(emp_rec.employee_id);
         dbms_output.put_line(emp_rec.last_name);
         dbms_output.put_line(emp_rec.salary);
     end loop;
end;
/


/* 서브쿼리 활용 */
begin
     /* 2.open, 3.fetch, 4.close + 레코드변수 자동생성 */
     for emp_rec in (select *
                     from employees
                     where department_id = 20) --> 이름이 없는 메모리(오라클 생성) : 명시적 커서 속성 이용못함
     loop
         dbms_output.put_line(emp_rec.employee_id);
         dbms_output.put_line(emp_rec.last_name);
         dbms_output.put_line(emp_rec.salary);
     end loop;
end;
/
/*
# (참고)자동으로 하면 값(active set 결과)이 없을 때 자동으로 close됨(아예 for문의 로직을 타지 않음). 
   그래서 쿼리문장의 active set 결과 없을 때 어떤 액션을 취해야 한다면 manual하게 구성해야 함. 
*/

[문제26]
사원의 last_name 값을 입력 받아서 그 사원의 employee_id, last_name, department_name 출력하고 
만약의 없는 last_name을 입력 할경우에는  "Hong 이라는 사원은 존재하지 않습니다."  출력 하는 프로그램을 만드세요.


입력값 : king

Employee Id = 156 Name = King Department Name = Sales
Employee Id = 100 Name = King Department Name = Executive


입력값 : hong

Hong 이라는 사원은 존재하지 않습니다.

select count(*) from employees where last_name = 'King';
var b_lname varchar2(30)
exec :b_lname := 'king'
print :b_lname

declare
    cursor emp_cur is
      select e.employee_id, d.department_name
      from employees e, departments d
      where e.department_id = d.department_id 
      and last_name = initcap(:b_lname);
begin
     for rec in emp_cur loop
       if 
         dbms_output.put_line('Employee Id = '||rec.employee_id||' Name = '||
         initcap(:b_lname)||' Department Name = '||rec.department_name);

   else dbms_output.put_line(1);
   end if;
        end loop;
end;
/

/* 선생님 풀이 */

-- King, Hong 데이터 조회

SELECT e.employee_id, e.last_name, d.department_name 
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND e.last_name = initcap('king');

SELECT e.employee_id, e.last_name, d.department_name 
FROM employees e, departments d
WHERE e.department_id = d.department_id
AND e.last_name = initcap('hong');

--------------------------------------------------------------------------------
/* 잘못된 접근 */

var b_name varchar2(10)

execute :b_name := 'king'

DECLARE
  CURSOR c1 IS 
	      SELECT e.employee_id, e.last_name, d.department_name
	      FROM employees e, departments d
        WHERE e.department_id = d.department_id
        AND e.last_name = initcap(:b_name);
BEGIN
  FOR v_rec IN c1 LOOP
    IF c1%NOTFOUND THEN  
	        DBMS_OUTPUT.PUT_LINE(:b_name || '  이라는 사원은 존재하지 않습니다.');
    ELSE
          DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                               ||' Name = ' || v_rec.last_name 
		                           ||' Department Name = '||v_rec.department_name);
    END IF;
  END LOOP;
END;
/


execute :b_name := 'hong'

DECLARE
 CURSOR c1 IS 
	      SELECT e.employee_id, e.last_name, d.department_name
	      FROM employees e, departments d
        WHERE e.department_id = d.department_id
        AND e.last_name = initcap(:b_name);
BEGIN
  FOR v_rec IN c1 LOOP
    IF c1%NOTFOUND THEN --> 잘못 만든 것. 쓸데없는 로직. 결과 없으면 아예 안됨.
	      DBMS_OUTPUT.PUT_LINE(:b_name || '  이라는 사원은 존재하지 않습니다.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                             ||' Name = ' || v_rec.last_name 
		                         ||' Department Name = '||v_rec.department_name);
    END IF;
  END LOOP;
END;
/
--------------------------------------------------------------------------------
/* 위 개선후 정답 */

DECLARE
 CURSOR c1 IS
	 SELECT e.employee_id, e.last_name, d.department_name 
	 FROM employees e, departments d
   WHERE e.department_id = d.department_id
   AND e.last_name = initcap(:b_name);

 v_rec c1%rowtype;

BEGIN
  OPEN c1;
  
  FETCH c1 INTO v_rec; --> active set 발생되거나 발생되지 않는 경우를 위한 미끼
  	
  IF c1%NOTFOUND THEN 
		  DBMS_OUTPUT.PUT_LINE(:b_name || '  이라는 사원은 존재하지 않습니다.');
  ELSE
   		DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                           ||' Name = ' || v_rec.last_name 
		                       ||'Department Name = '||v_rec.department_name);
	    LOOP
		    FETCH c1 INTO v_rec;
		      IF c1%FOUND THEN  
  			     DBMS_OUTPUT.PUT_LINE('Employee Id = ' || v_rec.employee_id 
                      		   ||' Name = ' || v_rec.last_name 
		                         ||' Department Name = '||v_rec.department_name);
		      ELSE  
			       EXIT;
		      END IF;
	     END LOOP;
  END IF; 
  CLOSE c1;
  
END;
/


