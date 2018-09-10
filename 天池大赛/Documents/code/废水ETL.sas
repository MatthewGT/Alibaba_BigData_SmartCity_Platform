libname tt "E:\����\05����Viya\sasdata";
data feishui;
	set feishui1806 feishui1805 feishui1803 feishui1802;
	retain str1-str4 num1;

	if '��ҵ����'n ne '' then
		do;
			str1='������'n;
			str2='��ҵ����'n;
			str3='��ҵ����'n;
			str4='����ˮ��'n;
			num1='�������'n;
		end;

	if '��������'n ne '' and  '��ҵ����'n eq '' then
		do;
			'������'n=str1;
			'��ҵ����'n=str2;
			'��ҵ����'n=str3;
			'����ˮ��'n=str4;
			'�������'n=num1;
		end;

	drop str1-str4 num1;
run;
data tt._12_FEISHUI_initial;
set feishui;
run;

data feishui_1;
set feishui;
if '������'n ne '' and '��ҵ����'n ne '';
keep '������'n '��ҵ����'n '��ҵ����'n '����ˮ��'n '��������'n 'ִ�б�׼����'n 
	'ִ�б�׼��������'n '�������'n '��������'n  '��������'n;
run;

data a1;
set feishui;
var1=input(compress(compress('��Ⱦ��Ũ��'n,"<"),">"),8.);
var2=max(input(scan('��׼��ֵ'n,1,'-'),8.),input(scan('��׼��ֵ'n,2,'-'),8.));
retain str1 str2;
if '��ҵ����'n ne "" then do;
	str1='��ҵ����'n;
	str2='��������'n;
end;
keep '��ҵ����'n '��������'n '�����Ŀ����'n '��Ⱦ��Ũ��'n '��׼��ֵ'n var1 var2 str1 str2;
run;

proc sort data=a1; by str1 str2 '�����Ŀ����'n descending var1; run;
data a2;
set a1(rename=('�����Ŀ����'n=Monitor_pjt_nm));
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
on a.'��ҵ����'n=b.str1 and a.'��������'n=b.str2
left join trans2 c 
on a.'��ҵ����'n=c.str1 and a.'��������'n=c.str2;
quit;

proc sort data=tt._12_FEISHUI;
by '�������'n '������'n '��ҵ����'n;
run;