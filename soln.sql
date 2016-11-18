--Q1  List all the company names (and countries) that are incorporated outside Australia
create or replace view Q1(Name,Country) as
select name , country
from company
where country != 'Australia'
;


--Q2  List all the company codes that have more than five executive members on record (i.e., at least six).
create or replace view preQ2(code,number) as --code:count(person)
select code, count(person)
from executive
group by code
;

create or replace view Q2(code) as
select c.code
from company c , preQ2 p2
where c.code = p2.code and
      p2.number >= 6
;

--Q3  List all the company names that are in the sector of "Technology"
create or replace view Q3(Name) as
select name
from company c , category ct 
where c.code = ct.code and
      ct.sector = 'Technology'
;

--Q4  Find the number of Industries in each Sector
create or replace view Q4(sector, number)as
select sector, count(industry)
from category
group by sector
;

--Q5 Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".
create or replace view preQ5 as
select code,sector
from category
where sector = 'Technology'
;

create or replace view Q5(Name) as
select distinct person 
from executive e,preQ5 p5
where e.code = p5.code
;

--Q6  List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2
create or replace view Q6(Name) as
select name
from company c, category ca
where c.code = ca.code and
      ca.sector = 'Services' and
      c.country = 'Australia' and
      c.zip like '2%'
;
    
--Q7 Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).
create or replace view pre1Q7 as --preprice
select *,row_number() over(order by code,"Date") as index1 
from asx
;

create or replace view pre2Q7 as --currentprice
select *,row_number() over(order by code,"Date") as index2
from asx 
;

create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as
select p2Q7."Date",p2Q7.Code,p2Q7.volume,p1Q7.price,p2Q7.price,p2Q7.price-p1Q7.price,(p2Q7.price-p1Q7.price)/p1Q7.price * 100
from pre1Q7 p1Q7,pre2Q7 p2Q7
where p1Q7.index1 + 1 = p2Q7.index2 and
      p1Q7.code = p2Q7.code
order by p2Q7."Date",p2Q7.Code
;
    
--Q8  Find the most active trading stock (the one with the maximum trading volume; if more than one, output all of them) on every trading day. Order your output by "Date" and then by Code
create or replace view preQ8("Date", volume) as  --date:max(volume)
select "Date",max(volume)
from asx
group by "Date"
;

create or replace view Q8("Date",Code, Volume)as
select a."Date",a.code,a.volume
from asx a,preQ8 p8
where a."Date" = p8."Date" and
      a.volume = p8.volume
order by a."Date",code
;



--Q9  Find the number of companies per Industry. Order your result by Sector and then by Industry.
create or replace view Q9(Sector,Industry, Number)as
select sector,industry,count(code)
from category 
group by sector,industry
order by sector, industry
;

--Q10  List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).
create or replace view preQ10 (industry,number) as  --industry:count
select industry,count(code)
from category
group by industry
;

create or replace view Q10(Code, Industry) as
select c.code,c.industry
from category c, preQ10 p
where c.industry = p.industry and
      p.number = 1
;
      
--Q11  List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company).
create or replace view pre1Q11(sector,sumstar)as   ---sector:sumstar
select ca.sector,sum(r.star)
from category ca,rating r
where ca.code = r.code
group by ca.sector
;

create or replace view pre2Q11(sector,company)as   ---sectro:count(company)
select sector,count(code)
from category
group by sector
;

create or replace view Q11(Sector, AvgRating) as   --sector:sum/count
select p1.sector,p1.sumstar/p2.company
from pre1Q11 p1,pre2Q11 p2
where p1.sector = p2.sector
order by p1.sumstar/p2.company desc
;

--Q12 Output the person names of the executives that are affiliated with more than one company.
create or replace view preQ12(name,number)as   --person:count(company)
select person,count(code)
from executive
group by person
;

create or replace view Q12(Name) as
select p12.name
from preQ12 p12
where p12.number >= 2
;


--Q13  Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector. i.e., they are in a Sector that all companies there have local Australia address.
create or replace view pre1Q13(code, name, address, zip) as 
select code, name, address, zip 
from company where country <> 'Australia'
;


create or replace view pre2Q13(code, name, address, zip, sector) as 
select p1q13.code, p1q13.name, p1q13.address, p1q13.zip, ca.sector
from pre1Q13 p1q13, category ca 
where p1q13.code = ca.code
;


create or replace view Q13(code, name, address, zip, sector) as
select c.code, c.name, c.address, c.zip, ca.sector  
from company c, category ca 
where country = 'Australia' and 
      c.code = ca.code 
except(select c.code, c.name, c.address, c.zip, ca.sector from company c, category ca,pre2Q13 p2Q13 where ca.sector = p2Q13.sector) 
order by code
;

---------------Q14  Calculate stock gains based on their prices of the first trading day and last trading day (i.e., the oldest "Date" and the most recent "Date" of the records stored in the ASX table). Order your result by Gain in descending order and then by Code in ascending order.
create or replace view pre1Q14(code,date1,date2)as --begindate,enddate
select code ,max("Date"),min("Date")
from asx
group by code
;

create or replace view pre2Q14(code,price1)as --beginprice
select a.code,a.price
from asx a, pre1Q14 p1Q14
where a.code = p1Q14.code and
      a."Date" = p1Q14.date1
;
      

create or replace view pre3Q14(code,price2)as ---endprice
select a.code,a.price
from asx a, pre1Q14 p1Q14
where a.code = p1Q14.code and
      a."Date" = p1Q14.date2
;

create or replace view q14(code, beginprice, endprice, change, gain) as 
select p2Q14.code, p2Q14.price1, p3Q14.price2, p3Q14.price2 - p2Q14.price1, (p3Q14.price2 - p2Q14.price1)/p2Q14.price1*100 as gain 
from pre2Q14 p2Q14, pre3Q14 p3Q14 
where p2Q14.code = p3Q14.code 
order by gain DESC, p2Q14.code
;

---------------Q15  For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days (as noted above, the total number of days here should exclude the first trading day).
create or replace view pre1Q15(code,minp,avgp,maxp) as --price
select code,min(price),sum(price)/count(price),max(price)
from asx
group by code
;

create or replace view pre2Q15(code,ming,avgg,maxg) as --gain
select code,min(gain),sum(gain)/count(gain),max(gain)
from Q7
group by code
;

create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as 
select p1Q15.code,p1Q15.minp,p1Q15.avgp,p1Q15.maxp,p2Q15.ming,p2q15.avgg,p2Q15.maxg
from pre1Q15 p1Q15,pre2Q15 p2Q15
where p1Q15.code = p2Q15.code
order by p1Q15.code
;

---------------Q16  Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company.
create or replace function executive_check() returns trigger
as $$ declare NumofCompany int;
begin
   NumofCompany := (select count(code) from executive where person = new.person);
   if NumofCompany >= 1 then
   raise expection '% is an executive of more than one company.',new.person;
   end if;
   retrun new;
end;
$$ language plpgsql;

create trigger ExecutiveCheck
before insert or update  on executive
for each row execute procedure executive_check()
;
    

---------------Q17   Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as Star's) to 5 when the stock has made a maximum daily price gain (when compared with the price on the previous trading day) in percentage within its sector. For example, for a given day and a given sector, if Stock A has the maximum price gain in the sector, its rating should then be updated to 5. If it happens to have more than one stock with the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. If there are more than one record of rating for a given stock that need to be updated, update (not insert) all these records. 


----------------Q18   Stock price and trading volume data are usually incoming data and seldom involve updating existing data. However, updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in the ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) into the ASXLog table. Here we assume that Date and Code cannot be corrected and will be the same as their original, old values. Timestamp is the date and time that the correction takes place. Note that it is also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp.

