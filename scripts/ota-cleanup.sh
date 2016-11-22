#!/bin/bash

case "$1" in
  -a|--all)
    cd ..
    cat ota.list | while read line; do
      if [[ $line =~ ^[0-9]+ ]]; then
        ID=$(echo "$line" | cut -d, -f2)
        TOKEN=$(echo "$line" | cut -d, -f3)
        appsendr destroy ${ID} ${TOKEN}
        sed -i "/${line}/d" ota.list
      fi
    done
    if [[ -n $(git diff ota.list) ]]; then
      git add ota.list
      git commit -m "ran cleanup script"
      git push
    fi
    ;;
  -b|--build)
    if [[ $2 =~ ^[0-9,]+$ ]]; then
      cd ..
      IFS=$','
      BUILDNUMBER=$2
      for i in ${BUILDNUMBER}; do
        if grep -wq ${i} ota.list; then
          ID=$(grep -w ${i} ota.list | cut -d, -f2)
          TOKEN=$(grep -w ${i} ota.list | cut -d, -f3)
          appsendr destroy ${ID} ${TOKEN}
          sed -i "/^${i},/d" ota.list
        fi
      done
      unset IFS
      if [[ -n $(git diff ota.list) ]]; then
        git add ota.list
        git commit -m "ran cleanup script"
        git push
      fi
    elif [[ $2 =~ ^[0-9]+-[0-9]+$ ]]; then
      cd ..
      FIRST=$(echo "$2" | cut -d- -f1)
      LAST=$(echo "$2" | cut -d- -f2)
      for i in `seq ${FIRST} ${LAST}`; do
        if grep -wq ${i} ota.list; then
          ID=$(grep -w ${i} ota.list | cut -d, -f2)
          TOKEN=$(grep -w ${i} ota.list   | cut -d, -f3)
          appsendr destroy ${ID} ${TOKEN}
          sed -i "/^${i},/d" ota.list
        fi
      done
      if [[ -n $(git diff ota.list) ]]; then
        git add ota.list
        git commit -m "ran cleanup script"
        git push
      fi
    else
      echo "Option accepts a build number, comma-separated build numbers or a range of build numbers only"
    fi
    ;;
  *)
    cat <<EOF
OTA cleanup script - destroys beta iOS applications hosted in ota.io

Usage:
./ota-cleanup.sh [option] [argument]

Options:
-a (--all)   - Destroys all builds listed
-b (--build) - Destroys a specific build number. Accepts only a build number, comma-separated build numbers or a range of build numbers
EOF
    ;;
esac

