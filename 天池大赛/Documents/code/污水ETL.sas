libname tt "E:\工作\05无锡Viya\sasdata";
data wushui;
	set wushui1806 wushui1805 wushui1804 wushui1803 wushui1802;
/*	length num1 8.;*/
	retain str1-str3 num1;

	if '污水处理厂名称'n ne '' then
		do;
			str1='行政区'n;
			str2='污水处理厂名称'n;
			str3='受纳水体'n;
			num1='监测日期'n;
		end;

	if '执行标准名称'n ne '' and  '污水处理厂名称'n eq '' then
		do;
			'行政区'n=str1;
			'污水处理厂名称'n=str2;
			'受纳水体'n=str3;
			'监测日期'n=num1;
		end;

	drop str1-str3 num1;
run;

data tt._13_WUSHUI_initial;
set wushui;
run;

data wushui_1;
set wushui;
if '行政区'n ne '' and '污水处理厂名称'n ne '';
keep '行政区'n '污水处理厂名称'n '受纳水体'n '监测日期'n '执行标准名称'n 
	'执行标准条件名称'n '设计日处理量'n '进口流量'n  '出口流量'n;
run;

data a1;
set wushui;
num1=input(compress(compress('进口浓度'n,"<"),">"),8.);
num2=input(compress(compress('出口浓度'n,"<"),">"),8.);
num3=max(input(scan('标准限值'n,1,'-'),8.),input(scan('标准限值'n,2,'-'),8.));
retain str1 str2;
if '污水处理厂名称'n ne "" then do;
	str1='污水处理厂名称'n;
	str2='执行标准名称'n;
end;
keep '污水处理厂名称'n '执行标准名称'n  '监测项目'n '进口浓度'n
	'出口浓度'n '标准限值'n num: str:;
run;

proc sort data=a1; by str1 str2 '监测项目'n descending  num2 descending num1; run;
data a2;
set a1(rename=('监测项目'n=Monitor_pjt_nm));
by str1 str2 Monitor_pjt_nm descending num2 descending num1;
if first.Monitor_pjt_nm;
run;
/*进口浓度*/
proc transpose data=a2 out=trans1(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var num1;
run;
/*出口浓度*/
proc transpose data=a2 out=trans2(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var num2;
run;
/*标准限值*/
proc transpose data=a2 out=trans3(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var num3;
run;

proc contents data=trans1 out=con1 noprint;
run;

proc sort data=con1; by varnum; run;

proc sql noprint;
select "b.'"|| strip(name)|| "'n as '"|| strip(name)||"_import'n,"||
			"c.'"|| strip(name)|| "'n as '"|| strip(name)||"_export'n,"||
			"d.'"|| strip(name)|| "'n as '"|| strip(name)||"_limit'n"
into: names1 separated by ", "
from con1 
where upcase(name) not in("STR1","STR2")
	and varnum<=15;

select "b.'"|| strip(name)|| "'n as '"|| strip(name)||"_import'n,"||
			"c.'"|| strip(name)|| "'n as '"|| strip(name)||"_export'n,"||
			"d.'"|| strip(name)|| "'n as '"|| strip(name)||"_limit'n"
into: names2 separated by ", "
from con1 
where upcase(name) not in("STR1","STR2")
	and varnum>15;
;quit;
%put names1=&names1.;
%put names2=&names2.;


proc sql noprint;
create table tt._13_wushui as
select a.*, &names1., &names2.
from wushui_1 a left join trans1 b 
on a.'污水处理厂名称'n=b.str1 and a.'执行标准名称'n=b.str2
left join trans2 c 
on a.'污水处理厂名称'n=c.str1 and a.'执行标准名称'n=c.str2
left join trans3 d 
on a.'污水处理厂名称'n=d.str1 and a.'执行标准名称'n=d.str2
;
quit;

proc sort data=tt._13_wushui; by '监测日期'n '行政区'n '污水处理厂名称'n; run;