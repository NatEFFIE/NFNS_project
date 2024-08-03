--корректное поле account_in_sum

with tt as 

(select *,
       lead(account_in_sum) over(partition by account_rk order by effective_date) as b_out
  from dm.account_balance_turnover)
	
select account_rk,
	   currency_name,
	   department_rk,
	   effective_date,
	   account_in_sum,
	   coalesce(b_out, account_out_sum) as account_out_sum
  from tt;

--корректное поле account_out_sum

with tt as 

(select *,
       lag(account_out_sum) over(partition by account_rk order by effective_date) as b_out
  from dm.account_balance_turnover)
	
select account_rk,
	   currency_name,
	   department_rk,
	   effective_date,
	   coalesce(b_out, account_in_sum) as account_in_sum,
       account_out_sum
  from tt;

-- создаем view для переноса значений

create or replace view bo

as

(with tt as 

(select *,
       lead(account_in_sum) over(partition by account_rk order by effective_date) as b_out
  from dm.account_balance_turnover)
	
select account_rk,
	   currency_name,
	   department_rk,
	   effective_date,
	   account_in_sum,
	   coalesce(b_out, account_out_sum) as account_out_sum
  from tt);

-- обновляем rd.account_balance
update rd.account_balance ab
   set account_out_sum = bo.account_out_sum
  from bo
 where ab.account_rk = bo.account_rk
   and ab.effective_date = bo.effective_date;

--создаем процедуру

create procedure pr_turnover (INTEGER)
as 
$$
 begin
     create table if not exists dm.b_a_turnover(account_rk INT, currency_name TEXT, 
	                                            department_rk INT, effective_date DATE,
	                                            account_in_sum NUMERIC(8,2), account_out_sum NUMERIC(8,2));

     insert into dm.b_a_turnover(account_rk, currency_name, department_rk, effective_date, account_in_sum, account_out_sum)
	 select a.account_rk,
	   COALESCE(dc.currency_name, '-1'::TEXT) AS currency_name,         
	   a.department_rk,
	   ab.effective_date,
	   ab.account_in_sum,
	   ab.account_out_sum
     from rd.account a
     left join rd.account_balance ab on a.account_rk = ab.account_rk
     left join dm.dict_currency dc on a.currency_cd = dc.currency_cd;
  end;
$$
language plpgsql;

