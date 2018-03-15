<문제5> 부서테이블에 신규 부서를 입력하는 프로그램을 작성하려고 합니다.
       부서 이름만 입력값으로 받고 부서코드는 마지막 부서 코드에 10을 증가해서 부서코드를
       넣고 관리자번호, 부서 위치는 null값으로 입력하는 프로그램을 작성하세요.
       화면출력 처럼 출력하세요.(dept 테이블을 생성한후 프로그램을 만드세요) 


<화면출력>

신규 부서 번호는 280, 부서 이름 It 입니다.


drop table dept purge;

create table dept as select * from departments;

select * from dept;

desc dept;

var b_dept_name varchar2(30)
exec :b_dept_name := 'It'
print :b_dept_name

declare
      v_dept_id dept.department_id%type;
      v_mgr_id dept.manager_id%type;
      v_loc_id dept.location_id%type;
begin
      select max(department_id)
      into v_dept_id
      from dept;
      v_dept_id := v_dept_id + 10;
      insert into dept
      values(v_dept_id, :b_dept_name, v_mgr_id, v_loc_id);
      dbms_output.put_line('신규 부서 번호는 '||v_dept_id||', 부서 이름 '||:b_dept_name||'입니다.');
      commit;
end;
/

select * from dept;

/* bind변수를 이용해야지 프로그램 1개로 돌릴 수 있다. */

[문제6]사원번호를 입력값으로 받아서 그 사원의 급여를 10%인상하는 프로그램을 수행하세요.
      화면의 출력되는 결과는 수정 전 월급과 수정 후 월급이 아래와 같이 출력 후 transaction은 rollback 하세요.


var b_id number
execute :b_id := 100
print :b_id

수정 전 월급 : 24000
수정 후 월급 : 26400


drop table emp purge;
create table emp as select * from employees;

declare
       v_sal emp.salary%type;
begin
       select salary
       into v_sal
       from emp
       where employee_id = :b_id;
       
       dbms_output.put_line('수정 전 월급 : '||v_sal);
       
       v_sal := v_sal * 1.10;
       
       update emp
       set salary = v_sal;
       dbms_output.put_line('수정 후 월급 : '||v_sal);
       rollback;
end;
/

/* returning : 튜닝(update + select 기능) */

declare
       v_sal emp.salary%type;
       v_name emp.last_name%type;
begin
       select salary
       into v_sal
       from emp
       where employee_id = :b_id; 
       
       dbms_output.put_line('수정 전 월급 : '||v_sal);
       
       update emp
       set salary = salary * 1.1
       where employee_id = :b_id
       returning last_name, salary into v_name, v_sal;
       
       dbms_output.put_line(v_name||'수정 후 월급 : '||v_sal);
       
       rollback;
end;
/       

[문제7] 사원번호를 입력값으로 받아서 그 사원을 삭제하는 프로그램을 수행하세요.
화면의 출력되는 결과는 아래와 같이 출력 후 transaction은 rollback 하세요.
(emp 테이블 사용하세요.)

<화면출력>

삭제된 사원의 사원 번호는 100 이고  사원의 이름은 King 입니다.

var b_id number
execute :b_id := 100

declare
       v_name emp.last_name%type;
begin
       delete from emp
       where employee_id = :b_id
       returning last_name into v_name; --> delete에 사용시 삭제이전 값 fetch

       dbms_output.put_line('삭제된 사원의 사원 번호는 '||:b_id||
       ' 이고  사원의 이름은 '||v_name||' 입니다.');       
       rollback;
end;
/

[문제8] 부서코드를 입력값으로 받아서 그 부서의 근무하는 사원의 인원수를 출력하시고 
        그 부서 사원들의 급여중에 10000 미만인 사원만 10% 인상한 급여로 수정하는 프로그램을 작성하세요.
        화면출력한 후 rollback 하세요.(emp 테이블 사용하세요)


<화면출력>

20 부서의 인원수는  2명 입니다.
20 부서의 수정된 ROW의 수는 1 입니다.

desc emp;
var b_id number
execute :b_id := 20

declare
       v_cnt emp.employee_id%type; --> 그냥 number로 하는게 나아보임
begin
       select count(*)
       into v_cnt
       from emp
       where department_id = :b_id;
       dbms_output.put_line(:b_id||' 부서의 인원수는 '||v_cnt||'명 입니다.');
       
       update emp
       set salary = salary * 1.10
       where salary < 10000
       and department_id = :b_id;
       dbms_output.put_line(:b_id||' 부서의 수정된 ROW의 수는 '||sql%rowcount||' 입니다.');
       
       rollback;
end;
/


================================================================================

/* 조건제어문 */

-- if문

IF 조건 THEN
  참값
ELSIF 조건 THEN --> elsif : 옵션
  참값
ELSIF 조건 THEN
  참값
ELSE
  기본값
END IF;

[문제9] 나이에 따른 유아, 어린이, 청소년, 성인 출력하시오
유아 : 1세 이상 6세 미만
어린이 : 6세 이상 13세 미만
청소년 : 13세 이상 19세 미만
성인 : 19세 이상

declare
     v_myage number := 19;
begin
     if v_myage >= 1 and v_myage < 6 then
            dbms_output.put_line('유아');     
     elsif v_myage >= 6 and v_myage < 13 then
            dbms_output.put_line('어린이');
     elsif v_myage >= 13 and v_myage < 19 then
            dbms_output.put_line('청소년');
     else   dbms_output.put_line('성인');
     end if;
end;
/

[문제10] 숫자를 입력값 받아서 짝수 인지 홀수 인지를 출력하는 프로그램을 작성하세요.

var v_a number
execute :v_a := 7

홀수입니다.


var v_num number
exec :v_num := 7

begin
    if mod(:v_num,2) = 0 then
       dbms_output.put_line('짝수입니다');
    else 
       dbms_output.put_line('홀수입니다');       
    end if;
end;
/

[문제11]두개의 숫자를 입력해서 해당 숫자의 차이값을 출력하세요.
숫자를 어떻게 입력하던 큰 숫자에서 작은 숫자를 빼게 if 문을 구성하세요.

var v_a number
var v_b number
execute :v_a := 10
execute :v_b := 7

print v_a v_b

declare
     v_c number;
begin
     if :v_a < :v_b then
        v_c := :v_b - :v_a;
        dbms_output.put_line('차이값 : '||v_c);
     elsif :v_a > :v_b then
        v_c := :v_a - :v_b;
        dbms_output.put_line('차이값 : '||v_c);
     else 
        dbms_output.put_line('차이값 : 0');  
     end if;
end;
/

declare
     v_c number;
begin
     if :v_a <= :v_b then
        v_c := :v_b - :v_a;
        dbms_output.put_line('차이값 : '||v_c);
     elsif :v_a > :v_b then
        v_c := :v_a - :v_b;
        dbms_output.put_line('차이값 : '||v_c);
     end if;
end;
/

[문제12] 사원번호를 입력값으로 받아서 그 사원의 근무개월수를 출력하고 근무개월수가
150개월 이상이면 급여를 20% 인상한 급여로 수정, 
149개월 보다 작거나 같고 100개월 보다 크거나 같으면  10%인상한 급여로 수정,
100개월 미만인 근무자는 아무 작업을 수행하지 않는 프로그램을 작성하세요.
테스트가 끝나면 rollback 합니다.(emp 테이블 사용)

<화면 출력>
100 사원은 근무개월수가 154 입니다. 급여는 20% 수정되었습니다.

<화면 출력>
166 사원은 근무개월수가 97 입니다. 100 개월 미만이므로  급여 수정 안됩니다.


-- months_between
-- if문 사용
select employee_id, hire_date, sysdate, round(months_between(sysdate, hire_date))
from emp;

var b_id number
exec :b_id := 166

declare
     v_wk number;
     v_sal emp.salary%type;
begin
     select round(months_between(sysdate, hire_date)), salary 
     into v_wk, v_sal
     from emp 
     where employee_id = :b_id;
     
     if v_wk >= 150 then
             v_sal := v_sal * 1.2;
             dbms_output.put_line(:b_id||'사원은 근무개월수가 '||v_wk||'입니다. 급여는 20% 수정되었습니다.');
     elsif v_wk >= 100 and v_wk <= 149 then
             v_sal := v_sal * 1.1;
             dbms_output.put_line(:b_id||'사원은 근무개월수가 '||v_wk||'입니다. 급여는 10% 수정되었습니다.');  
     else 
             dbms_output.put_line(:b_id||'사원은 근무개월수가 '||v_wk||'입니다. 100개월 미만이므로  급여 수정 안됩니다.');
     end if; 
     
     update emp
     set salary = v_sal
     where employee_id = :b_id;
     rollback;
end;
/

================================================================================

/* case 표현식(함수) */

case 기준값
       when 비교1 then 참값1
       when 비교2 then 참값2
       else
            기본값
end

-- 규칙. v_a := 'a' 프로시저문(단일행함수(decode 제외한) 사용가능, 그룹함수 사용불가)

var b_name varchar2(20)
begin                   
   :b_name := '문광표';  --> exec 개념
end;
/
print :b_name


declare
      v_grade char(1) := upper('c'); --> 프로시저문
      v_appraisal varchar2(30);
begin
      v_appraisal := case v_grade
                        when 'A' then '참잘했어요'
                        when 'B' then '잘했어요'
                        when 'C' then '다음에잘해요'
                        else '니가사람이야!!'
                     end;
      dbms_output.put_line('등급은' || v_grade ||', 평가는' || v_appraisal);
end;
/


declare
      v_grade char(1) := upper('d'); --> 프로시저문
      v_appraisal varchar2(30);
begin
      v_appraisal := case
                        when v_grade = 'A' then '참잘했어요'
                        when v_grade in ('B','C') then '잘했어요'
                        else '니가사람이야!!'
                     end;
      dbms_output.put_line('등급은' || v_grade ||', 평가는' || v_appraisal);
end;
/

/* case문으로 풀이한 문제 12 : then 이후 sql문 들어올수 없음 */

declare
	v_mon number;
begin
	SELECT trunc(months_between(sysdate, hire_date))
	INTO v_mon
	FROM emp
	WHERE employee_id = :b_id;

	case  
	 when v_mon >= 150 then

		UPDATE emp
		SET salary = salary * 1.20
		WHERE employee_id = :b_id;

		dbms_output.put_line(:b_id||' 사원은 근무개월수가 '
                                 ||v_mon||' 입니다. 급여는 20% 수정되었습니다.');
	 when v_mon between 100 and 149 then

		UPDATE emp
		SET salary = salary * 1.10
		WHERE employee_id = :b_id;
			dbms_output.put_line(:b_id||' 사원은 근무개월수가 '
                                 ||v_mon||' 입니다. 급여는 10% 수정되었습니다.');
	 else
		
		dbms_output.put_line(:b_id||' 사원은 근무개월수가 '||v_mon||' 입니다. 100 개월 미만이므로  급여 수정 안됩니다.');

	end case;
	
	rollback;
	
end;
/


================================================================================

/* 반복문 
1. loop문
2. while문
3. for문
*/

/* 기본 loop 구조 : 1 ~ 10 출력하기 */
declare
     i number := 1;
begin
     loop 
        dbms_output.put_line(i);
        i := i + 1; 
        if i > 10 then
             exit; --> pl/sql문으로 loop 구조(기본,while,for) 안에서만 사용해야함(무한루프 방지)
        end if;
     end loop;
end;
/


declare
     i number := 1;
begin

     loop 
        dbms_output.put_line(i);
        i := i + 1; 
        exit when i > 10; --> 결과 when 조건
     end loop;
     
end;
/


/* while loop 구조 */

declare 
      i number := 1;
begin
      while i <= 10 loop
              dbms_output.put_line(i);
              i := i + 1;
      end loop;
end;
/

/* for loop 구조 */

begin
      for i in 1..10 loop               --> i : count 변수, 선언할 필요 없음
              dbms_output.put_line(i);   --> i := i + 1 (암시적으로 이렇게 고정)
      end loop;
end;
/

begin
      for i in reverse 1..10 loop         --> reverse : 역순으로
              dbms_output.put_line(i);  
      end loop;
end;
/
[문제13]
화면의 숫자 1 부터 10 까지 출력하는 프로그램을 작성합니다. 단 4,8번은 출력하지 마세요.

<화면출력>
1
2
3
5
6
7
9
10

/* 풀이1. 기본 loop */
declare
     i number := 1;
begin
     loop 
        dbms_output.put_line(i);
        i := i + 1; 
        if i > 3 then exit;
        end if;
     end loop;
     
      loop
        i := i + 1;
        dbms_output.put_line(i); 
        if i > 6 then exit;
        end if;
     end loop;

      loop
        i := i + 2;
        dbms_output.put_line(i);   
        i := i - 1;
        if i = 9 then exit;
        end if;
     end loop;
end;
/

/* 풀이2. for loop */
begin
      for i in 1..10 loop    
       if i = 4 or i = 8 then
          null;
       else  
          dbms_output.put_line(i);
       end if;   
      end loop;
end;
/


begin
     for i in 1..10 loop
         if i<> 4 and i<>8 then
          dbms_output.put_line(i);
         else
            null;
         end if;
     end loop;
end;
/

begin 
    for i in 1..10 loop
      if i <> 4 and i<> 8 then
        dbms_output.put_line(i);
      end if;
    end loop;
end;
/

/* 풀이3. while */

declare
      i number := 1;
begin
      while i <= 10 loop
        if i = 4 or i = 8 then
          null;
        else 
          dbms_output.put_line(i);
        end if;
          i := i + 1;
      end loop;
end;
/

/* 풀이4. 기본 개선 */

declare
      i number := 1;
begin
    loop
      if i = 4 or i = 8 then
         null;
      else
         dbms_output.put_line(i);
      end if;  
      i := i + 1;
        exit when i > 10;
    end loop; 
end;
/


/* reverse */
declare 
      v_a number := 1;
      v_b number := 10;
begin
      for i in reverse v_a..v_b loop
          if i=4 or i=8 then
             null;
          else 
             dbms_output.put_line(i);
          end if;
      end loop;
end;
/


