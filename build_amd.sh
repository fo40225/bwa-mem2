for i in k8 k8-sse3 amdfam10 bdver1 bdver2 bdver3 bdver4 btver1 btver2 znver1 znver2 znver3 znver4
do
  make clean
  arch=" -march=${i} " make -j $(nproc) --trace
  mv bwa-mem2 bwa-mem2.${i}
done

make clean
make -j $(nproc) --trace
