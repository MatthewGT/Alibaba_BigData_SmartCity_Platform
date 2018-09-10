libname tt "E:\����\05����Viya\sasdata";
data wushui;
	set wushui1806 wushui1805 wushui1804 wushui1803 wushui1802;
/*	length num1 8.;*/
	retain str1-str3 num1;

	if '��ˮ��������'n ne '' then
		do;
			str1='������'n;
			str2='��ˮ��������'n;
			str3='����ˮ��'n;
			num1='�������'n;
		end;

	if 'ִ�б�׼����'n ne '' and  '��ˮ��������'n eq '' then
		do;
			'������'n=str1;
			'��ˮ��������'n=str2;
			'����ˮ��'n=str3;
			'�������'n=num1;
		end;

	drop str1-str3 num1;
run;

data tt._13_WUSHUI_initial;
set wushui;
run;

data wushui_1;
set wushui;
if '������'n ne '' and '��ˮ��������'n ne '';
keep '������'n '��ˮ��������'n '����ˮ��'n '�������'n 'ִ�б�׼����'n 
	'ִ�б�׼��������'n '����մ�����'n '��������'n  '��������'n;
run;

data a1;
set wushui;
num1=input(compress(compress('����Ũ��'n,"<"),">"),8.);
num2=input(compress(compress('����Ũ��'n,"<"),">"),8.);
num3=max(input(scan('��׼��ֵ'n,1,'-'),8.),input(scan('��׼��ֵ'n,2,'-'),8.));
retain str1 str2;
if '��ˮ��������'n ne "" then do;
	str1='��ˮ��������'n;
	str2='ִ�б�׼����'n;
end;
keep '��ˮ��������'n 'ִ�б�׼����'n  '�����Ŀ'n '����Ũ��'n
	'����Ũ��'n '��׼��ֵ'n num: str:;
run;

proc sort data=a1; by str1 str2 '�����Ŀ'n descending  num2 descending num1; run;
data a2;
set a1(rename=('�����Ŀ'n=Monitor_pjt_nm));
by str1 str2 Monitor_pjt_nm descending num2 descending num1;
if first.Monitor_pjt_nm;
run;
/*����Ũ��*/
proc transpose data=a2 out=trans1(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var num1;
run;
/*����Ũ��*/
proc transpose data=a2 out=trans2(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var num2;
run;
/*��׼��ֵ*/
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
on a.'��ˮ��������'n=b.str1 and a.'ִ�б�׼����'n=b.str2
left join trans2 c 
on a.'��ˮ��������'n=c.str1 and a.'ִ�б�׼����'n=c.str2
left join trans3 d 
on a.'��ˮ��������'n=d.str1 and a.'ִ�б�׼����'n=d.str2
;
quit;

proc sort data=tt._13_wushui; by '�������'n '������'n '��ˮ��������'n; run;