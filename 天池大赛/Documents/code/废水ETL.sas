libname tt "E:\工作\05无锡Viya\sasdata";
data feishui;
	set feishui1806 feishui1805 feishui1803 feishui1802;
	retain str1-str4 num1;

	if '企业名称'n ne '' then
		do;
			str1='行政区'n;
			str2='企业名称'n;
			str3='行业名称'n;
			str4='受纳水体'n;
			num1='监测日期'n;
		end;

	if '监测点名称'n ne '' and  '企业名称'n eq '' then
		do;
			'行政区'n=str1;
			'企业名称'n=str2;
			'行业名称'n=str3;
			'受纳水体'n=str4;
			'监测日期'n=num1;
		end;

	drop str1-str4 num1;
run;
data tt._12_FEISHUI_initial;
set feishui;
run;

data feishui_1;
set feishui;
if '行政区'n ne '' and '企业名称'n ne '';
keep '行政区'n '企业名称'n '行业名称'n '受纳水体'n '监测点名称'n '执行标准名称'n 
	'执行标准条件名称'n '监测日期'n '生产负荷'n  '监测点流量'n;
run;

data a1;
set feishui;
var1=input(compress(compress('污染物浓度'n,"<"),">"),8.);
var2=max(input(scan('标准限值'n,1,'-'),8.),input(scan('标准限值'n,2,'-'),8.));
retain str1 str2;
if '企业名称'n ne "" then do;
	str1='企业名称'n;
	str2='监测点名称'n;
end;
keep '企业名称'n '监测点名称'n '监测项目名称'n '污染物浓度'n '标准限值'n var1 var2 str1 str2;
run;

proc sort data=a1; by str1 str2 '监测项目名称'n descending var1; run;
data a2;
set a1(rename=('监测项目名称'n=Monitor_pjt_nm));
by str1 str2 Monitor_pjt_nm descending var1;
if first.Monitor_pjt_nm;
run;

proc transpose data=a2 out=trans1(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var var1;
run;
proc transpose data=a2 out=trans2(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var var2;
run;

proc contents data=trans1 out=con1 noprint;
run;

proc sort data=con1; by varnum; run;

proc sql noprint;
select cats("b.'", name, "'n, ","c.'", name, "'n as '", name,"_limit'n")
into: names1 separated by ", "
from con1 where upcase(name) not in("STR1","STR2")
;quit;
%put names1=&names1.;
/*%put names2=&names2.;*/


proc sql;
create table tt._12_feishui as
select a.*, &names1.
from feishui_1 a left join trans1 b 
on a.'企业名称'n=b.str1 and a.'监测点名称'n=b.str2
left join trans2 c 
on a.'企业名称'n=c.str1 and a.'监测点名称'n=c.str2;
quit;

proc sort data=tt._12_FEISHUI;
by '监测日期'n '行政区'n '企业名称'n;
run;