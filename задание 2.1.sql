with add_tab as

(select *, 
	row_number() over(partition by client_rk, effective_from_date) as r
from dm.client)

select *
from add_tab
where r = 1;