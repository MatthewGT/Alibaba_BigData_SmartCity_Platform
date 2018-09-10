libname tt "E:\����\05����Viya\sasdata";
data feiqi;
	set feiqi1806 feiqi1805 feiqi1804 feiqi1803;
	retain str1-str5 num1 num2;

	if '��ҵ����'n ne '' then
		do;
			str1='������'n;
			str2='��ҵ����'n;
			str3='��ҵ����'n;
			str4='ִ�б�׼����'n;
			str5='ִ�б�׼��������'n;
			num1='�������'n;
			num2='��������'n;
		end;

	if '��������'n ne '' and  '��ҵ����'n eq '' then
		do;
			'������'n=str1;
			'��ҵ����'n=str2;
			'��ҵ����'n=str3;
			'ִ�б�׼����'n=str4;
			'ִ�б�׼��������'n=str5;
			'�������'n=num1;
			'��������'n=num2;
		end;

	drop str1-str5 num1-num2;
run;

data tt._11_FEIQI_initial;
set feiqi;
run;

data feiqi_1;
set feiqi;
if '������'n ne '' and '��ҵ����'n ne '';
keep '������'n '��ҵ����'n '��ҵ����'n  '��������'n 'ִ�б�׼����'n 
	'ִ�б�׼��������'n '�������'n '��������'n  '����'n '�����¶�'n
	'������()'n;
run;

data a1;
set feiqi;
var1=input(compress(compress('ʵ��Ũ��'n,"<"),">"),8.);
var2=input(compress(compress('����Ũ��'n,"<"),">"),8.);
retain str1 str2;
if '��ҵ����'n ne "" then do;
	str1='��ҵ����'n;
	str2='��������'n;
end;
keep '��ҵ����'n '��������'n '�����Ŀ����'n 'ʵ��Ũ��'n '����Ũ��'n '��׼��ֵ'n var1 var2 str1 str2;
run;

proc sort data=a1; by str1 str2 '�����Ŀ����'n descending var2; run;
data a2;
set a1(rename=('�����Ŀ����'n=Monitor_pjt_nm));
by str1 str2 Monitor_pjt_nm descending var2;
if first.Monitor_pjt_nm;
run;
/*ʵ��ֵ*/
proc transpose data=a2 out=trans1(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var var1;
run;
/*����ֵ*/
proc transpose data=a2 out=trans2(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var var2;
run;
/*��׼����*/
proc transpose data=a2 out=trans3(drop=_name_);
by str1 str2;
id Monitor_pjt_nm;
var '��׼��ֵ'n;
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
on a.'��ҵ����'n=b.str1 and a.'��������'n=b.str2
left join trans2 c 
on a.'��ҵ����'n=c.str1 and a.'��������'n=c.str2
left join trans3 d 
on a.'��ҵ����'n=d.str1 and a.'��������'n=d.str2;
quit;

proc sort data=tt._11_FEIQI; by '�������'n '������'n '��ҵ����'n;
run;