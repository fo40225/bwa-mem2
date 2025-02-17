##/*************************************************************************************
##                           The MIT License
##
##   BWA-MEM2  (Sequence alignment using Burrows-Wheeler Transform),
##   Copyright (C) 2019  Intel Corporation, Heng Li.
##
##   Permission is hereby granted, free of charge, to any person obtaining
##   a copy of this software and associated documentation files (the
##   "Software"), to deal in the Software without restriction, including
##   without limitation the rights to use, copy, modify, merge, publish,
##   distribute, sublicense, and/or sell copies of the Software, and to
##   permit persons to whom the Software is furnished to do so, subject to
##   the following conditions:
##
##   The above copyright notice and this permission notice shall be
##   included in all copies or substantial portions of the Software.
##
##   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
##   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
##   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
##   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
##   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
##   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
##   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##   SOFTWARE.
##
##Contacts: Vasimuddin Md <vasimuddin.md@intel.com>; Sanchit Misra <sanchit.misra@intel.com>;
##                                Heng Li <hli@jimmy.harvard.edu> 
##*****************************************************************************************/

ifneq ($(portable),)
	STATIC_GCC=-static-libgcc -static-libstdc++
endif

EXE=		bwa-mem2

# Intel oneAPI DPC++/C++ Compiler
#CXX=		icpx

# AMD Optimizing C/C++ Compilers
#CXX=		clang++

ifeq ($(CXX), icpx)
CC=icx
else ifeq ($(CXX), clang++)
CC=clang
else ifeq ($(CXX), g++)
CC=gcc
endif

ARCH_FLAGS= -march=x86-64
MEM_FLAGS=	-DSAIS=1
CPPFLAGS+=	-DENABLE_PREFETCH -DV17=1 -DMATE_SORT=0 $(MEM_FLAGS) 
INCLUDES=   -Isrc -Iext/safestringlib/include
LIBS=		-lpthread -lm -lz -L. -Lext/safestringlib -lsafestring $(STATIC_GCC)
OBJS=		src/fastmap.o src/bwtindex.o src/utils.o src/memcpy_bwamem.o src/kthread.o \
			src/kstring.o src/ksw.o src/bntseq.o src/bwamem.o src/profiling.o src/bandedSWA.o \
			src/FMI_search.o src/read_index_ele.o src/bwamem_pair.o src/kswv.o src/bwa.o \
			src/bwamem_extra.o src/kopen.o

SAFE_STR_LIB=    ext/safestringlib/libsafestring.a

ifeq ($(arch),sse2)
	ARCH_FLAGS=-mprefer-vector-width=128 -march=x86-64
else ifeq ($(arch),sse42)
	ifeq ($(CXX), icpx)
		ARCH_FLAGS=-mprefer-vector-width=128 -xSSE4.2
	else ifeq ($(CXX), clang++)
		ARCH_FLAGS=-mprefer-vector-width=128 -mtune=bdver1 -msse3 -mssse3 -msse4 -msse4.1 -msse4.2 -mcrc32 -mcx16 -mpopcnt -msahf
	else
# nehalem && bdver1 (x86-64-v2)
		ARCH_FLAGS=-mprefer-vector-width=128 -msse3 -mssse3 -msse4 -msse4.1 -msse4.2 -mcrc32 -mcx16 -mpopcnt -msahf
	endif
else ifeq ($(arch),avx)
	ifeq ($(CXX), icpx)
		ARCH_FLAGS=-mprefer-vector-width=256 -xAVX
	else ifeq ($(CXX), clang++)
		ARCH_FLAGS=-mprefer-vector-width=256 -mtune=bdver1 -mavx -mcrc32 -mcx16 -mpclmul -mpopcnt -msahf -mxsave
	else	
# sandybridge && bdver1
		ARCH_FLAGS=-mprefer-vector-width=256 -mavx -mcrc32 -mcx16 -mpclmul -mpopcnt -msahf -mxsave
	endif
else ifeq ($(arch),avx2)
	ifeq ($(CXX), icpx)
		ARCH_FLAGS=-mprefer-vector-width=256 -xCORE-AVX2
	else ifeq ($(CXX), clang++)
		ARCH_FLAGS=-mprefer-vector-width=256 -mtune=bdver4 -mavx -mavx2 -mbmi -mbmi2 -mcrc32 -mcx16 -mf16c -mfma -mfsgsbase -mlzcnt -mmovbe -mpclmul -mpopcnt -mrdrnd -msahf -mxsave -mxsaveopt
	else	
# haswell && bdver4 (x86-64-v3)
		ARCH_FLAGS=-mprefer-vector-width=256 -mavx -mavx2 -mbmi -mbmi2 -mcrc32 -mcx16 -mf16c -mfma -mfsgsbase -mlzcnt -mmovbe -mpclmul -mpopcnt -mrdrnd -msahf -mxsave -mxsaveopt
	endif
else ifeq ($(arch),avx512)
	ifeq ($(CXX), icpx)
		ARCH_FLAGS=-mprefer-vector-width=512 -xCORE-AVX512
	else ifeq ($(CXX), clang++)
		ARCH_FLAGS=-mprefer-vector-width=512 -mtune=znver4 -mavx512f -mavx512cd -mavx512dq -mavx512bw -mavx512vl -madx -maes -mavx -mavx2 -mbmi -mbmi2 -mclflushopt -mclwb -mcrc32 -mcx16 -mf16c -mfma -mfsgsbase -mlzcnt -mmovbe -mpclmul -mpopcnt -mprfchw -mrdrnd -mrdseed -msahf -mxsave -mxsavec -mxsaveopt -mxsaves
	else	
# skylake-avx512 && znver4 (x86-64-v4)
		ARCH_FLAGS=-mprefer-vector-width=512 -mavx512f -mavx512cd -mavx512dq -mavx512bw -mavx512vl -madx -maes -mavx -mavx2 -mbmi -mbmi2 -mclflushopt -mclwb -mcrc32 -mcx16 -mf16c -mfma -mfsgsbase -mlzcnt -mmovbe -mpclmul -mpopcnt -mprfchw -mrdrnd -mrdseed -msahf -mxsave -mxsavec -mxsaveopt -mxsaves
	endif
else ifeq ($(arch),native)
	ifeq ($(CXX), icpx)
		ARCH_FLAGS=-xHOST
	else
		ARCH_FLAGS=-march=native
	endif

else ifneq ($(arch),)
# To provide a different architecture flag like -march=znver4 or -xSAPPHIRERAPIDS.
	ARCH_FLAGS=$(arch)
else
myall:multi
endif

ifneq ($(CXX), g++)
CXXFLAGS+= -fprofile-sample-use=bwa-mem2-clang-sample.prof -fsample-profile-use-profi -fprofile-instr-use=bwa-mem2-clang-instr.prof 
endif

CXXFLAGS+= -flto -O3 -std=c++14 -fpermissive $(ARCH_FLAGS)

#ifeq ($(CXX), icpx)
#CXXFLAGS+= -fprofile-sample-use=bwa-mem2.freq.prof -mllvm -unpredictable-hints-file=bwa-mem2.misp.prof
#endif

.PHONY:all clean depend multi
.SUFFIXES:.cpp .o

.cpp.o:
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(INCLUDES) $< -o $@

all:$(EXE)

multi:
	rm -f src/*.o $(BWA_LIB); cd ext/safestringlib/ && $(MAKE) clean;
	$(MAKE) arch=sse2    EXE=bwa-mem2.sse2    CXX=$(CXX) all
	rm -f src/*.o $(BWA_LIB); cd ext/safestringlib/ && $(MAKE) clean;
	$(MAKE) arch=sse42    EXE=bwa-mem2.sse42    CXX=$(CXX) all
	rm -f src/*.o $(BWA_LIB); cd ext/safestringlib/ && $(MAKE) clean;
	$(MAKE) arch=avx    EXE=bwa-mem2.avx    CXX=$(CXX) all
	rm -f src/*.o $(BWA_LIB); cd ext/safestringlib/ && $(MAKE) clean;
	$(MAKE) arch=avx2   EXE=bwa-mem2.avx2     CXX=$(CXX) all
	rm -f src/*.o $(BWA_LIB); cd ext/safestringlib/ && $(MAKE) clean;
	$(MAKE) arch=avx512 EXE=bwa-mem2.avx512bw CXX=$(CXX) all
	$(CXX) -Wall -O3 src/runsimd.cpp -Iext/safestringlib/include -Lext/safestringlib/ -lsafestring $(STATIC_GCC) -o bwa-mem2


$(EXE):$(OBJS) $(SAFE_STR_LIB) src/main.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS) src/main.o $(OBJS) $(LIBS) -o $@

$(SAFE_STR_LIB):
	cd ext/safestringlib/ && $(MAKE) clean && $(MAKE) CC=$(CC) directories libsafestring.a

clean:
	rm -fr src/*.o $(BWA_LIB) $(EXE) bwa-mem2.sse2 bwa-mem2.sse42 bwa-mem2.avx bwa-mem2.avx2 bwa-mem2.avx512bw
	cd ext/safestringlib/ && $(MAKE) clean

depend:
	(LC_ALL=C; export LC_ALL; makedepend -Y -- $(CXXFLAGS) $(CPPFLAGS) -I. -- src/*.cpp)

# DO NOT DELETE

src/FMI_search.o: src/FMI_search.h src/bntseq.h src/read_index_ele.h
src/FMI_search.o: src/utils.h src/macro.h src/bwa.h src/bwt.h src/sais.h
src/bandedSWA.o: src/bandedSWA.h src/macro.h
src/bntseq.o: src/bntseq.h src/utils.h src/macro.h src/kseq.h src/khash.h
src/bwa.o: src/bntseq.h src/bwa.h src/bwt.h src/macro.h src/ksw.h src/utils.h
src/bwa.o: src/kstring.h src/kvec.h src/kseq.h
src/bwamem.o: src/bwamem.h src/bwt.h src/bntseq.h src/bwa.h src/macro.h
src/bwamem.o: src/kthread.h src/bandedSWA.h src/kstring.h src/ksw.h
src/bwamem.o: src/kvec.h src/ksort.h src/utils.h src/profiling.h
src/bwamem.o: src/FMI_search.h src/read_index_ele.h src/kbtree.h
src/bwamem_extra.o: src/bwa.h src/bntseq.h src/bwt.h src/macro.h src/bwamem.h
src/bwamem_extra.o: src/kthread.h src/bandedSWA.h src/kstring.h src/ksw.h
src/bwamem_extra.o: src/kvec.h src/ksort.h src/utils.h src/profiling.h
src/bwamem_extra.o: src/FMI_search.h src/read_index_ele.h
src/bwamem_pair.o: src/kstring.h src/bwamem.h src/bwt.h src/bntseq.h
src/bwamem_pair.o: src/bwa.h src/macro.h src/kthread.h src/bandedSWA.h
src/bwamem_pair.o: src/ksw.h src/kvec.h src/ksort.h src/utils.h
src/bwamem_pair.o: src/profiling.h src/FMI_search.h src/read_index_ele.h
src/bwamem_pair.o: src/kswv.h
src/bwtindex.o: src/bntseq.h src/bwa.h src/bwt.h src/macro.h src/utils.h
src/bwtindex.o: src/FMI_search.h src/read_index_ele.h
src/fastmap.o: src/fastmap.h src/bwa.h src/bntseq.h src/bwt.h src/macro.h
src/fastmap.o: src/bwamem.h src/kthread.h src/bandedSWA.h src/kstring.h
src/fastmap.o: src/ksw.h src/kvec.h src/ksort.h src/utils.h src/profiling.h
src/fastmap.o: src/FMI_search.h src/read_index_ele.h src/kseq.h
src/kstring.o: src/kstring.h
src/ksw.o: src/ksw.h src/macro.h
src/kswv.o: src/kswv.h src/macro.h src/ksw.h src/bandedSWA.h
src/kthread.o: src/kthread.h src/macro.h src/bwamem.h src/bwt.h src/bntseq.h
src/kthread.o: src/bwa.h src/bandedSWA.h src/kstring.h src/ksw.h src/kvec.h
src/kthread.o: src/ksort.h src/utils.h src/profiling.h src/FMI_search.h
src/kthread.o: src/read_index_ele.h
src/main.o: src/main.h src/kstring.h src/utils.h src/macro.h src/bandedSWA.h
src/main.o: src/profiling.h
src/profiling.o: src/macro.h
src/read_index_ele.o: src/read_index_ele.h src/utils.h src/bntseq.h
src/read_index_ele.o: src/macro.h
src/utils.o: src/utils.h src/ksort.h src/kseq.h
src/memcpy_bwamem.o: src/memcpy_bwamem.h
