# black, heavy is not designed in monospace fonts
UNABRIDGED_GROUPS:=	hiragana1 katakana1 miscellaneous1 \
			hiragana2 katakana2 miscellaneous2 \
			latin_proportional1 latin_proportional2 \
			latin_clear1 latin_clear2
ABRIDGED_GROUPS:=	latin_monospace1 latin_monospace2 \
			latin_mono_new1 # latin_mono_new2
GROUPS:=		${UNABRIDGED_GROUPS} ${ABRIDGED_GROUPS}
BLACK_WEIGHTS:=		black heavy
NORMAL_WEIGHTS:=	bold medium regular light thin
WEIGHTS:=		${BLACK_WEIGHTS} ${NORMAL_WEIGHTS}
TARGETS:=		mplus-1p mplus-2p mplus-1m mplus-2m mplus-1c mplus-2c \
			mplus-1mn # mplus-2mn

BASELINE_SHIFT:=	58

all: split-svgs ttf

ttf: work.d/targets/mplus-1p/Makefile work.d/targets/mplus-2p/Makefile  work.d/targets/mplus-1m/Makefile work.d/targets/mplus-2m/Makefile work.d/targets/mplus-1c/Makefile work.d/targets/mplus-2c/Makefile work.d/targets/mplus-1mn/Makefile # work.d/targets/mplus-2mn/Makefile
	@(cd work.d/targets/mplus-1p ; make )
	@(cd work.d/targets/mplus-2p ; make )
	@(cd work.d/targets/mplus-1m ; make )
	@(cd work.d/targets/mplus-2m ; make )
	@(cd work.d/targets/mplus-1c ; make )
	@(cd work.d/targets/mplus-2c ; make )
	@(cd work.d/targets/mplus-1mn ; make)
#	@(cd work.d/targets/mplus-2mn ; make)

work.d/targets/mplus-1p/Makefile: scripts/target-Makefile.1.tmpl 
	sed s/^#Mplus-1P#// scripts/target-Makefile.1.tmpl > $@

work.d/targets/mplus-2p/Makefile: scripts/target-Makefile.1.tmpl 
	sed s/^#Mplus-2P#// scripts/target-Makefile.1.tmpl > $@

work.d/targets/mplus-1m/Makefile: scripts/target-Makefile.1s.tmpl 
	sed s/^#Mplus-1M#// scripts/target-Makefile.1s.tmpl > $@

work.d/targets/mplus-2m/Makefile: scripts/target-Makefile.1s.tmpl 
	sed s/^#Mplus-2M#// scripts/target-Makefile.1s.tmpl > $@

work.d/targets/mplus-1c/Makefile: scripts/target-Makefile.1.tmpl 
	sed s/^#Mplus-1C#// scripts/target-Makefile.1.tmpl > $@

work.d/targets/mplus-2c/Makefile: scripts/target-Makefile.1.tmpl 
	sed s/^#Mplus-2C#// scripts/target-Makefile.1.tmpl > $@

work.d/targets/mplus-1mn/Makefile: scripts/target-Makefile.1s.tmpl 
	sed s/^#Mplus-1mN#// scripts/target-Makefile.1s.tmpl > $@

work.d/targets/mplus-2mn/Makefile: scripts/target-Makefile.1s.tmpl 
	sed s/^#Mplus-2mN#// scripts/target-Makefile.1s.tmpl > $@

dirs:
	for w in $(NORMAL_WEIGHTS) ; do \
		for g in $(GROUPS) ; do \
			mkdir -p work.d/splitted/$$w/$$g/ ;\
		done ;\
		for t in $(TARGETS); do \
			mkdir -p work.d/targets/$$t/$$w/ ;\
		done \
	done
	for w in $(BLACK_WEIGHTS) ; do \
		for g in $(UNABRIDGED_GROUPS) ; do \
			mkdir -p work.d/splitted/$$w/$$g/ ;\
		done ;\
		for t in $(TARGETS); do \
			mkdir -p work.d/targets/$$t/$$w/ ;\
		done \
	done

split-svgs: dirs
	perl -I scripts scripts/split-svg.pl svg.d/*/*.svg
	for w in $(NORMAL_WEIGHTS) ; do \
		for g in $(GROUPS) ; do \
			expr 0 + `cat svg.d/$$g/baseline` + ${BASELINE_SHIFT} > work.d/splitted/$$w/$$g/baseline ;\
		done \
	done
	for w in $(BLACK_WEIGHTS) ; do \
		for g in $(UNABRIDGED_GROUPS) ; do \
			expr 0 + `cat svg.d/$$g/baseline` + ${BASELINE_SHIFT} > work.d/splitted/$$w/$$g/baseline ;\
		done \
	done

clean:
	@rm -rf work.d/ release/mplus-* *~ 

clean-targets:
	@rm -rf work.d/targets/

rebuild-ttf: clean-targets dirs ttf

release: ttf
	@(cd release ; make )
