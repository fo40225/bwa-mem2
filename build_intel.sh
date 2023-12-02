for i in SANDYBRIDGE IVYBRIDGE HASWELL BROADWELL SKYLAKE KABYLAKE AMBERLAKE WHISKEYLAKE COFFEELAKE ICELAKE-CLIENT ROCKETLAKE ALDERLAKE SKYLAKE-AVX512 CASCADELAKE COOPERLAKE CANNONLAKE ICELAKE-SERVER TIGERLAKE SAPPHIRERAPIDS SILVERMONT GOLDMONT GOLDMONT-PLUS TREMONT
do
  make clean
  arch=" -x${i} " make -j $(nproc) --trace
  mv bwa-mem2 bwa-mem2.${i}
done
for i in nocona core2 penryn nehalem westmere raptorlake meteorlake graniterapids emeraldrapids bonnell gracemont sierraforest grandridge
do
  make clean
  arch=" -march=${i} " make -j $(nproc) --trace
  mv bwa-mem2 bwa-mem2.${i}
done

make clean
make -j $(nproc) --trace
