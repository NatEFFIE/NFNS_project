create or replace procedure dm.fill_f101_round_f(i_OnDate DATE) as
$$
  begin
    create table if not exists dm.dm_f101_round_f(
                 from_date DATE,
                 to_date DATE,
                 chapter CHAR(1),
                 ledger_account VARCHAR(5),
                 characteristic VARCHAR(5),
                 balance_in_rub DECIMAL(23,8),
                 balance_in_val DECIMAL(23,8),
                 balance_in_total DECIMAL(23,8),
                 turn_deb_rub DECIMAL(23,8),
                 turn_deb_val DECIMAL(23,8),
                 turn_deb_total DECIMAL(23,8),
                 turn_cre_rub DECIMAL(23,8),
                 turn_cre_val DECIMAL(23,8),
                 turn_cre_total DECIMAL(23,8),
                 balance_out_rub DECIMAL(23,8),
                 balance_out_val DECIMAL(23,8),
                 balance_out_total DECIMAL(23,8)
                 );
         
          delete from dm.dm_f101_round_f where from_date = date_trunc('month', i_OnDate - INTERVAL '1 month');

          insert into dm.dm_f101_round_f (from_date, to_date, chapter, 
			  ledger_account, characteristic, balance_in_rub, 
			  balance_in_val, balance_in_total, turn_deb_rub, 
			  turn_deb_val, turn_deb_total, turn_cre_rub, turn_cre_val, 
			  turn_cre_total, balance_out_rub, balance_out_val, balance_out_total)

           select 
              date_trunc('month', i_OnDate - INTERVAL '1 month - 1 day') as from_date,
              date_trunc('month', i_OnDate) - INTERVAL '1 day' as to_date,
              ld.chapter,
              substring(acc.account_number, 1, 5) as ledger_account,
	          acc.char_type as characteristic,
			  
			 sum(case when acc.currency_code in ('810', '643') and af.on_date = date_trunc('month', i_OnDate - INTERVAL '1 month - 1 day') - INTERVAL '1 day'  
			  then tf.credit_amount_rub else 0 end) as balance_in_rub, 
			  sum(case when acc.currency_code not in ('810', '643') and af.on_date = date_trunc('month', i_OnDate - INTERVAL '1 month - 1 day') - INTERVAL '1 day'
			  then tf.credit_amount_rub else 0 end) as balance_in_val,
			  sum(case when af.on_date = date_trunc('month', i_OnDate - INTERVAL '1 month - 1 day') - INTERVAL '1 day'
			  then tf.credit_amount_rub else 0 end) as balance_in_total,

			  sum(case when acc.currency_code in ('810', '643') then tf.debet_amount_rub
			           else 0 end) as turn_deb_rub,
			  sum(case when acc.currency_code not in ('810', '643') then tf.debet_amount_rub
			           else 0 end) as turn_deb_val,
			  sum(tf.debet_amount_rub) as turn_deb_total,

			  sum(case when acc.currency_code in ('810', '643') then tf.credit_amount_rub
			           else 0 end) as turn_cre_rub,
			  sum(case when acc.currency_code not in ('810', '643') then tf.credit_amount_rub
			           else 0 end) as turn_cre_val,
			  sum(tf.credit_amount_rub) as turn_cre_total,

			  sum(case when acc.currency_code in ('810', '643') and af.on_date = date_trunc('month', i_OnDate) - INTERVAL '1 day'  
			  then tf.credit_amount_rub else 0 end) as balance_out_rub, 
			  sum(case when acc.currency_code not in ('810', '643') and af.on_date = date_trunc('month', i_OnDate) - INTERVAL '1 day'
			  then tf.credit_amount_rub else 0 end) as balance_out_val,
			  sum(case when af.on_date = date_trunc('month', i_OnDate) - INTERVAL '1 day'
			  then tf.credit_amount_rub else 0 end) as balance_out_total

              from ds.md_ledger_account_s ld
    join ds.md_account_d acc on ld.ledger_account = substring(acc.account_number, 1, 5):: integer
    left join dm.dm_account_balance_f af 
	on acc.account_rk = af.account_rk
    left join dm.dm_account_turnover_f tf 
	on acc.account_rk = tf.account_rk 
    group by 1,2,3,4,5;
end;
$$
language plpgsql;

--вызов процедуры
call dm.fill_f101_round_f(to_date('2018-02-01', 'YYYY-MM-DD'));

     