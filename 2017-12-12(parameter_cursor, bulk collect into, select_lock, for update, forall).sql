[문제27] 사원의 last_name 값을 입력 받아서 그 사원의 employee_id, last_name, department_name 출력하고 
만약의 없는 last_name을 입력 할경우에는  "Hong 이라는 사원은 존재하지 않습니다."  출력 하는 프로그램을 만드세요. 
단 명시적인 커서 FOR문을 이용하세요.

SQL> execute :b_name := 'king'

Employee Id = 156 Name = King Department Name = Sales
Employee Id = 100 Name = King Department Name = Executive
King 이라는 사원은 2 명 입니다.


SQL> execute :b_name := 'hong'

Hong 이라는 사원은 존재하지 않습니다.

select employee_id, last_name, department_name
from employees e, departments d
where e.department_id = d.department_id
and e.last_name = 'King';

var b_name varchar2(30)
exec :b_name := 'king'
exec :b_name := 'hong'

declare
    cursor emp_cur is
      select employee_id, last_name, department_name
      from employees e, departments d
      where e.department_id = d.department_id
      and e.last_name = initcap(:b_name);
    v_c number := 0;
begin
    for v_rec in emp_cur loop
      dbms_output.put_line('Employee Id = ' || v_rec.employee_id 
                           ||' Name = ' || v_rec.last_name 
		                       ||'Department Name = '||v_rec.department_name);
      v_c := emp_cur%rowcount;  
       --> 핵심 : for loop문이 끝나면 명시적 커서 close 되기때문에 여기에서 %rowcount 속성을 사용
    end loop;
    if v_c = 0 then
      dbms_output.put_line(initcap(:b_name)||' 이라는 사원은 존재하지 않습니다.'); --> 명시적 오류문
    else 
      dbms_output.put_line(initcap(:b_name)||' 이라는 사원은 '||v_c||'명 입니다.');
    end if;
end;
/


================================================================================

-- parameter를 갖는 cursor : 목적은 실행계획을 공유하기 위해

/* 
실행계획을 쉐어링 할지 분리해야 할지 판단해야함(만약 분포도가 작은놈과 큰놈을 다룰 때는
active set 달라야 함!! 분포도 작으면 index, 분포도 크면 full이 효율적)
*/
declare
  cursor parm_cur_80 is
       select employee_id, last_name, job_id
       from employees
       where department_id = 80
       and job_id = 'SA_MAN';
       
  cursor parm_cur_50 is
       select employee_id, last_name, job_id
       from employees
       where department_id = 50
       and job_id = 'ST_MAN';
       
  v_rec1 parm_cur_80%rowtype;
  
begin
  open parm_cur_80;
  loop
       fetch parm_cur_80 into v_rec1;
       exit when parm_cur_80%notfound;
           dbms_output.put_line('Emp Name1 : '||v_rec1.last_name);
  end loop;
  close parm_cur_80;
  
  for v_rec2 in parm_cur_50 loop
    dbms_output.put_line('Emp Name2 : '||v_rec2.last_name);
  end loop;
end;
/
/*
문제점: cursor 2개 만들고, 실행계획도 2번 만듬
해결: 바인드변수 처리, 입력변수 처리. 파라미터 갖는 커서 만들기
parameter를 갖는 커서의 목적: 실행계획을 공유하기 위해서.
(실행계획 sharing 하지 말아야 하는 경우: 
 - key값에 인덱스 걸려있고, 
 - key값에 따른 값의 분포도가 불균등하게 들어있는 경우, 
 - 인수 값에 따라 어떤 경우에는 rowid scan이 낫고, 어떤 경우는 full table scan이 나을 수도 있음. 
 - 이런 경우 의도적으로 hard parsing 을 유도해야 함. 건수를 카운팅 해봐야 함. 이건 튜닝임.)
*/

--------------------------------------------------------------------------------

/* 위 개선방안(튜닝) */

declare
  cursor parm_cur(p_id number, p_job varchar2) is --> 형식매개변수 : 타입만 작성, 사이즈 X
       select employee_id, last_name, job_id
       from employees
       where department_id = p_id
       and job_id = p_job;
       
  v_rec1 parm_cur%rowtype; --> record 변수선언
  
begin
  open parm_cur(80,'SA_MAN'); --> 실제매개변수 : 형식매개변수 타입순서에 일치되게 기입(바인드 변수도 가능)
  loop
       fetch parm_cur into v_rec1; --> loop 1 회전당 1 row씩 fetch 시킴
       exit when parm_cur%notfound;
           dbms_output.put_line('Emp Name1 : '||v_rec1.last_name);
  end loop;
  close parm_cur;
  
  for v_rec2 in parm_cur(50,'ST_MAN') loop
    dbms_output.put_line('Emp Name2 : '||v_rec2.last_name);
  end loop;
end;
/

-- 조회시 lock 걸기(select - for update)

/* 잘못된 접근 */
declare
     cursor sal_cur is
            select e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20;
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where last_name = emp_rec.last_name; --> 문제점(동명이인이면 우짜냐?)
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------

/* 위 개선사항(by index rowid) */
declare
     cursor sal_cur is
            select e.employee_id, e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20;
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where employee_id = emp_rec.employee_id;  --> by index rowid scan로 실행
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------

/* 위 개선사항(by user rowid) : 가장저렴한 I/O */
declare
     cursor sal_cur is
            select e.rowid, e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20;
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where rowid = emp_rec.rowid;  --> 해당 row에만 lock
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------

/* for update : DML 전부 */
declare
     cursor sal_cur is
            select e.last_name, e.salary, d.department_name
            from employees e, departments d
            where e.department_id = 20
            and d.department_id = 20
            for update; --> 미리 lock(cursor open시), rowid 내부적 구현 
                        --> 20번 부서 사원 row 전체 및 20번 부서 dept 테이블 row에 lock
begin
     for emp_rec in sal_cur loop
        dbms_output.put_line(emp_rec.last_name);
        dbms_output.put_line(emp_rec.salary);
        dbms_output.put_line(emp_rec.department_name);
        update employees
        set salary = emp_rec.salary * 1.1
        where current of sal_cur; 
         --> rowid = emp_rec.rowid; (update or delete사용 / insert는 where절이 없어서 안됨)
     end loop;
     rollback;
end;
/

--------------------------------------------------------------------------------
/* for update of 기능(3가지) */

declare
  ·······
for update of e.last_name; 
/* 
lock 선택(참조의 의미 : 이 컬럼이 있는 테이블의 row에 대해)
이렇게 하면 조인되는 dept 테이블에는 lock 안걸리고 emp 테이블만 걸림
(근데 테이블명 아니고 컬럼명 아무거나 씀. select 절에 있든 없든 상관없음. 
이 컬럼이 있는 테이블의 row에 대해서 lock이 걸림.)
*/

declare
  ·······
for update of e.first_name wait 5;	
/*
누가 먼저 lock 걸어놓은 경우 5초만 기다리고, 5초 동안 lock 안 풀리면 오류. 
기본값은 wait, 무작정 기다림.
*/

declare
  ·······
for update of e.first_name nowait;	
/* 누가 먼저 lock 걸어놓은 경우 안 기다리고 무조건 오류메시지 */


/*
# 주의 : lock은 커서를 오픈하는 순간 걸림. 만약 update 수행해야 하는 row 수가 일부여도 
        전체 lock이 걸리기 때문에, dml 대상이 일부인 경우엔 rowid로 쓰는 게 나음. 
        for update는 거의 전부 dml 해야 할 경우만. 
*/

================================================================================

[문제28] 30번 부서 사원들의 이름, 급여, 근무개월수, 부서이름을 출력하고 그 사원들 중에 
        근무개월수가 150개월 이상인 사원들의 급여를 10%인상하는 프로그램을 작성하세요.

/*
<화면 출력>

사원이름 : Raphaely 급여 : 11000 근무개월수 : 172 부서 이름 :  Purchasing
Raphaely 10%인상 급여로 수정했습니다.
사원이름 : Khoo 급여 : 3100 근무개월수 : 167 부서 이름 :  Purchasing
Khoo 10%인상 급여로 수정했습니다.
사원이름 : Baida 급여 : 2900 근무개월수 : 136 부서 이름 :  Purchasing
사원이름 : Tobias 급여 : 2800 근무개월수 : 141 부서 이름 :  Purchasing
사원이름 : Himuro 급여 : 2600 근무개월수 : 125 부서 이름 :  Purchasing
사원이름 : Colmenares 급여 : 2500 근무개월수 : 116 부서 이름 :  Purchasing
*/


select e.last_name, 
       e.salary, 
       trunc(months_between(sysdate,e.hire_date)), 
       d.department_name
from employees e, departments d
where e.department_id = 30
and d.department_id = 30; --> 카테시안 곱으로 유도한 것은 1족 : M족 이어서 문제없다


declare
  cursor v_cur is
    select e.rowid,
       e.last_name, 
       e.salary, 
       trunc(months_between(sysdate,e.hire_date)) hdate, 
       d.department_name
    from employees e, departments d
    where e.department_id = 30
    and d.department_id = 30;  
begin
  for v_rec in v_cur loop
      dbms_output.put_line('사원이름 : '||v_rec.last_name||' 급여 : '||v_rec.salary||
      '근무개월수 : '||v_rec.hdate||' 부서 이름 : '||v_rec.department_name);
      
      if v_rec.hdate >= 150 then
           update employees
           set salary = salary * 1.1
           where rowid = v_rec.rowid;
           dbms_output.put_line(v_rec.last_name||' 10%인상 급여로 수정했습니다.');
      end if;
      
  end loop;
  rollback;
end;
/

================================================================================

declare
     cursor emp_cur is
         select * from employees where department_id = 20;
     v_rec emp_cur%rowtype;
begin
     open emp_cur;
     fetch emp_cur into v_rec;
          dbms_output.put_line(v_rec.last_name);
     fetch emp_cur into v_rec;
          dbms_output.put_line(v_rec.last_name);          
     close emp_cur;
end;
/
/* NOTE
   fetch행위는 active set 만큼(여기서 2번) 실시해야 함. 만약 active set이 많아지면
   어떡하지?? 그래 loop를 돌려서 해결하자(아래로) */
--------------------------------------------------------------------------------

declare
     cursor emp_cur is
         select * from employees where department_id = 20;
     v_rec emp_cur%rowtype;
begin
     open emp_cur; 
     loop
       fetch emp_cur into v_rec;
           exit when emp_cur%notfound;
           dbms_output.put_line(v_rec.last_name);
     end loop;
     close emp_cur;
end;
/
/* NOTE
   loop로 하니까 한결 편하군! 그런데 선생님은 이 것은 성능에 문제 있다고 하신다.(아래로) */
--------------------------------------------------------------------------------
/* 선생님 왈 : 
명시적 커서는 declare, open, fetch, close를 지정해 주게 되는데 
이 때 fetch를 active set 결과 만큼 해야 함
compile engine(virtual machine)은 sql엔진, plsql엔진 총 2가지
위 문장은 plsql문이므로 처음에 plsql엔진이 받아 compile하는데 이 안에 있는 
select문은 plsql엔진이 처리 못해서 sql엔진에 처리하도록 요청. 
sql엔진이 parse, bind, execute, fetch. 오픈은 plsql문이 하지만 
실제 커서 안의 sql문을 수행하는 주체는 sql엔진. 그런데 변수는 plsql문
sql엔진과 plsql엔진 사이에 문맥 전환이 발생(명시적 커서에서 fetch문이 돌아갈 때). 
데이터가 많아질수록 문맥전환 많이 발생(active set 결과만큼). 
문맥전환을 1번으로 끝내려면 어떻게 하면 될까?
*/
--------------------------------------------------------------------------------
/* bulk collect into : 10g이후
- active set 결과를 변수로 한번에 로드(fetch 문맥전환 1번에 가능)
- 명시적 커서를 선언할 필요도 없고, open/fetch/close 할 필요도 없음
*/

/* nested table style */
declare
    type tab_type is table of employees%rowtype; --> record 타입, arr 타입
    v_tab tab_type; --> v_tab : 2차원 배열
begin
    select * 
    bulk collect into v_tab
    from employees
    where department_id = 20;
       dbms_output.put_line(sql%rowcount);
    for i in v_tab.first..v_tab.last loop
       dbms_output.put_line(v_tab(i).last_name);
    end loop;
end;
/

/* 위는 명시적 커서이지만 이름이 없어서 속성을 이용하지 못함(아래 개선사항) */
declare
     cursor emp_cur is
         select * from employees where department_id = 20;
     type tab_type is table of emp_cur%rowtype;
     v_arr2 tab_type;
begin
     open emp_cur; 
     fetch emp_cur bulk collect into v_arr2;
       for i in v_arr2.first..v_arr2.last loop
           dbms_output.put_line(v_arr2(i).last_name);
       end loop;
     close emp_cur;
end;
/

================================================================================

drop table emp purge;

create table emp as select * from employees;


begin
     delete from emp where department_id = 10;
     delete from emp where department_id = 20;
     delete from emp where department_id = 30;
end;
/
/* NOTE 실행계획 1개로 할 수 없을까? (아래로) */
--------------------------------------------------------------------------------

/* 그냥 loop */
declare 
    num number := 10;
begin 
    loop
     exit when num > 30;
     delete from emp where department_id = num;
     dbms_output.put_line(sql%rowcount || ' rows deleted');
     num := num + 10;
    end loop;
end;
/

--------------------------------------------------------------------------------
declare
    type num_list is table of number;
    v_num num_list := num_list(10,20,30);
begin
      delete from emp where department_id = v_num(1); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');
      delete from emp where department_id = v_num(2); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');
      delete from emp where department_id = v_num(3); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');      
end;
/
/* NOTE 실행계획은 1개만 작성, 코드작성 1번만 하려면? (아래로)*/
--------------------------------------------------------------------------------

declare
    type num_list is table of number;
    v_num num_list := num_list(10,20,30);
begin
    for i in v_num.first..v_num.last loop
      delete from emp where department_id = v_num(i); 
      dbms_output.put_line(sql%rowcount || ' rows deleted');
    end loop;
end;
/
/* NOTE 위와 동일하게 문맥전환은 3번 발생함 */

--------------------------------------------------------------------------------

/* forall문(loop 아님) */
declare
    type num_list is table of number;
    v_num num_list := num_list(10,20,30);
begin
    forall i in v_num.first..v_num.last 
    --> forall : DML문장 전용(혼용안됨), 배열안에 있는 기준해서 할꺼야(문맥전환 감소를 위해 한꺼번에 sql문 sql엔진에게 전달)
        delete from emp where department_id = v_num(i);
    for i in v_num.first..v_num.last loop
        dbms_output.put_line(sql%bulk_rowcount(i) || ' rows deleted');
    --> sql%bulk_rowcount(i) 새로운 속성(forall 전용)
    end loop;
    rollback;
end;
/
/* NOTE 문맥전환이 1번만 발생함 */

--------------------------------------------------------------------------------

declare
    type num_list is table of number;
    v_num num_list := num_list(10,11,12,6,20,50,5,30,40,7); 
     --> 인수에 0이 있어서 실패하면 이전까지 dml작업도 전부 자동롤백
begin
    forall i in v_num.first..v_num.last 
        delete from emp where salary > 500000/v_num(i);
    for i in v_num.first..v_num.last loop
        dbms_output.put_line(sql%bulk_rowcount(i) || ' rows deleted');
    end loop;
    rollback;
end;
/