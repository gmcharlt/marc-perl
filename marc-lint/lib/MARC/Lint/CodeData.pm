#!perl

package MARC::Lint::CodeData;

#declare the necessary variables
use vars qw($VERSION @EXPORT_OK %GeogAreaCodes %ObsoleteGeogAreaCodes %LanguageCodes %ObsoleteLanguageCodes %CountryCodes %ObsoleteCountryCodes);

$VERSION = '1.00';

use base qw(Exporter AutoLoader);

@EXPORT_OK = qw(%GeogAreaCodes %ObsoleteGeogAreaCodes %LanguageCodes %ObsoleteLanguageCodes %CountryCodes %ObsoleteCountryCodes);

$VERSION = '1.00';

=head1 NAME

MARC::Lint::CodeData -- Contains codes from the MARC code lists for Geographic Areas, Languages, and Countries.

Code data is used for validating fields 008, 040, 041, and 043.

Stores codes in hashes, %MARC::Lint::CodeData::[name].

=head1 SYNOPSIS

use MARC::Lint::CodeData;

#Should provide access to the following:
#%MARC::Lint::CodeData::GeogAreaCodes;
#%MARC::Lint::CodeData::ObsoleteGeogAreaCodes;
#%MARC::Lint::CodeData::LanguageCodes;
#%MARC::Lint::CodeData::ObsoleteLanguageCodes;
#%MARC::Lint::CodeData::CountryCodes
#%MARC::Lint::CodeData::ObsoleteCountryCodes

#or, import specific code list data
use MARC::Lint::CodeData qw(%GeogAreaCodes);

my $gac = "n-us---";
my $validgac = 1 if ($GeogAreaCodes{$gac});
print "Geographic Area Code $gac is valid\n" if $validgac;


=head1 EXPORT

None by default. 
@EXPORT_OK: %GeogAreaCodes, %ObsoleteGeogAreaCodes, %LanguageCodes, %ObsoleteLanguageCodes, %CountryCodes, %ObsoleteCountryCodes.

=head1 TO DO

Update codes as needed (see L<http://www.loc.gov/marc/>).

Add codes for MARC Code Lists for Relators, Sources, Description Conventions.

Determine whether three blank spaces should be in the LanguageCodes (for 008 validation) or not. 
If it is here, then 041 would be allowed to have three blank spaces as a valid code 
(though other checks would report the error--spaces at the beginning and ending of a subfield
and multiple spaces in a field where such a thing is not allowed).

=head2 SEE ALSO

L<MARC::Lint>

L<MARC::Lintadditions> (for check_040, check_041, check_043 using these codes)

L<MARC::Errorchecks> (for 008 validation using these codes)

L<http://www.loc.gov/marc/> for the official code lists.

The following (should be included in the distribution package for this package):
countrycodelistclean.pl
gaccleanupscript.pl
languagecodelistclean.pl
The scripts above take the MARC code list ASCII version as input.
They output tab-separated codes for updating the data below.

=head1 VERSION HISTORY

Version 1.00 (original version): First release, Dec. 5, 2004.
 -Included in MARC::Errorchecks distribution on CPAN.
 -Used by MARC::Lintadditions.

=cut

#fill the valid Geographic Area Codes hash

%GeogAreaCodes = map {($_, 1)} (split "\t", ("a-af---	f------	fc-----	fe-----	fq-----	ff-----	fh-----	fs-----	fb-----	fw-----	n-us-al	n-us-ak	e-aa---	n-cn-ab	f-ae---	ea-----	sa-----	poas---	aa-----	sn-----	e-an---	f-ao---	nwxa---	a-cc-an	t------	nwaq---	nwla---	n-usa--	ma-----	ar-----	au-----	r------	s-ag---	n-us-az	n-us-ar	a-ai---	nwaw---	lsai---	u-ac---	a------	ac-----	as-----	l------	fa-----	u------	u-at---	u-at-ac	e-au---	a-aj---	lnaz---	nwbf---	a-ba---	ed-----	eb-----	a-bg---	nwbb---	a-cc-pe	e-bw---	e-be---	ncbh---	el-----	ab-----	f-dm---	lnbm---	a-bt---	mb-----	a-ccp--	s-bo---	nwbn---	a-bn---	e-bn---	f-bs---	lsbv---	s-bl---	n-cn-bc	i-bi---	nwvb---	a-bx---	e-bu---	f-uv---	a-br---	f-bd---	n-us-ca	a-cb---	f-cm---	n-cn---	nccz---	lnca---	lncv---	cc-----	poci---	ak-----	e-urk--	e-urr--	nwcj---	f-cx---	nc-----	e-urc--	f-cd---	s-cl---	a-cc---	a-cc-cq	i-xa---	i-xb---	q------	s-ck---	n-us-co	b------	i-cq---	f-cf---	f-cg---	fg-----	n-us-ct	pocw---	u-cs---	nccr---	e-ci---	nwcu---	nwco---	a-cy---	e-xr---	e-cs---	f-iv---	eo-----	zd-----	n-us-de	e-dk---	dd-----	d------	f-ft---	nwdq---	nwdr---	x------	n-usr--	ae-----	an-----	a-em---	poea---	xa-----	s-ec---	f-ua---	nces---	e-uk-en	f-eg---	f-ea---	e-er---	f-et---	me-----	e------	ec-----	ee-----	en-----	es-----	ew-----	lsfk---	lnfa---	pofj---	e-fi---	n-us-fl	e-fr---	h------	s-fg---	pofp---	a-cc-fu	f-go---	pogg---	f-gm---	a-cc-ka	awgz---	n-us-ga	a-gs---	e-gx---	e-ge---	e-gw---	f-gh---	e-gi---	e-uk---	e-uk-ui	nl-----	np-----	fr-----	e-gr---	n-gl---	nwgd---	nwgp---	pogu---	a-cc-kn	a-cc-kc	ncgt---	f-gv---	f-pg---	a-cc-kw	s-gy---	a-cc-ha	nwht---	n-us-hi	i-hm---	a-cc-hp	a-cc-he	a-cc-ho	ah-----	nwhi---	ncho---	a-cc-hk	a-cc-hh	n-cnh--	a-cc-hu	e-hu---	e-ic---	n-us-id	n-us-il	a-ii---	i------	n-us-in	ai-----	a-io---	a-cc-im	m------	c------	n-us-ia	a-ir---	a-iq---	e-ie---	a-is---	e-it---	nwjm---	lnjn---	a-ja---	a-cc-ku	a-cc-ki	a-cc-kr	poji---	a-jo---	zju----	n-us-ks	a-kz---	n-us-ky	f-ke---	poki---	pokb---	a-kr---	a-kn---	a-ko---	a-cck--	a-ku---	a-kg---	a-ls---	cl-----	e-lv---	a-le---	nwli---	f-lo---	a-cc-lp	f-lb---	f-ly---	e-lh---	poln---	e-li---	n-us-la	e-lu---	a-cc-mh	e-xn---	f-mg---	lnma---	n-us-me	f-mw---	am-----	a-my---	i-xc---	f-ml---	e-mm---	n-cn-mb	poxd---	n-cnm--	zma----	poxe---	nwmq---	n-us-md	n-us-ma	f-mu---	i-mf---	i-my---	mm-----	ag-----	pome---	zme----	n-mx---	nm-----	n-us-mi	pott---	pomi---	n-usl--	aw-----	n-usc--	poxf---	n-us-mn	n-us-ms	n-usm--	n-us-mo	n-uss--	e-mv---	e-mc---	a-mp---	n-us-mt	nwmj---	zmo----	f-mr---	f-mz---	f-sx---	ponu---	n-us-nb	a-np---	zne----	e-ne---	nwna---	n-us-nv	n-cn-nk	ponl---	n-usn--	a-nw---	n-us-nh	n-us-nj	n-us-nm	u-at-ne	n-us-ny	u-nz---	n-cn-nf	ncnq---	f-ng---	fi-----	f-nr---	fl-----	a-cc-nn	poxh---	n------	ln-----	n-us-nc	n-us-nd	pn-----	n-use--	xb-----	e-uk-ni	u-at-no	n-cn-nt	e-no---	n-cn-ns	n-cn-nu	po-----	n-us-oh	n-uso--	n-us-ok	a-mk---	n-cn-on	n-us-or	zo-----	p------	a-pk---	popl---	ncpn---	a-pp---	aopf---	s-py---	n-us-pa	ap-----	s-pe---	a-ph---	popc---	zpl----	e-pl---	pops---	e-po---	n-cnp--	n-cn-pi	nwpr---	ep-----	a-qa---	a-cc-ts	u-at-qn	n-cn-qu	mr-----	er-----	n-us-ri	sp-----	nr-----	e-rm---	e-ru---	e-ur---	e-urf--	f-rw---	i-re---	nwsd---	fd-----	nweu---	lsxj---	nwxi---	nwxk---	nwst---	n-xl---	nwxm---	pows---	posh---	e-sm---	f-sf---	n-cn-sn	zsa----	a-su---	ev-----	e-uk-st	f-sg---	i-se---	a-cc-ss	a-cc-sp	a-cc-sm	a-cc-sh	e-urs--	e-ure--	e-urw--	a-cc-sz	f-sl---	a-si---	e-xo---	e-xv---	i-xo---	zs-----	pobp---	f-so---	f-sa---	s------	az-----	ls-----	u-at-sa	n-us-sc	ao-----	n-us-sd	lsxs---	ps-----	xc-----	n-usu--	n-ust--	e-urn--	e-sp---	f-sh---	aoxp---	a-ce---	f-sj---	fn-----	fu-----	zsu----	s-sr---	lnsb---	nwsv---	f-sq---	e-sw---	e-sz---	a-sy---	a-ch---	a-ta---	f-tz---	u-at-tm	n-us-tn	i-fs---	n-us-tx	a-th---	af-----	a-cc-tn	a-cc-ti	at-----	f-tg---	potl---	poto---	nwtr---	lstd---	w------	f-ti---	a-tu---	a-tk---	nwtc---	potv---	f-ug---	e-un---	a-ts---	n-us---	nwuc---	poup---	e-uru--	zur----	s-uy---	n-us-ut	a-uz---	ponn---	e-vc---	s-ve---	zve----	n-us-vt	u-at-vi	a-vt---	nwvi---	n-us-va	e-urp--	fv-----	powk---	e-uk-wl	powf---	n-us-dc	n-us-wa	n-usp--	awba---	nw-----	n-us-wv	u-at-we	xd-----	f-ss---	nwwi---	n-us-wi	n-us-wy	a-ccs--	a-cc-su	a-ccg--	a-ccy--	ay-----	a-ye---	e-yu---	n-cn-yk	a-cc-yu	fz-----	f-za---	a-cc-ch	f-rh---"));

#fill the obsolete Geographic Area Codes hash

%ObsoleteGeogAreaCodes = map {($_, 1)} (split "\t", ("t-ay---	e-ur-ai	e-ur-aj	nwbc---	e-ur-bw	f-by---	pocp---	e-url--	cr-----	v------	e-ur-er	et-----	e-ur-gs	pogn---	nwga---	nwgs---	a-hk---	ei-----	f-if---	awiy---	awiw---	awiu---	e-ur-kz	e-ur-kg	e-ur-lv	e-ur-li	a-mh---	cm-----	e-ur-mv	n-usw--	a-ok---	a-pt---	e-ur-ru	pory---	nwsb---	posc---	a-sk---	posn---	e-uro--	e-ur-ta	e-ur-tk	e-ur-un	e-ur-uz	a-vn---	a-vs---	nwvr---	e-urv--	a-ys---"));

#fill the valid Language Codes hash

%LanguageCodes = map {($_, 1)} (split "\t", ("   	abk	ace	ach	ada	ady	aar	afh	afr	afa	aka	akk	alb	ale	alg	tut	amh	apa	ara	arg	arc	arp	arw	arm	art	asm	ath	aus	map	ava	ave	awa	aym	aze	ast	ban	bat	bal	bam	bai	bad	bnt	bas	bak	baq	btk	bej	bel	bem	ben	ber	bho	bih	bik	bis	bos	bra	bre	bug	bul	bua	bur	cad	car	cat	cau	ceb	cel	cai	chg	cmc	cha	che	chr	chy	chb	chi	chn	chp	cho	chu	chv	cop	cor	cos	cre	mus	crp	cpe	cpf	cpp	crh	scr	cus	cze	dak	dan	dar	day	del	din	div	doi	dgr	dra	dua	dut	dum	dyu	dzo	bin	efi	egy	eka	elx	eng	enm	ang	epo	est	gez	ewe	ewo	fan	fat	fao	fij	fin	fiu	fon	fre	frm	fro	fry	fur	ful	glg	lug	gay	gba	geo	ger	gmh	goh	gem	gil	gon	gor	got	grb	grc	gre	grn	guj	gwi	gaa	hai	hat	hau	haw	heb	her	hil	him	hin	hmo	hit	hmn	hun	hup	iba	ice	ido	ibo	ijo	ilo	smn	inc	ine	ind	inh	ina	ile	iku	ipk	ira	gle	mga	sga	iro	ita	jpn	jav	jrb	jpr	kbd	kab	kac	xal	kal	kam	kan	kau	kaa	kar	kas	kaw	kaz	kha	khm	khi	kho	kik	kmb	kin	kom	kon	kok	kor	kpe	kro	kua	kum	kur	kru	kos	kut	kir	lad	lah	lam	lao	lat	lav	ltz	lez	lim	lin	lit	nds	loz	lub	lua	lui	smj	lun	luo	lus	mac	mad	mag	mai	mak	mlg	may	mal	mlt	mnc	mdr	man	mni	mno	glv	mao	arn	mar	chm	mah	mwr	mas	myn	men	mic	min	mis	moh	mol	mkh	lol	mon	mos	mul	mun	nah	nau	nav	nbl	nde	ndo	nap	nep	new	nia	nic	ssa	niu	nog	nai	sme	nso	nor	nob	nno	nub	nym	nya	nyn	nyo	nzi	oci	oji	non	peo	ori	orm	osa	oss	oto	pal	pau	pli	pam	pag	pan	pap	paa	per	phi	phn	pol	pon	por	pra	pro	pus	que	roh	raj	rap	rar	roa	rom	rum	run	rus	sal	sam	smi	smo	sad	sag	san	sat	srd	sas	sco	gla	sel	sem	scc	srr	shn	sna	iii	sid	sgn	bla	snd	sin	sit	sio	sms	den	sla	slo	slv	sog	som	son	snk	wen	sot	sai	sma	spa	suk	sux	sun	sus	swa	ssw	swe	syr	tgl	tah	tai	tgk	tmh	tam	tat	tel	tem	ter	tet	tha	tib	tir	tig	tiv	tli	tpi	tkl	tog	ton	chk	tsi	tso	tsn	tum	tup	tur	ota	tuk	tvl	tyv	twi	udm	uga	uig	ukr	umb	und	urd	uzb	vai	ven	vie	vol	vot	wak	wal	wln	war	was	wel	wol	xho	sah	yao	yap	yid	yor	ypk	znd	zap	zen	zha	zul	zun"));

#fill the obsolete Language Codes hash

%ObsoleteLanguageCodes = map {($_, 1)} (split "\t", ("ajm	esk	esp	eth	far	fri	gag	gua	int	iri	cam	kus	mla	max	lan	gal	lap	sao	gae	sho	snh	sso	swz	tag	taj	tar	tru	tsw"));

#fill the valid Country Codes hash

%CountryCodes = map {($_, 1)} (split "\t", ("af 	alu	aku	aa 	abc	ae 	as 	an 	ao 	am 	ay 	aq 	ag 	azu	aru	ai 	aw 	at 	au 	aj 	bf 	ba 	bg 	bb 	bw 	be 	bh 	dm 	bm 	bt 	bo 	bn 	bs 	bv 	bl 	bcc	bi 	vb 	bx 	bu 	uv 	br 	bd 	cau	cb 	cm 	xxc	cv 	cj 	cx 	cd 	cl 	cc 	ch 	xa 	xb 	ck 	cou	cq 	cf 	cg 	ctu	cw 	cr 	ci 	cu 	cy 	xr 	iv 	deu	dk 	dcu	ft 	dq 	dr 	em 	ec 	ua 	es 	enk	eg 	ea 	er 	et 	fk 	fa 	fj 	fi 	flu	fr 	fg 	fp 	go 	gm 	gz 	gau	gs 	gw 	gh 	gi 	gr 	gl 	gd 	gp 	gu 	gt 	gv 	pg 	gy 	ht 	hiu	hm 	ho 	hu 	ic 	idu	ilu	ii 	inu	io 	iau	ir 	iq 	iy 	ie 	is 	it 	jm 	ja 	ji 	jo 	ksu	kz 	kyu	ke 	gb 	kn 	ko 	ku 	kg 	ls 	lv 	le 	lo 	lb 	ly 	lh 	li 	lau	lu 	xn 	mg 	meu	mw 	my 	xc 	ml 	mm 	mbc	xe 	mq 	mdu	mau	mu 	mf 	ot 	mx 	miu	fm 	xf 	mnu	msu	mou	mv 	mc 	mp 	mtu	mj 	mr 	mz 	sx 	nu 	nbu	np 	ne 	na 	nvu	nkc	nl 	nhu	nju	nmu	nyu	nz 	nfc	nq 	ng 	nr 	xh 	xx 	nx 	ncu	ndu	nik	nw 	ntc	no 	nsc	nuc	ohu	oku	mk 	onc	oru	pk 	pw 	pn 	pp 	pf 	py 	pau	pe 	ph 	pc 	pl 	po 	pic	pr 	qa 	quc	riu	rm 	ru 	rw 	re 	xj 	xd 	xk 	xl 	xm 	ws 	sm 	sf 	snc	su 	stk	sg 	yu 	se 	sl 	si 	xo 	xv 	bp 	so 	sa 	scu	sdu	xs 	sp 	sh 	xp 	ce 	sj 	sr 	sq 	sw 	sz 	sy 	ta 	tz 	tnu	fs 	txu	th 	tg 	tl 	to 	tr 	ti 	tu 	tk 	tc 	tv 	ug 	un 	ts 	xxk	uik	xxu	uc 	up 	uy 	utu	uz 	nn 	vp 	vc 	ve 	vtu	vm 	vi 	vau	wk 	wlk	wf 	wau	wj 	wvu	ss 	wiu	wyu	ye 	ykc	za 	rh "));

#fill the obsolete Country Codes hash

%ObsoleteCountryCodes = map {($_, 1)} (split "\t", ("ai 	air	ac 	ajr	bwr	cn 	cz 	cp 	ln 	cs 	err	gsr	ge 	gn 	hk 	iw 	iu 	jn 	kzr	kgr	lvr	lir	mh 	mvr	nm 	pt 	rur	ry 	xi 	sk 	xxr	sb 	sv 	tar	tt 	tkr	unr	uk 	ui 	us 	uzr	vn 	vs 	wb 	ys "));

1;

=head1 LICENSE

This code may be distributed under the same terms as Perl itself. 

Please note that this module is not a product of or supported by the 
employers of the various contributors to the code.

=head1 AUTHOR

Bryan Baldus
eijabb@cpan.org

Copyright (c) 2004.

=cut

__END__