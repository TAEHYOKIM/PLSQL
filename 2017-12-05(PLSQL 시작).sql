/* 
PL/SQL = PL(Procedure Language) SQL(Structured Query Language)
 - IBM 출신 DB2 작업하던 개발자들이 나와서 오라클 만듬
 - SQL + a(노트 참조)
*/

/* 1.DBA SESSION */
alter system flush shared_pool; --> 2번 실시, shared_pool 메모리 초기화


/* 2.HR SESSION */
select * from hr.employees where employee_id = 100;
select * from hr.employees where employee_id = 101;
select * from hr.employees where employee_id = 102;
select * from hr.employees where employee_id = 103;


/* 3.DBA SESSION */
select sql_id, sql_text, parse_calls, executions --> parse_calls : 조회횟수, executions : 실행횟수
from v$sql -->  shared_pool에 있는 sql문 lib.cache 값 본다
where sql_text like '%hr.employee%'
and sql_text not like '%v$sql%';



/* 실행계획 확인 : 중복되는 SQL문, 메모리 및 CPU 사용량 나빠짐 --> PL/SQL로 변수 처리해야 함*/
select * from table(dbms_xplan.display_cursor('82mnzcywm53rs'));
select * from table(dbms_xplan.display_cursor('czmhpuznkxr1r'));
select * from table(dbms_xplan.display_cursor('2sgjc8u8ha0m4'));
select * from table(dbms_xplan.display_cursor('crmr8navwm6mf'));

/* 1행씩 출력(DBMS 창) */
BEGIN
      DBMS_OUTPUT.PUT_LINE('오늘 행복하자');
END;
/

declare
  /* scalar data type(단일값만 보유하는 변수) */
       v_a number(7);  --> null이 초기값으로
       v_b number(3) := 100;
       v_c varchar2(10) not null := 'oracle';  --> not null 선언시 초기값 설정 필수
       v_d constant date default sysdate;
       v_e constant number(7) := 7;  --> 상수선언시 초기값 설정 필수, 다른값 입력제한
                                     /* v_d := sysdate; -- error */
begin 
      dbms_output.put_line(v_a);
      dbms_output.put_line(v_b);
      dbms_output.put_line(v_c);
      dbms_output.put_line(v_d);
      dbms_output.put_line(v_e);

end;
/

var g_total number --> 글로벌 변수 : 바인드변수를 프로그램 내/외부 사용가능

declare
       v_sal number := 10000; --> 로컬변수 : 프로그램 내부에서만 사용가능
       v_comm number := 100; 
begin
      :g_total := v_sal + v_comm; --> ':'의미는 프로그램 외부에서 변수를 불러옴
end;
/

print :g_total

select * from employees where salary > :g_total;
