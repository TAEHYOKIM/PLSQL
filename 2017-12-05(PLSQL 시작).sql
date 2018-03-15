/* 
PL/SQL = PL(Procedure Language) SQL(Structured Query Language)
 - IBM ��� DB2 �۾��ϴ� �����ڵ��� ���ͼ� ����Ŭ ����
 - SQL + a(��Ʈ ����)
*/

/* 1.DBA SESSION */
alter system flush shared_pool; --> 2�� �ǽ�, shared_pool �޸� �ʱ�ȭ


/* 2.HR SESSION */
select * from hr.employees where employee_id = 100;
select * from hr.employees where employee_id = 101;
select * from hr.employees where employee_id = 102;
select * from hr.employees where employee_id = 103;


/* 3.DBA SESSION */
select sql_id, sql_text, parse_calls, executions --> parse_calls : ��ȸȽ��, executions : ����Ƚ��
from v$sql -->  shared_pool�� �ִ� sql�� lib.cache �� ����
where sql_text like '%hr.employee%'
and sql_text not like '%v$sql%';



/* �����ȹ Ȯ�� : �ߺ��Ǵ� SQL��, �޸� �� CPU ��뷮 ������ --> PL/SQL�� ���� ó���ؾ� ��*/
select * from table(dbms_xplan.display_cursor('82mnzcywm53rs'));
select * from table(dbms_xplan.display_cursor('czmhpuznkxr1r'));
select * from table(dbms_xplan.display_cursor('2sgjc8u8ha0m4'));
select * from table(dbms_xplan.display_cursor('crmr8navwm6mf'));

/* 1�྿ ���(DBMS â) */
BEGIN
      DBMS_OUTPUT.PUT_LINE('���� �ູ����');
END;
/

declare
  /* scalar data type(���ϰ��� �����ϴ� ����) */
       v_a number(7);  --> null�� �ʱⰪ����
       v_b number(3) := 100;
       v_c varchar2(10) not null := 'oracle';  --> not null ����� �ʱⰪ ���� �ʼ�
       v_d constant date default sysdate;
       v_e constant number(7) := 7;  --> �������� �ʱⰪ ���� �ʼ�, �ٸ��� �Է�����
                                     /* v_d := sysdate; -- error */
begin 
      dbms_output.put_line(v_a);
      dbms_output.put_line(v_b);
      dbms_output.put_line(v_c);
      dbms_output.put_line(v_d);
      dbms_output.put_line(v_e);

end;
/

var g_total number --> �۷ι� ���� : ���ε庯���� ���α׷� ��/�ܺ� ��밡��

declare
       v_sal number := 10000; --> ���ú��� : ���α׷� ���ο����� ��밡��
       v_comm number := 100; 
begin
      :g_total := v_sal + v_comm; --> ':'�ǹ̴� ���α׷� �ܺο��� ������ �ҷ���
end;
/

print :g_total

select * from employees where salary > :g_total;
