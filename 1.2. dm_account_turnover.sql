--создание представления
create or replace view ds.vw_dm_account_turnover as

(with c as
(select oper_date,
	   credit_account_rk,
       sum(credit_amount) as credit_amount
  from ds.ft_posting_f 
 group by oper_date, credit_account_rk),
	
d as
(select oper_date,
	   debet_account_rk,
       sum(debet_amount) as debet_amount	   
  from ds.ft_posting_f f 
 group by oper_date, debet_account_rk),
e as
 (select a.account_rk,
	   e.data_actual_date,
	   e.data_actual_end_date,
	   e.reduced_cource
from ds.md_account_d a
join ds.md_currency_d c using(currency_rk)
join ds.md_exchange_rate_d e using(currency_rk))
	
select c.oper_date,
       c.credit_account_rk as account_rk,
       c.credit_amount,
	   c.credit_amount * coalesce(e.reduced_cource, 1) as credit_amount_rub,
       coalesce(d.debet_amount, 0) as debet_amount,
	   coalesce(d.debet_amount, 0) * coalesce(e.reduced_cource, 1) as debet_amount_rub
from c left join d on c.credit_account_rk = d.debet_account_rk
              and c.oper_date = d.oper_date
	   join e 
	     on c.oper_date between e.data_actual_date and e.data_actual_end_date
	    and e.account_rk = c.credit_account_rk

union

select d.oper_date,
       d.debet_account_rk as account_rk,
       c.credit_amount,
	   coalesce(c.credit_amount, 0) * coalesce(e.reduced_cource, 1) as credit_amount_rub,
       coalesce(d.debet_amount, 0) as debet_amount,
	   coalesce(d.debet_amount, 0) * coalesce(e.reduced_cource, 1) as debet_amount_rub
from d left join c on c.credit_account_rk = d.debet_account_rk
              and c.oper_date = d.oper_date
	   join e 
	     on c.oper_date between e.data_actual_date and e.data_actual_end_date
	     and e.account_rk = d.debet_account_rk
order by 1,2);




--cоздание процедуры

create or replace procedure ds.fill_account_turnover_f(i_OnDate DATE)
as
$$
  begin 
	  create table if not exists dm.dm_account_turnover_f
                   (on_date DATE,
	                account_rk INTEGER,
	                credit_amount NUMERIC(25,4),
	                credit_amount_rub NUMERIC(25,4),
	                debet_amount NUMERIC(25,4),
	                debet_amount_rub Numeric(25,4));
     
      insert into dm.dm_account_turnover_f
	  select * from ds.vw_dm_account_turnover
		where oper_date = i_OnDate;

  end;
$$
language plpgsql;

--drop procedure ds.fill_account_turnover_f

--запуск процедуры 

do $$
 declare 
  v_date date := to_date('2018.01.01', 'YYYY.MM.DD');
 begin
  while v_date <> to_date('2018.02.01', 'YYYY.MM.DD') loop
   call ds.fill_account_turnover_f(v_date);
    v_date := v_date + 1;
  end loop;
 end$$;

--проверка
select * from dm.dm_account_turnover_f;