###########################################################################
##                                                                       ##
##                  Language Technologies Institute                      ##
##                     Carnegie Mellon University                        ##
##                      Copyright (c) 1999-2017                          ##
##                        All Rights Reserved.                           ##
##                                                                       ##
##  Permission is hereby granted, free of charge, to use and distribute  ##
##  this software and its documentation without restriction, including   ##
##  without limitation the rights to use, copy, modify, merge, publish,  ##
##  distribute, sublicense, and/or sell copies of this work, and to      ##
##  permit persons to whom this work is furnished to do so, subject to   ##
##  the following conditions:                                            ##
##   1. The code must retain the above copyright notice, this list of    ##
##      conditions and the following disclaimer.                         ##
##   2. Any modifications must be clearly marked as such.                ##
##   3. Original authors' names are not deleted.                         ##
##   4. The authors' names are not used to endorse or promote products   ##
##      derived from this software without specific prior written        ##
##      permission.                                                      ##
##                                                                       ##
##  CARNEGIE MELLON UNIVERSITY AND THE CONTRIBUTORS TO THIS WORK         ##
##  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      ##
##  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   ##
##  SHALL CARNEGIE MELLON UNIVERSITY NOR THE CONTRIBUTORS BE LIABLE      ##
##  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    ##
##  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   ##
##  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          ##
##  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       ##
##  THIS SOFTWARE.                                                       ##
##                                                                       ##
###########################################################################
##                                                                       ##
##    Fast efficient small run-time speech synthesis system              ##
##    http://cmuflite.org                                                ##
##                                                                       ##
##       Authors:  Alan W Black (awb@cs.cmu.edu)                         ##
##                 Kevin A. Lenzo (lenzo@cs.cmu.edu)                     ##
##                 and others see ACKNOWLEDGEMENTS                       ##
##          Date:  Mar 2022                                              ##
##       Version:  2.3 current                                           ##
##                                                                       ## 
###########################################################################
##    MODIFIED:                                                          ##
##    Minimal support for wasm32-unknown-unknown                         ##
##       Authors:  Bryan Jimenez                                         ##
##          Date:  Dec 2024                                              ##
###########################################################################

TOP=.
DIRNAME=
BUILD_DIRS = include src lang doc
ALL_DIRS=config $(BUILD_DIRS) testsuite \
         wince windows android \
         sapi tools main 
CONFIG=configure configure.in config.sub config.guess \
       missing install-sh mkinstalldirs
OLD_WINDOWS = Exports.def flite.sln fliteDll.vcproj
WINDOWS = Exports.def flite.sln flite.v11.suo fliteDll.vcxproj fliteDll.vcxproj.filters
FILES = Makefile README.md ACKNOWLEDGEMENTS COPYING $(CONFIG) $(WINDOWS)
DIST_CLEAN = .time-stamp $(TOP)/build/ \
                config.cache config.log config.status \
		config/config config/system.mak FileList

HOST_ONLY_DIRS = tools main
ALL = $(BUILD_DIRS)

config_dummy := $(shell test -f config/config || ( echo '*** '; echo '*** Making default config file ***'; echo '*** '; ./configure; )  >&2)

# TODO: set up build to configure for wasm32-unknown-unknown
#include $(TOP)/config/common_make_rules

ifeq ($(TARGET_OS),wince)
BUILD_DIRS += wince
endif

config/config: config/config.in config.status
	./config.status

configure: configure.in
	autoconf

get_voices:
	./bin/get_voices us_voices
#	 ./bin/get_voices indic_voices

backup: time-stamp
	@ $(RM) -f $(TOP)/FileList
	@ $(MAKE) file-list
	@ echo .time-stamp >>FileList
	@ ln -s . $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)
	@ sed 's/^\.\///' <FileList | sed 's/^/'$(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)'\//' >.file-list-all
	@ tar jcvf $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2 `cat $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)/.file-list-all`
	@ $(RM) -f $(TOP)/.file-list-all
	@ $(RM) $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE) 
	@ ls -l $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2

backupbz2: time-stamp
	@ $(RM) -f $(TOP)/FileList
	@ $(MAKE) file-list
	@ echo .time-stamp >>FileList
	@ ln -s . $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)
	@ sed 's/^\.\///' <FileList | sed 's/^/'$(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)'\//' | grep -v cmu_us_kal | grep -v cmu_us_awb | grep -v cmu_us_rms | grep -v cmu_us_slt | grep -v cmu_time_awb >.file-list-all
	@ tar jcvf $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2 `cat $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE)/.file-list-all`
	@ $(RM) -f $(TOP)/.file-list-all
	@ $(RM) $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE) 
	@ ls -l $(PROJECT_PREFIX)-$(PROJECT_VERSION)-$(PROJECT_STATE).tar.bz2

tags:
	@ $(RM) -f $(TOP)/FileList
	@ $(MAKE) file-list
	etags `cat FileList | grep "\.[ch]$$"`

install:
	@echo Installing 
	mkdir -p $(DESTDIR)$(INSTALLBINDIR)
	mkdir -p $(DESTDIR)$(INSTALLLIBDIR)
	mkdir -p $(DESTDIR)$(INSTALLINCDIR)
	$(INSTALL) -m 644 include/*.h $(DESTDIR)$(INSTALLINCDIR)
	@ $(MAKE) -C main --no-print-directory DESTDIR=$(DESTDIR) install

time-stamp :
	@ echo $(PROJECT_NAME) >.time-stamp
	@ echo $(PROJECT_PREFIX) >>.time-stamp
	@ echo $(PROJECT_VERSION) >>.time-stamp
	@ echo $(PROJECT_DATE) >>.time-stamp
	@ echo $(PROJECT_STATE) >>.time-stamp
	@ echo $(LOGNAME) >>.time-stamp
	@ hostname >>.time-stamp
	@ date >>.time-stamp

# Convinience command, to generate cg dumped voices
voices: ./bin/flite_cmu_us_awb ./bin/flite_cmu_us_rms ./bin/flite_cmu_us_rms
	mkdir -p voices
	./bin/flite_cmu_us_awb -voicedump voices/cmu_us_awb.flitevox
	./bin/flite_cmu_us_rms -voicedump voices/cmu_us_rms.flitevox
	./bin/flite_cmu_us_slt -voicedump voices/cmu_us_slt.flitevox

test:
	@ $(MAKE) --no-print-directory -C testsuite test

clean-wasm:
	-rm ./include/flite_patch_*.h
	-rm ./main/*.o ./tools/*.o
	-rm -rf ./bin ./build

build-project:
# build wasm32-unknown-unknown
	$(eval target=--target=wasm32-unknown-unknown)
	$(eval T_DIR=wasm32-unknown-unknown)
	$(eval L_DIR=../flite-patch/dist)
	$(eval CC=clang)
	$(eval LD=wasm-ld)
	$(eval AR=llvm-ar)
#	$(eval AR=/usr/bin/ar)
# llvm-ranlib not needed if using [llvm-ar -s](https://llvm.org/docs/CommandGuide/llvm-ar.html#cmdoption-llvm-ar-arg-s)
#	$(eval RANLIB=llvm-ranlib)
	$(eval CFLAGS=-DWASM_NO_LIB -nostdlib -mbulk-memory -Wall )
#	$(eval CFLAGS_WASM=$(CFLAGS) -Wl,--strip-all -Wl,--export-dynamic -Wl,--no-entry)
# Copy patched std-libs for wasm
	cp $(L_DIR)/flite_patch_ctype.h ./include/
	cp $(L_DIR)/flite_patch_wchar.h ./include/
	cp $(L_DIR)/flite_patch_math.h ./include/
	cp $(L_DIR)/flite_patch_stdarg.h ./include/
	cp $(L_DIR)/flite_patch_stddef.h ./include/
	cp $(L_DIR)/flite_patch_stdio.h ./include/
	cp $(L_DIR)/flite_patch_stdlib.h ./include/
	cp $(L_DIR)/flite_patch_string.h ./include/
	cp $(L_DIR)/flite_patch_logging.h ./include/
	mkdir -p "./build/$(T_DIR)/lib"
	echo "making in src/audio ..."
	mkdir -p "./build/$(T_DIR)/obj/src/audio"
	$(eval BUILD_DIR=./src/audio)
	$(CC) $(target) -I. -DCST_AUDIO_NONE -I./include $(CFLAGS)     -c $(BUILD_DIR)/audio.c -o ./build/$(T_DIR)/obj/src/audio/audio.o
	$(CC) $(target) -I. -DCST_AUDIO_NONE -I./include $(CFLAGS)     -c $(BUILD_DIR)/au_streaming.c -o ./build/$(T_DIR)/obj/src/audio/au_streaming.o
	$(CC) $(target) -I. -DCST_AUDIO_NONE -I./include $(CFLAGS)     -c $(BUILD_DIR)/au_none.c -o ./build/$(T_DIR)/obj/src/audio/au_none.o
	echo "making in src/utils ..."
	mkdir -p "./build/$(T_DIR)/obj/src/utils"
	$(eval BUILD_DIR=./src/utils)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_alloc.c -o ./build/$(T_DIR)/obj/src/utils/cst_alloc.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_error.c -o ./build/$(T_DIR)/obj/src/utils/cst_error.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_string.c -o ./build/$(T_DIR)/obj/src/utils/cst_string.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_wchar.c -o ./build/$(T_DIR)/obj/src/utils/cst_wchar.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_tokenstream.c -o ./build/$(T_DIR)/obj/src/utils/cst_tokenstream.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_val.c -o ./build/$(T_DIR)/obj/src/utils/cst_val.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_features.c -o ./build/$(T_DIR)/obj/src/utils/cst_features.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_endian.c -o ./build/$(T_DIR)/obj/src/utils/cst_endian.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_val_const.c -o ./build/$(T_DIR)/obj/src/utils/cst_val_const.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_val_user.c -o ./build/$(T_DIR)/obj/src/utils/cst_val_user.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_mmap_none.c -o ./build/$(T_DIR)/obj/src/utils/cst_mmap_none.o
# File I/O wrapper for wasm32-unknown-unknown
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_file_none.c -o ./build/$(T_DIR)/obj/src/utils/cst_file_none.o
	echo "making in src/regex ..."
	mkdir -p "./build/$(T_DIR)/obj/src/regex"
	$(eval BUILD_DIR=./src/regex)
	$(CC) $(target)  -I. -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_regex.c -o ./build/$(T_DIR)/obj/src/regex/cst_regex.o
	$(CC) $(target)  -I. -I./include $(CFLAGS)     -c $(BUILD_DIR)/regexp.c -o ./build/$(T_DIR)/obj/src/regex/regexp.o
	$(CC) $(target)  -I. -I./include $(CFLAGS)     -c $(BUILD_DIR)/regsub.c -o ./build/$(T_DIR)/obj/src/regex/regsub.o
	echo "making in src/hrg ..."
	mkdir -p "./build/$(T_DIR)/obj/src/hrg"
	$(eval BUILD_DIR=./src/hrg)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_utterance.c -o ./build/$(T_DIR)/obj/src/hrg/cst_utterance.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_relation.c -o ./build/$(T_DIR)/obj/src/hrg/cst_relation.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_item.c -o ./build/$(T_DIR)/obj/src/hrg/cst_item.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_ffeature.c -o ./build/$(T_DIR)/obj/src/hrg/cst_ffeature.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_rel_io.c -o ./build/$(T_DIR)/obj/src/hrg/cst_rel_io.o
	echo "making in src/stats ..."
	mkdir -p "./build/$(T_DIR)/obj/src/stats"
	$(eval BUILD_DIR=./src/stats)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_cart.c -o ./build/$(T_DIR)/obj/src/stats/cst_cart.o
	echo "making in src/speech ..."
	mkdir -p "./build/$(T_DIR)/obj/src/speech"
	$(eval BUILD_DIR=./src/speech)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_wave.c -o ./build/$(T_DIR)/obj/src/speech/cst_wave.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_wave_io.c -o ./build/$(T_DIR)/obj/src/speech/cst_wave_io.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_track.c -o ./build/$(T_DIR)/obj/src/speech/cst_track.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_wave_utils.c -o ./build/$(T_DIR)/obj/src/speech/cst_wave_utils.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_lpcres.c -o ./build/$(T_DIR)/obj/src/speech/cst_lpcres.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/rateconv.c -o ./build/$(T_DIR)/obj/src/speech/rateconv.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/g721.c -o ./build/$(T_DIR)/obj/src/speech/g721.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/g72x.c -o ./build/$(T_DIR)/obj/src/speech/g72x.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/g723_24.c -o ./build/$(T_DIR)/obj/src/speech/g723_24.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/g723_40.c -o ./build/$(T_DIR)/obj/src/speech/g723_40.o
	echo "making in src/lexicon ..."
	mkdir -p "./build/$(T_DIR)/obj/src/lexicon"
	$(eval BUILD_DIR=./src/lexicon)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_lexicon.c -o ./build/$(T_DIR)/obj/src/lexicon/cst_lexicon.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_lts.c -o ./build/$(T_DIR)/obj/src/lexicon/cst_lts.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_lts_rewrites.c -o ./build/$(T_DIR)/obj/src/lexicon/cst_lts_rewrites.o
	echo "making in src/synth ..."
	mkdir -p "./build/$(T_DIR)/obj/src/synth"
	$(eval BUILD_DIR=./src/synth)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_synth.c -o ./build/$(T_DIR)/obj/src/synth/cst_synth.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_utt_utils.c -o ./build/$(T_DIR)/obj/src/synth/cst_utt_utils.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_voice.c -o ./build/$(T_DIR)/obj/src/synth/cst_voice.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_phoneset.c -o ./build/$(T_DIR)/obj/src/synth/cst_phoneset.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_ffeatures.c -o ./build/$(T_DIR)/obj/src/synth/cst_ffeatures.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/flite.c -o ./build/$(T_DIR)/obj/src/synth/flite.o
	echo "making in src/wavesynth ..."
	mkdir -p "./build/$(T_DIR)/obj/src/wavesynth"
	$(eval BUILD_DIR=./src/wavesynth)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_units.c -o ./build/$(T_DIR)/obj/src/wavesynth/cst_units.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_clunits.c -o ./build/$(T_DIR)/obj/src/wavesynth/cst_clunits.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_diphone.c -o ./build/$(T_DIR)/obj/src/wavesynth/cst_diphone.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_sigpr.c -o ./build/$(T_DIR)/obj/src/wavesynth/cst_sigpr.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_sts.c -o ./build/$(T_DIR)/obj/src/wavesynth/cst_sts.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_reflpc.c -o ./build/$(T_DIR)/obj/src/wavesynth/cst_reflpc.o
	echo "making in src/cg ..."
	mkdir -p "./build/$(T_DIR)/obj/src/cg"
	$(eval BUILD_DIR=./src/cg)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_cg.c -o ./build/$(T_DIR)/obj/src/cg/cst_cg.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_mlsa.c -o ./build/$(T_DIR)/obj/src/cg/cst_mlsa.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_mlpg.c -o ./build/$(T_DIR)/obj/src/cg/cst_mlpg.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_vc.c -o ./build/$(T_DIR)/obj/src/cg/cst_vc.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cst_cg_map.c -o ./build/$(T_DIR)/obj/src/cg/cst_cg_map.o
# echo "making in lang ..."
# mkdir -p "./build/$(T_DIR)/obj/src/lang"
	echo "making in lang/cmulex ..."
	mkdir -p "./build/$(T_DIR)/obj/lang/cmulex"
	$(eval BUILD_DIR=./lang/cmulex)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_lts_rules.c -o ./build/$(T_DIR)/obj/lang/cmulex/cmu_lts_rules.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_lts_model.c -o ./build/$(T_DIR)/obj/lang/cmulex/cmu_lts_model.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_lex.c -o ./build/$(T_DIR)/obj/lang/cmulex/cmu_lex.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_lex_entries.c -o ./build/$(T_DIR)/obj/lang/cmulex/cmu_lex_entries.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_lex_data.c -o ./build/$(T_DIR)/obj/lang/cmulex/cmu_lex_data.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_postlex.c -o ./build/$(T_DIR)/obj/lang/cmulex/cmu_postlex.o
	echo "making in lang/usenglish ..."
	mkdir -p "./build/$(T_DIR)/obj/lang/usenglish"
	$(eval BUILD_DIR=./lang/usenglish)
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_int_accent_cart.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_int_accent_cart.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_int_tone_cart.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_int_tone_cart.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_f0_model.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_f0_model.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_dur_stats.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_dur_stats.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_durz_cart.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_durz_cart.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_f0lr.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_f0lr.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_phoneset.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_phoneset.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_ffeatures.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_ffeatures.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_phrasing_cart.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_phrasing_cart.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_gpos.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_gpos.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_text.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_text.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_expand.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_expand.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_nums_cart.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_nums_cart.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_aswd.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_aswd.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/usenglish.c -o ./build/$(T_DIR)/obj/lang/usenglish/usenglish.o
	$(CC) $(target)   -I./include $(CFLAGS)     -c $(BUILD_DIR)/us_pos_cart.c -o ./build/$(T_DIR)/obj/lang/usenglish/us_pos_cart.o
	echo "making in lang/cmu_us_kal ..."
	mkdir -p "./build/$(T_DIR)/obj/lang/cmu_us_kal"
	$(eval BUILD_DIR=./lang/cmu_us_kal)
	$(CC) $(target)  -I./lang/usenglish -I./lang/cmulex  -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_us_kal_diphone.c -o ./build/$(T_DIR)/obj/lang/cmu_us_kal/cmu_us_kal_diphone.o
	$(CC) $(target)  -I./lang/usenglish -I./lang/cmulex  -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_us_kal.c -o ./build/$(T_DIR)/obj/lang/cmu_us_kal/cmu_us_kal.o
	$(CC) $(target)  -I./lang/usenglish -I./lang/cmulex  -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_us_kal_lpc.c -o ./build/$(T_DIR)/obj/lang/cmu_us_kal/cmu_us_kal_lpc.o
	$(CC) $(target)  -I./lang/usenglish -I./lang/cmulex  -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_us_kal_res.c -o ./build/$(T_DIR)/obj/lang/cmu_us_kal/cmu_us_kal_res.o
	$(CC) $(target)  -I./lang/usenglish -I./lang/cmulex  -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_us_kal_residx.c -o ./build/$(T_DIR)/obj/lang/cmu_us_kal/cmu_us_kal_residx.o
	$(CC) $(target)  -I./lang/usenglish -I./lang/cmulex  -I./include $(CFLAGS)     -c $(BUILD_DIR)/cmu_us_kal_ressize.c -o ./build/$(T_DIR)/obj/lang/cmu_us_kal/cmu_us_kal_ressize.o
# echo "making in doc ..."
# echo "making in tools ..."
	echo "linking ..."
#	mkdir -p "./bin"
	mkdir -p "./build/$(T_DIR)/lib"
# libflite_cmulex.a
	$(eval OBJDIR=./build/$(T_DIR)/obj/lang/cmulex)
	$(AR) -crvs ./build/$(T_DIR)/lib/libflite_cmulex.a $(OBJDIR)/cmu_lex_data.o $(OBJDIR)/cmu_lex_entries.o $(OBJDIR)/cmu_lex.o $(OBJDIR)/cmu_lts_model.o $(OBJDIR)/cmu_lts_rules.o $(OBJDIR)/cmu_postlex.o
#	$(RANLIB) ./build/$(T_DIR)/lib/libflite_cmulex.a
# libflite_cmu_us_kal.a
	$(eval OBJDIR=./build/$(T_DIR)/obj/lang/cmu_us_kal)
	$(AR) -crvs ./build/$(T_DIR)/lib/libflite_cmu_us_kal.a $(OBJDIR)/cmu_us_kal_diphone.o $(OBJDIR)/cmu_us_kal_lpc.o $(OBJDIR)/cmu_us_kal.o $(OBJDIR)/cmu_us_kal_residx.o $(OBJDIR)/cmu_us_kal_res.o $(OBJDIR)/cmu_us_kal_ressize.o 
#	$(RANLIB) ./build/$(T_DIR)/lib/libflite_cmu_us_kal.a
# libflite_usenglish.a
	$(eval OBJDIR=./build/$(T_DIR)/obj/lang/usenglish)
	$(AR) -crvs ./build/$(T_DIR)/lib/libflite_usenglish.a $(OBJDIR)/us_aswd.o $(OBJDIR)/us_dur_stats.o $(OBJDIR)/us_durz_cart.o $(OBJDIR)/usenglish.o $(OBJDIR)/us_expand.o $(OBJDIR)/us_f0lr.o $(OBJDIR)/us_f0_model.o $(OBJDIR)/us_ffeatures.o $(OBJDIR)/us_gpos.o $(OBJDIR)/us_int_accent_cart.o $(OBJDIR)/us_int_tone_cart.o $(OBJDIR)/us_nums_cart.o $(OBJDIR)/us_phoneset.o $(OBJDIR)/us_phrasing_cart.o $(OBJDIR)/us_pos_cart.o $(OBJDIR)/us_text.o 
#	$(RANLIB) ./build/$(T_DIR)/lib/libflite_usenglish.a
# libflite.a
	$(eval OBJDIR=./build/$(T_DIR)/obj/src)
	$(AR) -crvs ./build/$(T_DIR)/lib/libflite.a \
	$(OBJDIR)/speech/cst_lpcres.o $(OBJDIR)/speech/cst_track.o $(OBJDIR)/speech/cst_wave_io.o $(OBJDIR)/speech/cst_wave.o $(OBJDIR)/speech/cst_wave_utils.o $(OBJDIR)/speech/g721.o $(OBJDIR)/speech/g723_24.o $(OBJDIR)/speech/g723_40.o $(OBJDIR)/speech/g72x.o $(OBJDIR)/speech/rateconv.o \
	$(OBJDIR)/audio/audio.o $(OBJDIR)/audio/au_none.o $(OBJDIR)/audio/au_streaming.o \
	$(OBJDIR)/cg/cst_cg_map.o $(OBJDIR)/cg/cst_cg.o $(OBJDIR)/cg/cst_mlpg.o $(OBJDIR)/cg/cst_mlsa.o $(OBJDIR)/cg/cst_vc.o \
	$(OBJDIR)/hrg/cst_ffeature.o $(OBJDIR)/hrg/cst_item.o $(OBJDIR)/hrg/cst_relation.o $(OBJDIR)/hrg/cst_rel_io.o $(OBJDIR)/hrg/cst_utterance.o \
	$(OBJDIR)/lexicon/cst_lexicon.o $(OBJDIR)/lexicon/cst_lts.o $(OBJDIR)/lexicon/cst_lts_rewrites.o \
	$(OBJDIR)/regex/cst_regex.o $(OBJDIR)/regex/regexp.o $(OBJDIR)/regex/regsub.o \
	$(OBJDIR)/stats/cst_cart.o \
	$(OBJDIR)/synth/cst_ffeatures.o $(OBJDIR)/synth/cst_phoneset.o $(OBJDIR)/synth/cst_synth.o $(OBJDIR)/synth/cst_utt_utils.o $(OBJDIR)/synth/cst_voice.o $(OBJDIR)/synth/flite.o \
	$(OBJDIR)/utils/cst_alloc.o $(OBJDIR)/utils/cst_endian.o $(OBJDIR)/utils/cst_error.o $(OBJDIR)/utils/cst_features.o $(OBJDIR)/utils/cst_file_none.o $(OBJDIR)/utils/cst_mmap_none.o $(OBJDIR)/utils/cst_string.o $(OBJDIR)/utils/cst_tokenstream.o $(OBJDIR)/utils/cst_val_const.o $(OBJDIR)/utils/cst_val.o $(OBJDIR)/utils/cst_val_user.o $(OBJDIR)/utils/cst_wchar.o \
	$(OBJDIR)/wavesynth/cst_clunits.o $(OBJDIR)/wavesynth/cst_diphone.o $(OBJDIR)/wavesynth/cst_reflpc.o $(OBJDIR)/wavesynth/cst_sigpr.o $(OBJDIR)/wavesynth/cst_sts.o $(OBJDIR)/wavesynth/cst_units.o
#	$(RANLIB) ./build/$(T_DIR)/lib/libflite.a
	echo "making in main ..."
	mkdir -p "./build/$(T_DIR)/obj/main"
	$(eval BUILD_DIR=./main)
	cd main; ../tools/make_lang_list "usenglish cmulex"
	cd main; ../tools/make_voice_list "cmu_us_kal"
	$(CC) $(target) $(CFLAGS)      -I./include  -c -o $(BUILD_DIR)/flite_wasm.o $(BUILD_DIR)/flite_wasm.c
	$(CC) $(target) $(CFLAGS)      -I./include  -c -o $(BUILD_DIR)/flite_lang_list.o $(BUILD_DIR)/flite_lang_list.c
	$(CC) $(target) $(CFLAGS)      -I./include  -c -o $(BUILD_DIR)/flite_voice_list.o $(BUILD_DIR)/flite_voice_list.c
#	$(CC) $(target) $(CFLAGS_WASM)     -o ./bin/flite.wasm $(BUILD_DIR)/flite_wasm.o $(BUILD_DIR)/flite_lang_list.o $(BUILD_DIR)/flite_voice_list.o -L./build/$(T_DIR)/lib -lflite_patch_stdlib -lflite_patch_ctype -lflite_patch_string -lflite_patch_stdio -lflite_cmu_us_kal -lflite_usenglish -lflite_cmulex -lflite
	echo "linking flite_wasm ..."
# libfilte_wasm.a
	$(AR) -crvs ./build/$(T_DIR)/lib/libflite_wasm.a $(BUILD_DIR)/flite_wasm.o $(BUILD_DIR)/flite_lang_list.o $(BUILD_DIR)/flite_voice_list.o
#	$(RANLIB) ./build/$(T_DIR)/lib/libflite_wasm.a
	rm ./main/*.o