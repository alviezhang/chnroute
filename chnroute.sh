#!/bin/sh

OUTPUT_FILEPATH=chnroute.txt
LOCAL_ADDR_ENABLED=false
MERGE_FILE=
SLIENT=

help() {
    echo " Usage: $0 [-l] [-m merge.txt] [output.txt]"
    echo " -l: add local domain ip address"
    echo " -m: merge file from merge.txt"
    echo " -s: slient mode"
    echo "output.txt: chnroute output file, default is 'chnroute.txt'"
}

while getopts ":m: :h :l :s" opt; do
    case $opt in
        l)
            LOCAL_ADDR_ENABLED=true
            ;;
        h)
            help
            ;;
        s)
            SLIENT="-s"
            ;;
        m)
            MERGE_FILE=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
        *)
            help
            ;;
    esac
done

shift $((OPTIND-1))

if [ ! -z "$@" ]; then
    OUTPUT_FILEPATH=$@
fi

curl $SLIENT 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > $OUTPUT_FILEPATH

if [ ! -z "$MERGE_FILE" ]; then
    cat $MERGE_FILE >> $OUTPUT_FILEPATH
fi

if [ $LOCAL_ADDR_ENABLED = "true" ]; then
    echo "10.0.0.0/8" >> $OUTPUT_FILEPATH
    echo "172.16.0.0/12" >> $OUTPUT_FILEPATH
    echo "192.168.0.0/16" >> $OUTPUT_FILEPATH
fi

