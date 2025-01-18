for i in SANDYBRIDGE IVYBRIDGE HASWELL BROADWELL SKYLAKE KABYLAKE AMBERLAKE WHISKEYLAKE COFFEELAKE ICELAKE-CLIENT ROCKETLAKE ALDERLAKE SKYLAKE-AVX512 CASCADELAKE COOPERLAKE CANNONLAKE ICELAKE-SERVER TIGERLAKE SAPPHIRERAPIDS SILVERMONT GOLDMONT GOLDMONT-PLUS TREMONT
do
  make clean
  CXX="icpx" arch=" -x${i} " make -j $(nproc) --trace
  mv bwa-mem2 bwa-mem2.${i}
done
for i in nocona core2 penryn nehalem westmere sandybridge ivybridge haswell broadwell skylake skylake-avx512 cascadelake cooperlake cannonlake icelake-client rocketlake icelake-server tigerlake sapphirerapids alderlake raptorlake meteorlake graniterapids emeraldrapids graniterapids-d bonnell silvermont atom_sse4_2_movbe goldmont goldmont_plus tremont sierraforest grandridge
do
  make clean
  CXX="icpx" arch=" -march=${i} " make -j $(nproc) --trace
  mv bwa-mem2 bwa-mem2.${i}
done

make clean
make -j $(nproc) --trace
