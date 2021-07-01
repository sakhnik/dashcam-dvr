#!/bin/bash -x

set -o pipefail

storage=/var/local/dvr
duration=60000
capacity_megs=20000

export PATH=/opt/vc/bin:$PATH

mkdir -p "$storage"
cd "$storage"

fname_to_num()
{
    num=$1
    num=${num/.mp4/}
    num=$((10#$num))
    echo $num
}

num_to_fname()
{
    printf "%06d.mp4" $1
}

# There is no real time clock available, so we shouldn't rely
# on timestamps between reboots. Instead, we'll number the clips.
last=$(ls -v | tail -1)
if [[ "$last" ]]; then
    last=$(fname_to_num $last)
    if [[ "$last" -gt 999000 ]]; then
        # To simplify dealing with big numbers, recycling etc,
        # let's just shift all the clips to the beginning of the range.
        first=$(fname_to_num $(ls -v | head -1))
        ls -v | while read fname; do
            num=$(fname_to_num $fname)
            num=$((num - first))
            mv $fname $(num_to_fname $num)
        done
        last=$((last - first))
    fi
    last=$(( (last / 1000 + 2) * 1000 ))
else
    last=0
fi

(
    while true; do
        size_megs=$(du -ms | awk '{print $1}')
        if [[ "$size_megs" -gt $capacity_megs ]]; then
            rm "$(ls -v | head -1)"
            continue
        fi
        sleep $((duration / 1000))
    done

) &

cleanup()
{
    kill %1
    wait
}

trap cleanup EXIT

while true; do
    fname=$(num_to_fname $last)
    last=$((++last))
    raspivid -t $duration -o - | \
        ffmpeg -hide_banner -loglevel error \
	    -i - -c:v copy \
            -movflags frag_keyframe+empty_moov \
            -f mp4 $fname
done
