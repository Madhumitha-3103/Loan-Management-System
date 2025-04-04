create database project;
use project;
-- sheet 1
select * from customer_income;
alter table customer_income add primary key(loan_id(10));
create table applicant_income_grades as select *, 
case
when applicantincome>15000 then 'Grade A'
when applicantincome>9000 then 'grade B'
when applicantincome>5000 then 'middle class customer'
else 'low class'
end as grade,
case
when applicantincome<5000 and property_area='rural' then '3'
when applicantincome<5000 and property_area='semi_rural' then '3.5'
when applicantincome<5000 and property_area='urban' then '5'
when applicantincome<5000 and property_area='semi_urban' then '2.5'
else '7'
end as monthly_intrest_percentage
from customer_income;
select * from applicant_income_grades;
alter table applicant_income_grades  modify monthly_intrest_percentage decimal(5,2);

-- loan table(trigger functions)
-- dummy table
create table dummy(loan_id text(10), customer_id text,loanamount text, loan_amount_term int,cibilscore int,primary key(loan_id(10)));
select * from dummy;
-- primary table
create table loan_status(loan_id text(10), customer_id text,loanamount text, loan_amount_term int,cibilscore int,primary key(loan_id(10)));
select * from Loan_status;
-- secondary table
create table loan_cibilscore_status_details(loan_id text,loanamount text,cibilscore int,cibilscore_status text, primary key(loan_id(10)));
select * from loan_cibilscore_status_details;
drop table loan_status;
drop table loan_cibilscore_status_details;
-- before insert trigger query
delimiter //
create trigger loan_check before insert on loan_status for each row
begin
 if new.loanamount is null then set new.loanamount='loan still processing';

end if;
end //
delimiter ;
drop trigger loan_check;

-- after insert trigger
delimiter //
create trigger cibilscore after insert on loan_Status for each row
begin 
if new.cibilscore>900 then insert into loan_cibilscore_status_details(loan_id,loanamount,cibilscore,cibilscore_status)values 
(new.loan_id ,new.loanamount,new.cibilscore,'high  cibil score');
elseif new.cibilscore>750 then insert into loan_cibilscore_status_details(loan_id,loanamount,cibilscore,cibilscore_status)
values(new.loan_id ,new.loanamount,new.cibilscore,'no penalty');
elseif new.cibilscore>0 then insert into loan_cibilscore_status_details(loan_id,loanamount,cibilscore,cibilscore_status)
values(new.loan_id ,new.loanamount,new.cibilscore,'penalty customers');
else  insert into loan_cibilscore_status_details(loan_id,loanamount,cibilscore,cibilscore_status)
values(new.loan_id ,new.loanamount,new.cibilscore,'reject customer');
end if;
end //
delimiter ;
select count(*) from loan_cibilscore_status_details where cibilscore_status='penalty customers';
-- inserting values from dummy
insert into loan_status (loan_id, customer_id, loanamount, loan_amount_term, cibilscore)
select loan_id, customer_id, loanamount, loan_amount_term, cibilscore
from dummy;

-- deleting values
delete from loan_cibilscore_status_details where  loanamount='loan still processing';
delete from loan_cibilscore_status_details where cibilscore_status='reject customer';
select count(*) from loan_cibilscore_status_details;

-- alter table
alter table loan_cibilscore_status_details modify loanamount int;
describe loan_cibilscore_status_details;

-- calculating monthly and annual intrest
describe applicant_income_grades;
drop table customer_intrest_analysis;
 create table customer_intrest_analysis as select A.*,l.loanamount,l.cibilscore,l.cibilscore_status,
 case
 when applicantincome<5000 and property_area ='rural' then (loanamount*(3/100))
 when applicantincome<5000 and property_area='semi rural' then (loanamount*(3.5/100))
 when applicantincome<5000 and property_area='urban' then (loanamount*(5/100))
  when applicantincome<5000 and property_area='semi urban' then (loanamount*(2.5/100))
  else  (loanamount*(7/100))
  end as monthly_intrest,
  case
   when applicantincome<5000 and property_area ='rural' then (loanamount*(3/100)*12)
 when applicantincome<5000 and property_area='semi rural' then (loanamount*(3.5/100)*12)
 when applicantincome<5000 and property_area='urban' then (loanamount*(5/100)*12)
  when applicantincome<5000 and property_area='semi urban' then (loanamount*(2.5/100)*12)
  else  (loanamount*(7/100)*12)
  end as annual_intrest
from applicant_income_grades a
 inner join loan_cibilscore_status_details l on a.loan_id=l.loan_id;
drop table customer_intrest_analysis;
 select * from customer_intrest_analysis;
 select count(*) from customer_intrest_analysis;
 alter table customer_intrest_analysis add  primary key(loan_id(10));
 describe customer_intrest_analysis;
 
 -- sheet 3
 select * from customer_det;
 drop table customer_det;
 select count(*) from customer_det;
update customer_det
set gender = 
case
when customer_id in ('IP43006','IP43016','IP43508','IP43577','IP43589','IP43593') then'female'
when customer_id in ('IP43018','IP43038') then 'male'
else 'gender'
end;

 
update customer_det
set age=
case
when customer_id='IP43007' then 45
when customer_id='IP43009' then 32
else age 
end;

select * from customer_det where customer_id='IP43018';
alter table customer_det add primary key(customer_id(10));
describe customer_det;
 
-- sheet 4 and 5
select * from country_state;
select count(*) from country_state;
select * from region_info;
create table  country_region  as select c.*,r.Region from country_state c right join region_info r on c.region_id=r.region_id;
select * from country_region;
alter table country_region add primary key (customer_id(10));
describe country_region;
drop table country_region;


-- foreign key
describe customer_income;
alter table customer_income modify loan_id varchar(10);
alter table customer_income modify customer_id varchar(10);
select * from customer_income;
alter table customer_intrest_analysis modify loan_id varchar(10); 
alter table loan_status modify loan_id varchar(10);
alter table customer_income add constraint loan_key foreign key(loan_id) references loan_status(loan_id);
alter table customer_income drop primary key;
describe loan_status;
alter table customer_income add constraint income_key foreign key(loan_id) references applicant_income_grades(loan_id);
describe applicant_income_grades;

describe loan_cibilscore_status_details;
alter table customer_income drop  foreign key loan_key;
alter table loan_status  drop primary key;
alter table loan_cibilscore_status_details modify loan_id varchar(10);
alter table loan_cibilscore_status_details add constraint cibil_key foreign key(loan_id) references loan_status(loan_id); 
drop table country_state;
drop table region_info;     

alter table customer_intrest_analysis modify loan_id varchar(10);
alter table customer_intrest_analysis add primary key(loan_id);
alter table customer_intrest_analysis add constraint intrest_key foreign key(loan_id) references loan_cibilscore_status_details(loan_id);


alter table customer_det modify customer_id varchar(10);
alter table customer_intrest_analysis modify customer_id varchar(10);
alter table customer_intrest_analysis add primary key(customer_id);
alter table customer_intrest_analysis add constraint details_key foreign key (customer_id) references customer_det(customer_id);


alter table country_state modify customer_id varchar(10);
alter table customer_det add primary key(customer_id);
alter table customer_det add constraint state_key foreign key(customer_id) references country_state(customer_id);

alter table country_state add constraint region_key foreign key(region_id) references region_info(region_id);

alter table customer_income add constraint customer_key foreign key (customer_id) references applicant_income_grades(customer_id);
describe applicant_income_grades;
alter table applicant_income_grades modify customer_id varchar(10);
alter table applicant_income_grades add primary key (customer_id );
alter table customer_income modify customer_id varchar(10);

-- output 1
 create table output_1 as select A.*,l.loanamount,l.cibilscore,l.cibilscore_status,c.monthly_intrest,c.annual_intrest,
d.customer_name,d.gender,d.age,d.married,d.education,d.self_employed,d.region_id,r.postal_code,r.segment,r.state,r.region from applicant_income_grades a
inner join loan_cibilscore_status_details l on a.loan_id=l.loan_id
inner join customer_intrest_analysis c on l.loan_id=c.loan_id
inner join customer_det d on c.loan_id=d.loan_id
inner join country_region r on d.customer_id=r.customer_id;
select * from output_1;
select count(*) from output_1;
drop table output_1;

-- output 2
create table output_2 as 
select C.*,r.Postal_code,r.segment,r.state,r.region from customer_det C  
right join country_region r  on c.customer_id= r.customer_id
where c.customer_id is null and r.segment is null;
select * from output_2;

drop table output_2;


-- filter using inner join
-- output 3
 create table output_3 as  select A.*,l.loanamount,l.cibilscore,l.cibilscore_status,c.monthly_intrest,c.annual_intrest,
d.customer_name,d.gender,d.age,d.married,d.education,d.self_employed,d.region_id,r.postal_code,r.segment,r.state,r.region from applicant_income_grades a
inner join loan_cibilscore_status_details l on a.loan_id=l.loan_id
inner join customer_intrest_analysis c on l.loan_id=c.loan_id
inner join customer_det d on c.loan_id=d.loan_id
inner join country_region r on d.customer_id=r.customer_id
where l.cibilscore_status='high  cibil score';
select * from output_3;
select count(*) from output_3; 

-- output 4
create table output_4 as select A.*,l.loanamount,l.cibilscore,l.cibilscore_status,c.monthly_intrest,c.annual_intrest,
d.customer_name,d.gender,d.age,d.married,d.education,d.self_employed,d.region_id,r.postal_code,r.segment,r.state,r.region from applicant_income_grades a
inner join loan_cibilscore_status_details l on a.loan_id=l.loan_id
inner join customer_intrest_analysis c on l.loan_id=c.loan_id
inner join customer_det d on c.loan_id=d.loan_id
inner join country_region r on d.customer_id=r.customer_id where segment in ('home office','corporate');

select * from output_4;

select count(*) from output_4;

-- storing in procedure
drop procedure project_output;
delimiter //
create procedure project_output()
begin
select * from output_1;
select * from output_2;
 select * from  output_3;
select * from output_4;

end //
delimiter ;

call project_output();
