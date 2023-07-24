CREATE table activity
(
user_id varchar(20),
event_name varchar(20),
event_date date,
country varchar(20)
);

insert into activity values (1,'app-installed','2022-01-01','India')
,(1,'app-purchase','2022-01-02','India')
,(2,'app-installed','2022-01-01','USA')
,(3,'app-installed','2022-01-01','USA')
,(3,'app-purchase','2022-01-03','USA')
,(4,'app-installed','2022-01-03','India')
,(4,'app-purchase','2022-01-03','India')
,(5,'app-installed','2022-01-03','SL')
,(5,'app-purchase','2022-01-03','SL')
,(6,'app-installed','2022-01-04','Pakistan')
,(6,'app-purchase','2022-01-04','Pakistan');


-- Table content
select * from activity;

-- Daily active users
select event_date, count(distinct user_id) from activity
group by event_date;

-- Weekly active users
select DATEPART(week, event_date) week_number, count(distinct user_id) no_of_users from activity
group by DATEPART(week, event_date);

-- users(user_id) who did install and purchase on same day
select user_id, event_date from activity
group by user_id, event_date
having count(distinct event_name)=2;

-- Number of users in a specific day who installed and purchased
select event_date, count(distinct new_user_id) no_of_users from
(
select event_date, user_id, case when count(distinct event_name)=2 then user_id else null end as new_user_id from activity
group by event_date, user_id
) temp
group by event_date;

-- percentage of paid users in India, USA and any other country should be tagged as others
with cte as 
(
select case when country in ('USA','India') then country else 'others' end as new_country, count(*) new_count from activity
where event_name = 'app-purchase'
group by case when country in ('USA','India') then country else 'others' end
)
, cte2 as (select sum(new_count) as count1 from cte)

select new_country, 100.0*new_count/count1 percentage from cte, cte2;

-- Among all the users who installed the app on a given day, how many did in app 
-- purchased on the very next day
 with prev_date as (
 select *, 
 lag(event_date,1) over(partition by user_id order by event_date) as prev_event_date,
 lag(event_name,1) over(partition by user_id order by event_date) as prev_event_name 
 from activity
 )
 select event_date, 
 count(case when event_name = 'app-purchase' and prev_event_name='app-installed' and
 DATEDIFF(day, prev_event_date, event_date) = 1 then event_date else null end) new_dates 
 from prev_date
 group by event_date;










