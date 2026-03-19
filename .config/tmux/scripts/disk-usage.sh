#!/bin/sh
diskutil info / | awk -F'[:(]' '
  /Container Total Space/{split($3,a," "); t=a[1]}
  /Container Free Space/{split($3,a," "); f=a[1]}
  END{
    g=1000000000; u=t-f; p=int(u*10/t); bar=""
    for(i=0;i<10;i++) bar=bar (i<p?"█":"░")
    pct=f*100/t
    printf " 📦 %s %.2fGB free | %.2fGB of %.2fGB used", bar, f/g, u/g, t/g
  }'
