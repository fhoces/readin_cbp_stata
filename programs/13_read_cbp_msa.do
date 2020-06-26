/* $Id$ */
/* $URL$ */
/* read in CBP */
#delimit;
include "config.do";
set more 1;

capture program drop readin;
program define readin;
local year `1';
local yr=`year'-1900;
if ( `year' > 1999 ) {;
	local yr=`year'-2000;
	if ( `yr' < 10 ) { ;
		local yr 0`yr';
	};
};

/* di "Reading in CBP year=`year' = `yr'";*/
! unzip -LL -o -d $INPUTS $INPUTS/cbp`yr'msa.zip;
insheet using $INPUTS/cbp`yr'msa.txt;
! chmod u+rw $INPUTS/cbp`yr'msa.txt;
rm $INPUTS/cbp`yr'msa.txt;
gen int year=`year';
label var year "Year";
/* http://www.census.gov/econ/cbp/download/noise_layout/Metro_Area_Layout.txt */
/* force msa to be character */
ren msa stnum;
tostring stnum, gen(msa);
replace msa="0"+msa if stnum<10;
drop stnum;
label var msa "Metro or Micro Area Code      ";
label var empflag "Data Suppression Flag      ";
label var emp "Total Mid-March Employees with Noise    ";
label var qp1 "Total First Quarter Payroll ($1,000) with Noise  ";
label var ap "Total Annual Payroll ($1,000) with Noise   ";
capture ren totest est;
label var est "Total Number of Establishments     ";
label var n1_4 "Number of Establishments: 1-4 Employee Size Class  ";
label var n5_9 "Number of Establishments: 5-9 Employee Size Class  ";
label var n10_19 "Number of Establishments: 10-19 Employee Size Class  ";
label var n20_49 "Number of Establishments: 20-49 Employee Size Class  ";
label var n50_99 "Number of Establishments: 50-99 Employee Size Class  ";
label var n100_249 "Number of Establishments: 100-249 Employee Size Class  ";
label var n250_499 "Number of Establishments: 250-499 Employee Size Class  ";
label var n500_999 "Number of Establishments: 500-999 Employee Size Class  ";
label var n1000 "Number of Establishments: 1,000 or More Employee Size Class";
capture gen n1000_1 = .;
label var n1000_1 "Number of Establishments: Employment Size Class: 1,000-1,499 Employees  ";
capture gen n1000_2 = .;
label var n1000_2 "Number of Establishments: Employment Size Class: 1,500-2,499 Employees ";
capture gen n1000_3 = .;
label var n1000_3 "Number of Establishments: Employment Size Class: 2,500-4,999 Employees  ";
capture gen n1000_4 = .;
label var n1000_4 "Number of Establishments: Employment Size Class: 5,000 or More Employees  ";

/* industry switches in 1998 */
if ( `year' >= 1998 ) {;
	gen str4 sic="";
};
else {;
	gen str6 naics="";
};
label var naics "Industry Code - 6-digit NAICS code.   ";
label var sic "Industry Code - 4-digit SIC code.";

/* convert flags to numeric */
recode_flag;

/* from 2007 onwards, noise infusion is used */

if ( `year' >= 2007 ) {;
label var emp_nf "Total Mid-March Employees Noise Flag";
label var qp1_nf "Total First Quarter Payroll Noise Flag   ";
label var ap_nf "Total Annual Payroll Noise Flag    ";

/* transform characters to numbers for Stata */
foreach v of var emp_nf qp1_nf ap_nf {;
	local l`v' : variable label `v';
	if `"`l`v''"' == "" {;
		local l`v' "`v'";
	};
	recode_nflag `v' `v'_num;
	label var `v'_num "`l`v'' (numeric)";
	/* label value `v'_num nflag;*/
};
}; /* end of >2008 condition */

saveold $outputs/cbp`year'_msa, replace;
clear;
end;


forvalues yr = 1993/$maxyear {;
readin `yr';
};

