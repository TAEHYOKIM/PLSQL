[문제14] 1번부터 100까지 짝수만 출력하세요.
/* 풀이1. for loop */
begin
  for i in 1..100 loop
   if mod(i,2)=0 then
    dbms_output.put_line(i);
   end if;
  end loop;
end;
/

/* 풀이2. while loop */
declare
     i number := 2;
begin
    while i <= 100 loop
     dbms_output.put_line(i);
     i := i + 2;
    end loop;
end;
/

/* 풀이3. 기본 loop */
declare
      i number := 2;
begin
      loop 
        dbms_output.put_line(i);
        i := i + 2;
        exit when i > 100;
      end loop;
end;
/


[문제15] 1번부터 100까지 홀수만 출력하세요.
/* 풀이1. for loop */
begin
  for i in 1..100 loop
   if mod(i,2)=1 then
    dbms_output.put_line(i);
   end if;
  end loop;
end;
/

/* 풀이2. while loop */
declare
     i number := 1;
begin
    while i <= 100 loop
     dbms_output.put_line(i);
     i := i + 2;
    end loop;
end;
/

/* 풀이3. 기본 loop */
declare
      i number := 1;
begin
      loop 
        dbms_output.put_line(i);
        i := i + 2;
        exit when i > 100;
      end loop;
end;
/


[문제16] 구구단 2단 출력하는 프로그램을 작성하세요.

2 * 1 = 2
2 * 2 = 4
2 * 3 = 6
2 * 4 = 8
2 * 5 = 10
2 * 6 = 12
2 * 7 = 14
2 * 8 = 16
2 * 9 = 18

begin
   for i in 1..9 loop
    dbms_output.put_line('2 * '||i||' = '||2 * i);
   end loop;
end;
/

[문제17]
단을 입력값으로 받아서 그 단에 대해서만 출력하시고 만약에 단 입력값이 없으면 전체 구구단이 출력되도록 작성하세요.

var b_dan number

execute :b_dan := 2

execute :b_dan := null

begin
    for i in 1..9 loop
      if :b_dan is not null then
        dbms_output.put_line(:b_dan||' * '||i||' = '||:b_dan*i);
      else
        for j in 1..9 loop
         dbms_output.put_line(i||' * '||j||' = '||i*j);
        end loop;
      end if;  
    end loop;
end;
/

/* 다른 loop문이 섞여도 작동은 된다 */
declare
    i number := 1;
begin
    while i < 10 loop
      if :b_dan is not null then
        dbms_output.put_line(:b_dan||' * '||i||' = '||:b_dan*i);
      else
        for j in 1..9 loop
         dbms_output.put_line(i||' * '||j||' = '||i*j);
        end loop;
      end if;
      i := i + 1;
    end loop;
end;
/

begin
   for i in 1..10 loop
     dbms_output.put_line('*');
     for j in i..i+1 loop
       dbms_output.put_line(' *');
       dbms_output.put_line('*');
     end loop;
   end loop;
end;
/

DECLARE
    v_gogo number;
BEGIN
    FOR i IN 1..9 LOOP
        FOR v_gogo IN 1..9 LOOP
            IF i <= 9 THEN
                DBMS_OUTPUT.PUT_LINE( i ||'*'|| v_gogo ||'='|| (i * v_gogo));
            END IF;
        END LOOP;
    END LOOP;
END;
/

[문제18]구구단 2단을 for loop 문으로 출력하는데 2 * 6은 제외 시켜주세요.

2 * 1 = 2
2 * 2 = 4
2 * 3 = 6
2 * 4 = 8
2 * 5 = 10
2 * 7 = 14
2 * 8 = 16
2 * 9 = 18

begin
  for i in 1..9 loop
   if i<>6 then
    dbms_output.put_line('2 * '||i||' = '||2 * i);    
   end if;
  end loop;
end;
/

/* continue문 : 11g부터 나온 기능 */
begin
  for i in 1..9 loop
    continue when i = 6; --> continue when 조건 : 조건이 참이면 수행 안하고 다음 루프
    dbms_output.put_line('2 * '||i||' = '||2 * i);    
  end loop;
end;
/


[문제19] 사원 테이블의 employee_id, last_name 을 출력하는 프로그램입니다.
       사원번호는 100번 부터 해서 5씩 증가한 정보를 출력하시고 120번으로 끝내도록 해주세요.
 
<화면 출력>

100  King
105  Austin
110  Chen
115  Khoo
120  Weiss


declare
    v_lname employees.last_name%type;
begin
    for i in 100..120 loop
      if mod(i,5)=0 then
          select last_name
          into v_lname
          from employees
          where employee_id = i;
          
        dbms_output.put_line(i || ' ' || v_lname);
      end if;
    end loop;
end;
/

var v_id number
exec 

declare
    v_lname employees.last_name%type;
    v_id employees.employee_id%type := 100;
begin
    while v_id <= 120 loop
          select employee_id, last_name
          into v_id, v_lname
          from employees
          where employee_id = v_id;
      dbms_output.put_line(v_id || ' ' || v_lname);
      v_id := v_id + 5;
    end loop;
end;
/
set serveroutput off;

[문제20] 사원 번호를 입력 값으로 받아서 그 사원의 급여를 출력하는 프로그램을 작성합니다. 
       또한 급여 1000당 별(*) 하나를 출력해주세요.

<화면출력>
employee_id => 200  salary => 4400
star is => **** 

-- lpad
var b_id number
exec :b_id := 200
print :b_id

select null||'*' from dual;

declare
    v_sal employees.salary%type;
    v_star varchar2(100);
begin
    select salary
    into v_sal
    from employees
    where employee_id = :b_id;
    
    dbms_output.put_line('employee_id => '||:b_id||' salary => '||v_sal);
    
    /* lpad */
    dbms_output.put_line('star is => '||lpad('*',(v_sal/1000),'*'));
    
    /* for loop #1 */
    for i in 1..trunc(v_sal/1000) loop
      v_star := v_star || '*';
    end loop;
      dbms_output.put_line('star is => '||v_star);
      
    /* for loop #2 */
    for i in 1..trunc(v_sal/1000) loop
      dbms_output.put('*');  --> 메모리에만 저장
    end loop;
      dbms_output.new_line;  --> 출력
end;
/
/* put_line : put + new_line */

begin
    select salary
    into v_sal
    from employees
    where employee_id = :b_id;
    
    
end;
/

================================================================================

/* 조합변수(레코드 타입) */

declare
  v_id departments.department_id%type;
  v_name departments.department_name%type;
  v_mgr departments.manager_id%type;
  v_loc departments.location_id%type;
begin
  select department_id, department_name, manager_id, location_id
  into v_id, v_name, v_mgr, v_loc
  from departments
  where department_id = 10;
        dbms_output.put_line(v_id||' '||v_name||' '||v_mgr||' '||v_loc);
end;
/

/* 특징 : 내부구성요소를 직접 만든다 */
declare
 type dept_record_type is record  --> 레코드 변수 내부구성(dept_record_type)
 (
  id number,
  name varchar2(30),
  mgr departments.manager_id%type,
  loc departments.location_id%type
 );
 v_rec dept_record_type;          --> 레코드 변수 선언(v_rec)
begin
  select department_id, department_name, manager_id, location_id
  into v_rec.id, v_rec.name, v_rec.mgr, v_rec.loc
  from departments
  where department_id = 10;
        dbms_output.put_line(v_rec.id||' '||v_rec.name||' '||v_rec.mgr||' '||v_rec.loc);
end;
/

declare
 type dept_record_type is record
 (
  id number,
  name varchar2(30),
  mgr departments.manager_id%type,
  loc departments.location_id%type
 );
 v_rec dept_record_type;
begin
  select department_id, department_name, manager_id, location_id
  into v_rec       --> 순서상 타입 일치되면 간편하게 가능
  from departments
  where department_id = 10;
        dbms_output.put_line(v_rec.id||' '||v_rec.name||' '||v_rec.mgr||' '||v_rec.loc);
end;
/

declare 
    v_rec employees%rowtype;  --> %rowtype : 해당 테이블(employees)의 컬럼들 기반으로 record type 변수 선언
begin
  select *
  into v_rec
  from employees
  where employee_id = 100;
        dbms_output.put_line(v_rec.employee_id||' '||v_rec.last_name);
end;
/

declare
/*
 type dept_record_type is record
 (
  id number,
  name varchar2(30),
  mgr departments.manager_id%type,
  loc departments.location_id%type
 );
 v_rec dept_record_type;
*/
v_rec departments%rowtype;
 
begin
   select *
   into v_rec
   from departments
   where department_id = 10;
         dbms_output.put_line(v_rec.department_id||' '||v_rec.location_id);
end;
/
 

================================================================================

레코드 변수
--------------------
| 숫자 | 문자 | 날짜 |
--------------------

배열 변수
----
숫 자
----
숫 자
----
숫 자
----


begin
    update emp
    set salary = salary * 1.1
    where employee_id = 100;
                 /* 실행계획 2번 만드네.. */
    update emp
    set salary = salary * 1.1
    where employee_id = 200;
end;
/

/* 위 개선방안 */
declare 
    type table_id_type is table of number --> table_id_type : 배열변수 이름, ...of number 1개만
    index by binary_integer;              --> binary_integer : 배열 방번호, 테이블에서 사용하는게 아님

  /*  
    type table_id_type is table of number
    index by pls_integer;         
  */  --> 부호비트 가지고 있어 숫자계산에서 더 빠름 (10g 이상부터)
    
    v_tab table_id_type;
    
begin
    v_tab(1) := 100;
    v_tab(2) := 200;
  
    update emp
    set salary = salary * 1.1
    where employee_id = v_tab(1);       
 /* 같은 update문 됨 하지만 코드가 길어지면 메모리 사용량 증가(shared pool-lib.cache) */
    update emp
    set salary = salary * 1.1
    where employee_id = v_tab(2);    
end;
/


/* 위 개선방법 */

declare 
    type table_id_type is table of number 
    index by binary_integer;              
    v_tab table_id_type;   
begin
    v_tab(1) := 100;
    v_tab(2) := 200;
    
  for i in 1..2 loop
    update emp
    set salary = salary * 1.1
    where employee_id = v_tab(i);
  end loop;
    dbms_output.put_line(sql%rowcount);
  rollback;
end;
/


/* 위 개선방법 */

declare 
    type table_id_type is table of number 
    index by binary_integer;              
    v_tab table_id_type;   
begin
    v_tab(1) := 100;
    v_tab(3) := 200;
    v_tab(5) := 101;
    
  for i in v_tab.first..v_tab.last loop --> v_tab.first : 가장 작은 방번호, v_tab.last : 가장 큰 방번호
    if v_tab.exists(i) then  --> v_tab.exists(i) : i번 요소가 v_tab에 존재하면 True (배열에서만 사용하는 메소드), not exists는 없음
      update emp
      set salary = salary * 1.1
      where employee_id = v_tab(i);
    else
      dbms_output.put_line(i||' 요소번호가 없음');
    end if;
  end loop;
    dbms_output.put_line(sql%rowcount);
  rollback;
end;
/

[문제21]
배열 변수에 있는 100,101,102,103,104,200 사원들의 근무한 개월수를 출력하고 근무개월수가 
150개월이상 되었으면 급여(salary)를 10% 인상한 급여로 수정하는 프로그램 작성하세요.


<출력 결과>

100는 근무개월수가 166 입니다. 급여는 10% 인상되었습니다.
101는 근무개월수가 139 입니다. 급여는 인상할 수 없습니다.
102는 근무개월수가 195 입니다. 급여는 10% 인상되었습니다.
103는 근무개월수가 135 입니다. 급여는 인상할 수 없습니다.
104는 근무개월수가 119 입니다. 급여는 인상할 수 없습니다.
200는 근무개월수가 163 입니다. 급여는 10% 인상되었습니다.


declare
    type table_id_type is table of number 
    index by binary_integer;              
    v_tab table_id_type;  
    
    v_wk number;
begin
    v_tab(1) := 100;
    v_tab(2) := 101;
    v_tab(3) := 102;
    v_tab(4) := 103;
    v_tab(5) := 104;
    v_tab(6) := 200;
  
    for i in v_tab.first..v_tab.last loop
      select trunc(months_between(sysdate,hire_date))
      into v_wk
      from emp
      where employee_id = v_tab(i);
      
      if v_wk >= 150 then
        update emp
        set salary = salary * 1.1
        where employee_id = v_tab(i);
        
        dbms_output.put_line(v_tab(i)||'는 근무개월수가 '||v_wk||'입니다. 급여는 10% 인상되었습니다.');
      else 
        dbms_output.put_line(v_tab(i)||'는 근무개월수가 '||v_wk||'입니다. 급여는 인상할 수 없습니다.');
      end if;
      
    end loop;
end;
/


/* 2차원 배열 */

declare
   type dept_rec_type is record(id number, name varchar2(30), mgr number, loc number);
   v_rec dept_rec_type;
   
   type dept_table_type is table of v_rec%type index by binary_integer; --> 이전에 선언한 변수 그래로 사용가능
   v_tab dept_table_type;
   
   /*
   type dept_table_type is table of dept_rec_type index by binary_integer;
   v_tab dept_table_type;
   */
begin
   for i in 1..5 loop
     select *
     into v_tab(i)
     from departments
     where department_id = i*10;
   end loop;
   
   for i in v_tab.first..v_tab.last loop /*1..5*/
     dbms_output.put_line(v_tab(i).id||v_tab(i).name||v_tab(i).mgr||v_tab(i).loc);
   end loop;
end;
/


declare
   type dept_rec_type is record(id number, name varchar2(30), mgr number, loc number);
   v_rec dept_rec_type;

   type dept_table_type is table of dept_rec_type index by binary_integer;
   v_tab dept_table_type;

begin
   for i in 1..5 loop
     select *
     into v_tab(i)
     from departments
     where department_id = i*10;
   end loop;
   
   for i in 1..5 loop
     dbms_output.put_line(v_tab(i).id||v_tab(i).name||v_tab(i).mgr||v_tab(i).loc);
   end loop;
end;
/


/* 위 개선방안 */
declare
   type emp_table_type is table of employees%rowtype index by binary_integer;
   v_tab emp_table_type;
 --> employees%rowtype : 레코드 선언한 거랑 동일한 효과
begin
   for i in 100..110 loop
     select *
     into v_tab(i)
     from employees
     where employee_id = i;
   end loop;
   
   for i in 100..110 loop
     dbms_output.put_line(v_tab(i).employee_id||' '||v_tab(i).salary);
   end loop;
end;
/


declare
   type emp_rec_type is record(name varchar2(30), sal number, day date); --> 1. record 선언
   type emp_table_type is table of emp_rec_type index by binary_integer; --> 2. 배열 선언
   v_tab emp_table_type;
begin
   for i in 100..110 loop
     select last_name, salary, hire_date
     into v_tab(i)
     from employees
     where employee_id = i;
   end loop;
   
   for i in 100..110 loop
     dbms_output.put_line(v_tab(i).name||' '||v_tab(i).sal||' '||v_tab(i).day);
   end loop;
end;
/


/* 추가설명(넣어야 할 값들을 알고 있을 경우) : nested table data type(중첩배열타입) */
declare 
    type table_id_type is table of number; --> index by binary_integer 빼야함
    v_tab table_id_type := table_id_type(100, 101, 200, 103);  --> 요소 번호는 1~2^31까지 암시적 입력
begin
  for i in v_tab.first..v_tab.last loop
      dbms_output.put_line(i||' : '||v_tab(i));
  end loop;
end;
/
