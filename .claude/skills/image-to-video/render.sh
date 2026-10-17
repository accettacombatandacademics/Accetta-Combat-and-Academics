#!/usr/bin/env bash
# Usage: render.sh <image> <output.mp4> [style] [focus_x] [focus_y]
#   style:   reel (9:16, drift then impact zoom + shake, default) | pushin (3:4, slow push-in)
#   focus_x/focus_y: point to zoom toward, as fractions of width/height (default 0.5 0.5)
set -euo pipefail
IMG=$1; OUT=$2; STYLE=${3:-reel}; FX=${4:-0.5}; FY=${5:-0.5}

# Upscale to a fixed 3000px width (keeping aspect) so zoompan has room to zoom without blur.
PRE="scale=3000:-2"

case "$STYLE" in
  reel)
    # 75 frames of slow drift, snap to 1.4x over 6 frames, decaying shake after the hit.
    VF="$PRE,zoompan=z='if(lt(on,75),1.0+0.06*on/75,1.06+0.34*min(1,(on-75)/6))':\
x='max(0,min(iw-iw/zoom,iw*$FX-iw/zoom/2+if(gte(on,75),40*sin(on*2.1)*exp(-(on-75)/8),0)))':\
y='max(0,min(ih-ih/zoom,ih*$FY-ih/zoom/2+if(gte(on,75),30*cos(on*2.7)*exp(-(on-75)/8),0)))':\
d=165:s=1080x1920:fps=30,eq=contrast=1.08:saturation=1.15,\
fade=in:st=0:d=0.4,fade=out:st=5.0:d=0.5,format=yuv420p"
    DUR=5.5 ;;
  pushin)
    VF="$PRE,zoompan=z='1+0.25*on/180':\
x='max(0,min(iw-iw/zoom,iw*$FX-iw/zoom/2))':\
y='max(0,min(ih-ih/zoom,ih*$FY-ih/zoom/2))':\
d=180:s=1080x1440:fps=30,fade=in:st=0:d=0.5,fade=out:st=5.5:d=0.5,format=yuv420p"
    DUR=6 ;;
  *) echo "unknown style: $STYLE (use reel or pushin)" >&2; exit 1 ;;
esac

ffmpeg -y -loglevel error -loop 1 -i "$IMG" -vf "$VF" -t "$DUR" -c:v libx264 -crf 20 -movflags +faststart "$OUT"
echo "$OUT"
