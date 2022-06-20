use sakila;

select * from actor;

show databases;

select now();

show character set;

desc actor;

create view cust_vw as
select customer_id,first_name,last_name,active
from customer;

select first_name,last_name
from cust_vw
where active = 0;

select customer_id,rental_date
from rental
where date(rental_date) = '2005-07-05';

select c.first_name,c.last_name,a.address
from customer c join address a;

#p96
select c.first_name,c.last_name,c.address_id,city,ct.city_id
from customer c
inner join address a
on c.address_id = a.address_id
inner join city ct
on a.city_id = ct.city_id;

#p97
select c.first_name,c.last_name,addr.address,addr.city,a.district
from customer c
inner join
(select a.address_id,a.address,ct.city 
from address a
inner join city ct
on a.city_id = ct.city_id
where a.district LIKE 'California'
) addr
on c.address_id = addr.address_id
inner join address a
on a.address_id = c.address_id;

#99
select f.title
from film f
inner join film_actor fa
on f.film_id = fa.film_id
inner join actor a
on fa.actor_id = a.actor_id
where((a.first_name = 'CATE' and a.last_name = 'MCQUEEN')
or (a.first_name = 'CUBE' and a.last_name = 'BIRCH'));

#p100
select f.title,f_prnt.title prequeladdressaddress
from film f
inner join film f_prnt
on f_prnt.film_id = f.prequel_film_id
where f.prequel_film_id is not null;

select * from address
where city_id = 300;

#p102 自己結合。順番は違うけど、同じ内容が2度出力されることに注意
select distinct a1.city_id,a1.address,a2.address
from address a1
inner join address a2
where a1.city_id = a2.city_id
and a1.address_id <> a2.address_id;

#p110 mysqlではintersectは使用できない
select c.first_name
from customer c
where c.first_name LIKE '%D'
intersect
select a.first_name
from actor a
where a.first_name LIKE '%D';

#intersectの代わりにINやEXISTSを使う。ただし、INは遅いのでEXISTSを使用することが推奨。
#https://tech.pjin.jp/blog/2021/03/31/%E3%80%90sql%E5%85%A5%E9%96%80%E3%80%91%E7%A9%8D%E9%9B%86%E5%90%88/

select c.first_name
from customer c
where c.first_name LIKE '%D'
and c.first_name in(
select a.first_name
from actor a
where a.first_name LIKE '%D');

select c.first_name
from customer c
where c.first_name like '%D' and exists(
select a.first_name
from actor a
where a.first_name LIKE '%D' and a.first_name = c.first_name);

#p112 mysqlではexceptは使用できない
select c.first_name
from customer c
where c.first_name LIKE '%D'
except
select a.first_name
from actor a
where a.first_name LIKE '%D';

#inでも代用できるが、実行速度は遅い
select c.first_name
from customer c
where c.first_name LIKE '%D'
and c.first_name not in(
select a.first_name
from actor a
where a.first_name LIKE '%D');

select c.first_name
from customer c
where c.first_name like '%D' and not exists(
select a.first_name
from actor a
where a.first_name LIKE '%D' and a.first_name = c.first_name);

create table string_tbl
(char_fld CHAR(30),
vchar_fld VARCHAR(30),
text_fld TEXT
);

select @@session.sql_mode;

select char(97);
select ascii('a');

select concat('I',' am');

select length(first_name) from actor;

select position('J' in first_name) from actor;
select locate('A',first_name,2) from actor;
select strcmp('abc','xyz') cmp;
select @@global.time_zone,@@session.time_zone;

select str_to_date('September 17,2019','%M %d, %Y');

select current_date(),current_time(),current_timestamp();

#p142 intervalによる時間操作
select date_add(current_date(),interval 5 day);
select date_add(current_date(),interval '3:27:11' hour_second);
select date_add(current_date(),interval '9-11' year_month);

#文字列から特定の文字数を切り出す関数substr
select substring('Please find the substring in this string',17,9);

select abs(-25.768),sign(-25.768),round(-25.768,2);
#今年月日から月のみ抽出
select extract(month from current_date());

select customer_id,count(*)
from rental
group by customer_id;

select customer_id,count(*)
from rental
group by customer_id
order by 2 desc;

select customer_id,count(*)
from rental
group by customer_id
having count(*)>40
order by 2 desc;

select customer_id,max(amount),min(amount),avg(amount),sum(amount),count(*)
from payment
group by customer_id;

select count(customer_id),count(distinct customer_id)
from payment;

select customer_id,count(*) from payment
group by customer_id;

#日付の差分を求める組込み関数datediff P155
#current_dateを加減算せず、こちらを使用すべき https://qiita.com/mtanabe/items/349437e4c9113e5b2e93

select max(datediff(return_date,rental_date))
from rental;

select customer_id,rental_id,datediff(return_date,rental_date)
from rental
order by customer_id;

select count(val)
from rental;

select fa.actor_id,f.rating,count(*)
from film_actor fa
inner join film f
on fa.film_id = f.film_id
group by fa.actor_id,f.rating
order by 1,2;

select extract(year from rental_date) year,count(*) how_many
from rental
group by extract(year from rental_date);

select fa.actor_id,f.rating,count(*)
from film_actor fa
inner join film f
on fa.film_id = f.film_id
group by fa.actor_id,f.rating with rollup
order by 1,2;

#not inは<> allに書き換えられる
select first_name,last_name
from customer
where customer_id <> all
(select customer_id
from payment
where amount = 0);

#in は anyのエイリアス
select c.first_name
from customer c
where c.first_name LIKE '%D'
and c.first_name = any(
select a.first_name
from actor a
where a.first_name LIKE '%D');

#cross joinによる書き換え
select fa.actor_id,fa.film_id
from film_actor fa
where fa.actor_id in(
select actor_id from actor where last_name = 'MONROE')
and fa.film_id in
(select film_id from film where rating = 'PG');

select actor_id,film_id
from film_actor
where (actor_id,film_id) in
(select a.actor_id,f.film_id 
from actor as a
cross join film as f
where a.last_name = 'MONROE' 
and f.rating = 'PG');

#select 1というのはtrueであるという意味
select c.first_name,c.last_name
from customer c
where exists
(select 1 from rental r
where r.customer_id = c.customer_id
and date(r.rental_date) < '2005-05-25');

select rental_id,rental_date 
from rental
where exists 
(select 1 from rental
where date(rental_date) > '2005-05-25');

select first_name,last_name,
case when active = 1 
then 'ACTIVE'
else 'INACTIVE'
end activity_type
from customer;

select c.first_name,c.last_name,
case
when active = 0 then 0
else
(select count(*) from rental r where r.customer_id = c.customer_id)
end num_rental
from customer c
order by num_rental;

#月ごとの集計 P207
select monthname(rental_date) rental_month,count(*) num_rentals
from rental
where rental_date between '2005-05-01' and '2005-08-01'
group by monthname(rental_date); 

#月ごとの集計 P207
select
sum(case when monthname(rental_date) = 'May' then 1 else 0 end) May_rentals,
sum(case when monthname(rental_date) = 'June' then 1 else 0 end) June_rentals,
sum(case when monthname(rental_date) = 'July' then 1 else 0 end) July_rentals
from rental
where rental_date between '2005-05-01' and '2005-08-01';

#サブクエリをcaseで使用する P209
SELECT f.title,
case(select count(*) from inventory i where i.film_id = f.film_id)
when 0 then 'out of stock'
when 1 then 'scarcs'
when 2 then 'scarcs'
when 3 then 'available'
when 4 then 'available'
else 'common'
end film_available
from film f;

#ゼロ除算を防ぐ P210
select c.first_name,c.last_name,
sum(p.amount) tot_payment_amt,
count(p.amount) num_payments,
sum(p.amount) / 
case when count(p.amount) = 0 then 1 else count(p.amount)
end avg_payment
from customer c
left outer join payment p
on c.customer_id = p.customer_id
group by c.first_name,c.last_name
order by avg_payment;

select name,
case name
when name in ('English','Italian','French','German') then 'latin1'
when name in ('Japanese','Mandarin') then 'utf8'
else 'Unknown'
end chara_set
from language;

select
sum(case when rating = 'PG' then 1 else 0 end) PG
from film;

alter table customer
add index idx_email (email);

show index from customer;

show index from actor;

select last_name from actor;

#viewの作り方P244
create view customer_vw
(customer_id,
first_name,
last_name,
email)
as select
customer_id,
first_name,
last_name,
concat(substr(email,1,2),'*****',substr(email,-4)) email
from customer;

select * from customer_vw;

#viewの結合 P245
select cv.first_name,cv.last_name,p.amount
from customer_vw cv 
inner join payment p
on cv.customer_id = p.customer_id
where p.amount >= 11;

update customer_vw
set last_name = 'SMITH-ALLEN'
where customer_id = 1;

#単純なviewなら更新できる
select first_name,last_name,email
from customer
where customer_id = 1;

#tableタイプを調べる P257
select table_name,table_type
from information_schema.tables
where table_schema = 'sakila'
order by 1;

#四半期ごとにまとめる関数quarter
select quarter(payment_date) quater,monthname(payment_date) month_nm,
sum(amount) monthly_sales
from payment
where year(payment_date) = 2005
group by quarter(payment_date),monthname(payment_date);

#局所的な並べ替えP273
select quarter(payment_date) quater,monthname(payment_date) month_nm,
  sum(amount) monthly_sales,
  rank() over (order by sum(amount) desc) sales_rank
from payment
where year(payment_date) = 2005
group by quarter(payment_date), monthname(payment_date)
order by 1,month_nm;

#自動的に順位つけする関数rank()
select *,
rank() over (order by amount desc) as amount_rank
from payment
order by amount_rank;

select customer_id,count(*) num_rentals,
  row_number() over (order by count(*) desc) row_number_rnk,
  dense_rank() over 


