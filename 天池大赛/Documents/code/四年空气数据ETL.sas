libname tt "E:\¹¤×÷\05ÎÞÎýViya\sasdata";

data air;
set air_2014-air_2018;
if find(type,'_')>0 then type=scan(type,1,'_');
run;

proc freq data=air;
tables type;
run;

data tt._03_realtime_air_initial;
set air;
run;

proc transpose data=air out=tt._03_realtime_air_trans;
by date;
id type;
var '1188a'n '1189a'n '1190a'n '1191a'n '1192a'n '1193a'n '1194a'n '1195a'n;
run;

proc contents data=tt._03_realtime_air_trans out=tmp noprint; 
run;

proc sql noprint;
select cat("min('",strip(name),"'n) as '",strip(name),"_min'n, ",
			"mean('",strip(name),"'n) as '",strip(name),"_mean'n, ",
			"max('",strip(name),"'n) as '",strip(name),"_max'n, ",
			"sum('",strip(name),"'n) as '",strip(name),"_sum'n") into:vars
	separated by ","
from tmp
where upcase(strip(name)) not in("_NAME_","DATE")
order by varnum
;quit;
%put vars=&vars.;

proc sql noprint;
create table tt._03_realtime_air_summary as
select date,&vars.
from tt._03_realtime_air_trans
group by date
;quit;

data a;
set tt._03_realtime_air_summary;
week=year(date)*100+week(date);
month=year(date)*100+month(date);
run;

proc sql;
create table tt._03_realtime_air_week as
select week, min(date) as date format=yymmddn8.,
	mean(aqi_mean) as AQI,
	mean('PM2.5_min'n) as 'PM2.5'n,
	mean('PM10_min'n) as 'PM10'n,
	mean(so2_mean) as SO2,
	mean(NO2_mean) as NO2,
	mean(O3_mean) as O3,
	mean(CO_mean) as CO
from a
group by week
;quit;

proc sql;
create table tt._03_realtime_air_month as
select month, min(date) as date format=yymms7.,
	mean(aqi_mean) as AQI,
	mean('PM2.5_min'n) as 'PM2.5'n,
	mean('PM10_min'n) as 'PM10'n,
	mean(so2_mean) as SO2,
	mean(NO2_mean) as NO2,
	mean(O3_mean) as O3,
	mean(CO_mean) as CO
from a
group by month
;quit;
