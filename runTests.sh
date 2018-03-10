#!/bin/bash
mathoid=`pwd`/node_modules/mathoid/server.js
if [ -f  $mathoid ]; then
   echo "Running mathoid from $mathoid"
else
   echo "$mathoid not found."
   echo "install mathoid via 'npm i mathoid'"
   exit
fi

for file in `pwd`/config/*.yaml
do
    # from https://stackoverflow.com/questions/3362920/get-just-the-filename-from-a-path-in-a-bash-script
    xbase=${file##*/}
    xpref=${xbase%.*}
    echo "starting mathoid with config $xpref"
    $mathoid -c $file  >./results/mathoid-$xpref.log &
    echo "wait for mathoid to start"
    sleep 2s
    for sample in `pwd`/data/*.txt
    do
        sbase=${sample##*/}
        spref=${sbase%.*}
        echo "processing $sample"
        curl --silent -d "@$sample" localhost:10044/svg > ./results/svg-${spref}-${xpref}.svg
        curl --silent -d "@$sample" localhost:10044/png > ./results/png-${spref}-${xpref}.png
    done
    kill %
done
kill %%