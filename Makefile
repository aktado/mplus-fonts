#Mplus-1M#COMMON_SUBST=	s/%%FONTNAME_BASE%%/mplus-1m/;s/%%FAMILY%%/m+-1m/;s/%%MODULES_LATIN%%/latin_monospace1/;s/%%MODULES_KANA%%/hiragana1 katakana1 miscellaneous1 latin_fullwidth1 latin_full_clear1/
#Mplus-2M#COMMON_SUBST=	s/%%FONTNAME_BASE%%/mplus-2m/;s/%%FAMILY%%/m+-2m/;s/%%MODULES_LATIN%%/latin_monospace1 latin_monospace2/;s/%%MODULES_KANA%%/hiragana2 katakana2 miscellaneous2 latin_full_clear1 latin_full_clear2/
#Mplus-1mN#COMMON_SUBST=	s/%%FONTNAME_BASE%%/mplus-1mn/;s/%%FAMILY%%/m+-1mn/;s/%%MODULES_LATIN%%/latin_mono_new1/;s/%%MODULES_KANA%%/hiragana1 katakana1 miscellaneous1 latin_full_clear1/
COMMON_SUBST=	s/%%FONTNAME_BASE%%/mplus-2mn/;s/%%FAMILY%%/m+-2m/;s/%%MODULES_LATIN%%/latin_mono_new1/;s/%%MODULES_KANA%%/hiragana2 katakana2 miscellaneous2 latin_full_clear1 latin_full_clear2/

# black and heavy is missing
TEMPLATE=	../../../scripts/target-Makefile.2.tmpl
SUBDIRS=	bold medium regular light thin
MAKEFILES=	bold/Makefile medium/Makefile regular/Makefile light/Makefile thin/Makefile

all:: $(MAKEFILES)
	for i in $(SUBDIRS) ;\
	do \
	(cd $$i && make) ;\
	done

bold/Makefile: ${TEMPLATE}
	sed '${COMMON_SUBST};s/%%WEIGHT%%/bold/g' ${TEMPLATE} > $@

medium/Makefile: ${TEMPLATE}
	sed '${COMMON_SUBST};s/%%WEIGHT%%/medium/g' ${TEMPLATE} > $@

regular/Makefile: ${TEMPLATE}
	sed '${COMMON_SUBST};s/%%WEIGHT%%/regular/g' ${TEMPLATE} > $@

light/Makefile: ${TEMPLATE}
	sed '${COMMON_SUBST};s/%%WEIGHT%%/light/g' ${TEMPLATE} > $@

thin/Makefile: ${TEMPLATE}
	sed '${COMMON_SUBST};s/%%WEIGHT%%/thin/g' ${TEMPLATE} > $@

clean:
	rm -f *~
	rm -f */*.ttf */build-ttf.pe */set_bearings */set_kernings */set_fontnames */tmp.sfd
