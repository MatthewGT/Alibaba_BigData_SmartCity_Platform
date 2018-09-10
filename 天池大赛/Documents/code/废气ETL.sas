libname tt "E:\工作\05无锡Viya\sasdata";
data feiqi;
	set feiqi1806 feiqi1805 feiqi1804 feiqi1803;
	retain str1-str5 num1 num2;

	if '企业名称'n ne '' then
		do;
			str1='行政区'n;
			str2='企业名称'n;
			str3='行业名称'n;
			str4='执行标准名称'n;
			str5='执行标准条件名称'n;
			num1='监测日期'n;
			num2='工况负荷'n;
		end;

	if '监测点名称'n ne '' and  '企业名称'n eq '' then
		do;
			'行政区'n=str1;
			'企业名称'n=str2;
			'行业名称'n=str3;
			'执行标准名称'n=str4;
			'执行标准条件名称'n=str5;
			'监测日期'n=num1;
			'工况负荷'n=num2;
		end;

	drop str1-str5 num1-num2;
run;

data tt._11_FEIQI_initial;
set feiqi;
run;

data feiqi_1;
set feiqi;
if '行政区'n ne '' and '企业名称'n ne '';
keep '行政区'n '企业名称'n '行业名称'n  '监测点名称'n '执行标准名称'n 
	'执行标准条件名称'n '监测日期'n '工况负荷'n  '流量'n '烟气温度'n
	'含氧量()'n;
run;

data a1;
set feiqi;
var1=input(compress(compress('实测浓度'n,"<"),">"),8.);
var2=input(compress(compress('折算浓度'n,"<"),">"),8.);
retain str1 str2;
if '企业名称'n ne "" then do;
	str1='企业名称'n;
	str2='监测点名称'n;
end;
keep '企业名称'n '监测点名称'n '监测项目名称'n '实测浓度'n '折算浓度'n '标准限值'n var1 var2 str1 str2;
run;

proc sort data=a1; by str1 str2 '监测项目名称'n descending var2; run;
data a2;
set a1(rename=('监测项目名称'n=Monitor_pjt_nm));
by str1 str2 Monitor_pjt_nm descending var2;
if first.Monitor_pjt_nm;
run;
/*实测值*/
proc transpose data=a2 out=trans1(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var var1;
run;
/*折算值*/
proc transpose data=a2 out=trans2(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var var2;
run;
/*标准上限*/
proc transpose data=a2 out=trans3(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var '标准限值'n;
run;

proc contents data=trans1 out=con1 noprint;
run;

proc sort data=con1; by varnum; run;

proc sql noprint;
select cats("b.'", name, "'n, ","c.'", name, "'n as '", name,"_convert'n,",
	"d.'", name, "'n as '", name,"_limit'n")
into: names1 separated by ", "
from con1 where upcase(name) not in("STR1","STR2")
;quit;
%put names1=&names1.;
/*%put names2=&names2.;*/


proc sql;
create table tt._11_feiqi as
select a.*, &names1.
from feiqi_1 a left join trans1 b 
on a.'企业名称'n=b.str1 and a.'监测点名称'n=b.str2
left join trans2 c 
on a.'企业名称'n=c.str1 and a.'监测点名称'n=c.str2
left join trans3 d 
on a.'企业名称'n=d.str1 and a.'监测点名称'n=d.str2;
quit;

proc sort data=tt._11_FEIQI; by '监测日期'n '行政区'n '企业名称'n;
run;