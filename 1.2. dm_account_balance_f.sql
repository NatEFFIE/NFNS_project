--создать представление для переноса таблицы в витрину dm.dm_account_balance_f

create or replace view ds.vw_balance_out as

(with e as
 (select a.account_rk,
	   e.data_actual_date,
	   e.data_actual_end_date,
	   e.reduced_cource
from ds.md_account_d a
join ds.md_currency_d c using(currency_rk)
join ds.md_exchange_rate_d e using(currency_rk))


select b.on_date,
	   b.account_rk,
	   b.currency_rk,
	   b.balance_out,
	   b.balance_out * coalesce(e.reduced_cource, 1) as balance_out_rub
from ds.ft_balance_f b
join e on e.account_rk = b.account_rk
      and b.on_date between e.data_actual_date and e.data_actual_end_date);


--создаем таблицу с остатками 
create table if not exists dm.dm_account_balance_f
as select * from ds.vw_balance_out;


--создаем процедуру на заполнение

create or replace procedure ds.fill_account_balance_f(i_OnDate DATE)
as $$
declare
    v_account_rk INT;
    v_balance_out NUMERIC;
    v_balance_out_rub NUMERIC;
begin
    insert into dm.dm_account_balance_f(on_date, account_rk, currency_rk, balance_out, balance_out_rub)
    select i_OnDate, b.account_rk, md.currency_rk,
    case 
        when md.char_type = 'А' then coalesce(b.balance_out, 0) + coalesce(dt.debet_amount, 0) - coalesce(dt.credit_amount, 0)
        when md.char_type = 'П' then coalesce(b.balance_out, 0) - coalesce(dt.debet_amount, 0) + coalesce(dt.credit_amount, 0)
    end as balance_out,
    case 
        when md.char_type = 'А' then coalesce(b.balance_out_rub, 0) + coalesce(dt.debet_amount_rub, 0) - coalesce(dt.credit_amount_rub, 0)
        when md.char_type = 'П' then coalesce(b.balance_out_rub, 0) - coalesce(dt.debet_amount_rub, 0) + coalesce(dt.credit_amount_rub, 0)
    end as balance_out_rub
	from ds.md_account_d md
	left join lateral(
        select ba.account_rk, ba.balance_out, ba.balance_out_rub
        from dm.dm_account_balance_f ba
        where ba.account_rk = md.account_rk and ba.on_date = i_OnDate - interval '1 day'
        limit 1
    ) b on TRUE
    left join DM.DM_ACCOUNT_TURNOVER_F dt on dt.account_rk = md.account_rk and dt.on_date = i_OnDate;
    
end;
$$
language plpgsql;

-- запускаем

do $$
 declare 
  v_date date := to_date('2018.01.01', 'YYYY.MM.DD');
 begin
  while v_date <> to_date('2018.02.01', 'YYYY.MM.DD') loop
   call ds.fill_account_balance_f(v_date);
    v_date := v_date + 1;
  end loop;
 end$$;

--проверка
select * from dm.dm_account_balance_f
order by account_rk, on_date;
