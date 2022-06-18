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
