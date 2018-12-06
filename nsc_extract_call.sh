#!/bin/sh
######################################################################################
#
# Desc: Extract a single call from several pcap files
#
# Author: Marlon A
#
# VERSION: 1.0
######################################################################################
TMP="/tmp" # working directory {default: /tmp}
PCAPDIR=$PWD # directory where pcap files to be extracted are located {default: `pwd}
TMPFILES="__RTP__" #temporary files name {defaul: __RTP__ }


#######################
chk_if_running()
#######################
{
ps aux | grep $1|grep -v grep 1>/dev/null
is_running=$?
while [ $is_running -eq 0 ]
do
echo -n "."
ps aux | grep $1|grep -v grep 1>/dev/null
is_running=$?
sleep 1
done
echo -ne " Done !\n"
}

###########
get_sipid()
##########
{
echo  -n "Please enter SIP Call-ID  : "
read  -e SIPID
}
##########
get_rtpp()
##########
{
echo  -n "Please Enter RTP Port \#1 : "
read -e RTPP1
echo -n  "Please Enter RTP Port \#2 : "
read -e RTPP2
}

########
log_me()
########
{
LVL=$2
MSG=$1
LLN=$3
case $LVL in
"d")
if [ -z $LLN ]
then
	echo -e "[`date`](\e[32mDEBUG\e[0m) $1"
else
	echo -en "[`date`](\e[32mDEBUG\e[0m) $1"
fi
;;
"w")
if [ -z $LLN ]
then
	echo -e "[`date`](\e[33mWARNING\e[0m) $1"
else
	echo -ne "[`date`](\e[33mWARNING\e[0m) $1"
fi
;;
"e")
if [ -z $LLN ]
	then
	echo -e "[`date`](\e[31mERROR\e[0m) $1"
else
	echo -ne "[`date`](\e[31mERROR\e[0m) $1"
fi
;;
*)
if [ -z $LLN ]
then
	echo -e "[`date`](\e[34mINFO\e[0m) $1"
else
	echo -ne "[`date`](\e[34mINFO\e[0m) $1"
fi
;;
esac
}
##########
run_help()
#########
{
echo -e "
Script can be run with arguments or the script will prompt for what he needs.\n

 -s : SIP dialogue Call-ID as argument
 -t : RTP #1 port number (order does not matter)
 -f : RTP #2 port number (order does not matter)
 -d : PCAP directory: where pcap files are located.
 -w : Working directory (where files will be extracted to minimum 1GB).
\n\n
Example: `basename $0` -s 445043434bb4575b5c2ee9bc3b7c72e6 -f 14176 -t 18728
\n
SIP Header INFO (\e[32mGreen\e[0m = SIP CALLERID ,\e[33mYellow\e[0m = RTP 1 and \e[34mDarkBlue\e[0m = RTP 2)
\n
INVITE sip:1111@172.18.10.254 SIP/2.0
Via: SIP/2.0/UDP 172.18.16.209:5060;branch=z9hG4bK15e8479c;rport
Max-Forwards: 70
From:  <sip:2222@172.18.16.209>;tag=as32836182
To: <sip:1111@172.18.10.254>
Contact: <sip:3182314378@172.18.16.209:5060>
Call-ID: \e[32m445043434bb4575b5c2ee9bc3b7c72e6\e[0m@172.18.16.209:5060
CSeq: 102 INVITE
User-Agent: NobleSIPhony
Date: Tue, 13 Feb 2018 16:07:40 GMT
Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, SUBSCRIBE, NOTIFY, INFO, PUBLISH
Supported: replaces, timer
Content-Type: application/sdp
Content-Length: 277

v=0
o=root 1092854350 1092854350 IN IP4 172.18.16.209
s=NobleSIPhony
c=IN IP4 172.18.16.209
t=0 0
m=audio \e[33m14176\e[0m RTP/AVP 18 0 101                 \e[31m <<-----------------------------------\e[0m
a=rtpmap:18 G729/8000
a=fmtp:18 annexb=no
a=rtpmap:0 PCMU/8000
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-16
a=ptime:20
a=sendrecv
\n
<--- SIP read from UDP:172.18.10.254:5060 --->
SIP/2.0 183 Session Progress
Via: SIP/2.0/UDP 172.18.16.209:5060;branch=z9hG4bK15e8479c;rport=5060
Record-Route: <sip:sansay1857354317rdb11766@172.18.10.254:5060;lr;transport=udp>
To: <sip:2222@172.18.10.254>;tag=sansay1857354317rdb11766
From:  <sip:1111@172.18.16.209>;tag=as32836182
Call-ID: \e[32m445043434bb4575b5c2ee9bc3b7c72e6\e[0m@172.18.16.209:5060
CSeq: 102 INVITE
Contact: <sip:13186587193@172.18.10.254:5060>
Content-Type: application/sdp
Content-Length: 250
\n
v=0
o=Sansay-VSXi 188 1 IN IP4 172.18.10.254
s=Session Controller
c=IN IP4 172.18.10.230
t=0 0
m=audio \e[34m18728\e[0m RTP/AVP 18 101 		 \e[31m <<-----------------------------------\e[0m
a=rtpmap:18 G729/8000
a=fmtp:18 annexb=no
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-15
a=sendrecv
a=ptime:20
\n
<--- SIP read from UDP:172.18.10.254:5060 --->
SIP/2.0 200 OK
Via: SIP/2.0/UDP 172.18.16.209:5060;branch=z9hG4bK15e8479c;rport=5060
Record-Route: <sip:sansay1857354317rdb11766@172.18.10.254:5060;lr;transport=udp>
To: <sip:2222@172.18.10.254>;tag=sansay1857354317rdb11766
From:  <sip:1111@172.18.16.209>;tag=as32836182
Call-ID: \e[32m445043434bb4575b5c2ee9bc3b7c72e6\e[0m@172.18.16.209:5060
CSeq: 102 INVITE
Contact: <sip:13186587193@172.18.10.254:5060>
Content-Type: application/sdp
Content-Length: 250
\n
v=0
o=Sansay-VSXi 188 1 IN IP4 172.18.10.254
s=Session Controller
c=IN IP4 172.18.10.230
t=0 0
m=audio \e[34m18728\e[0m RTP/AVP 18 101
a=rtpmap:18 G729/8000
a=fmtp:18 annexb=no
a=rtpmap:101 telephone-event/8000
a=fmtp:101 0-15
a=sendrecv
a=ptime:20\n
"|more
exit 0
}
#############
check_depen()
#############
{
which mergecap tshark >/dev/null 2>&1
mexit=$?
if [ $mexit -ne 0  ]
    then
        log_me "Missing dependencies (tshar/mergecap) " w
        exit 1
fi
}
PS3="ENTER 1/2/3: "

#############
main_menu()
###########
{
check_depen
while getopts s:f:t:h opts; do
	case ${opts} in
	s)
		SIPID=$OPTARG
	;;
	f)
		RTPP1=$OPTARG
	;;
	t)
		RTPP2=$OPTARG
	;;
	w)
		TMP=$OPTARG
	;;
	d)
		PCAPDIR=$OPTARG
	;;
	/?|h|:|-help)
		HELP=Y
	;;
	*)
		log_me "Unknown flag \"$opts\" " w
		log_me "run with -h flag for help"
		exit 1
    ;;
    esac
done

if [ -z $SIPID ] 
	then
    log_me   "Missing Argument:  Example for sip only: " w
    log_me   "`basename $0` -s 445043434bb4575b5c2ee9bc3b7c72e6  (run \"`basename $0` -h\" for help)" 
    log_me   "Do  you want to extract SIP ONLY(1) or SIP and RTP (2)  or extra RTP for existing SIP.pcap:[enter 1 or 2 or 3]: " i
    imenu=("SIP dialog extract only" "SIP dialogue and RTP stream " "I have no idea what I am doing here ")
	select iopt in "${imenu[@]}"; do
		if [ "$iopt" = "SIP dialog extract only" ]
			then
			get_sipid
			check_working_dir "init"
			extract_pcap SIP
			merge_pcaps
			exit 0 
		elif [ "$iopt" = "SIP dialogue and RTP stream " ]
			then
			get_sipid
			get_rtpp
			check_working_dir "init"
			extract_pcap SIP_RTP
			imerge_pcaps
			exit 0 
		elif [ "$iopt" = "I have no idea what I am doing here " ]
			then
			log_me "Run `basename $0 ` -h "
			exit 1
		else
			echo  "That's not a valid option!"
			exit 10
		fi
	done

elif [ ! -z $HELP ]
	then
	run_help 
	exit 0
elif [ ! -z $SIPID ] && [ ! -z $RTPP1 ] && [ ! -z $RTPP2 ]
	then
	check_working_dir "init"
	extract_pcap SIP_RTP
	merge_pcaps
elif [ ! -z $SIPID ] && [  -z $RTPP1 ] && [  -z $RTPP2 ]
	then
	check_working_dir "init"
	extract_pcap SIP
	merge_pcaps
else
log_me   "Do  you want to extract SIP ONLY(1) or SIP and RTP (2)  or extra RTP for existing SIP.pcap:[enter 1 or 2 or 3]: " i
imenu=("SIP dialog extract only" "SIP dialogue and RTP stream " "I have no idea what I am doing here ")
	select iopt in "${imenu[@]}"; do
		if [ "$iopt" = "SIP dialog extract only" ]
			then
			get_sipid
			check_working_dir "init"
			extract_pcap SIP
		elif [ "$iopt" = "SIP dialogue and RTP stream " ]
			then
			get_sipid
			get_rtpp
			check_working_dir "init"
			extract_pcap SIP_RTP
		elif [ "$iopt" = "I have no idea what I am doing here " ]
			then
			log_me "Run `basename $0 ` --help "
			exit 1
		else
			echo  "That's not a valid option!"
            exit 10
        fi
    done
fi
exit 0
}

###################
check_working_dir()
###################
{
PPT=$1
PERT=`/bin/df -h $TMP|awk  'NR>1 {gsub(/%/,""); {print $5}}'`
dstSIZE=`/bin/df -m $TMP|awk 'NR>1 {gsub(/%/,""); {print $4}}'`
case $PPT in
"initial"|"init")
	if [ ${PERT} -lt "95" ] && [ $dstSIZE -gt "1000" ]
		then
		echo
		log_me "\nWorking directory is ${TMP}/, Always make sure there is enough space" w
		printf "\n\n"
		`which df` -h | fgrep "$TMP"
		printf "\n"
		echo "CTRL+C to exit, PRESS <ENTER> To Continue"
		read
	else
		log_me "-->> $TMP percentage is at ${PERT}% BUT only has ${dstSIZE}mb(limit=1000mb),  exiting because it is not safe to extract files to $TMP, try changing directory with -w \"new_working_directory\".." w
		exit 1
	fi
;;
"recheck")
	if [ ${PERT} -lt "95" ] && [ $dstSIZE -gt "1000" ]
		then
		log_me "check_working_dir() space is fine, continuing!"
	else
		log_me "-->> $TMP percentage is at ${PERT}% BUT only has ${dstSIZE}mb(limit=1000mb),  exiting because it is not safe to continue to extract files to $TMP, try changing directory with -w \"new_working_directory\".." w
		exit 1
	fi

;;
*)
	log_me "check_working_dir() Unknown error exiting...."
	exit 10
;;
esac
}

##############
extract_pcap()
##############
{

EXT_TYPE=$1
case $EXT_TYPE in
SIP)
handle_pcap_files
for file in `ls *.pcap`
do
	FILE="$TMP/${TMPFILES}_$$"
	log_me "Filter ==  \"sip.Call-ID contains $SIPID \"" "d"
	log_me "Extracting pcap file $file to $FILE " i t
	tshark -r $file -R "sip.Call-ID contains $SIPID" -w $FILE 2>/dev/null &
	chk_if_running "tshark"
	check_working_dir "recheck"
done
;;
SIP_RTP)
handle_pcap_files
for file in `ls *.pcap`
do
	FILE="$TMP/${TMPFILES}_$$"
	##
	## TODO: Make it work with more than 2 RTP ports
	##
	log_me "Filter ==  \"sip.Call-ID contains $SIPID or (udp.dstport==$RTPP1 and udp.srcport==$RTPP2) or (udp.dstport==$RTPP2 and udp.srcport==$RTPP1)\"" "d"
	log_me   "Extracting pcap file $file to $FILE " i t
	tshark -r $file -R "sip.Call-ID contains $SIPID or (udp.dstport==$RTPP1 and udp.srcport==$RTPP2) or (udp.dstport==$RTPP2 and udp.srcport==$RTPP1)" -w $FILE 2>/dev/null &
	chk_if_running "tshark"
	check_working_dir "recheck"
done
;;
*)
	log_me "Something went terribly wrong." e
	exit 99
;;
esac
}

##################
handle_pcap_files()
##################
{
log_me "Looking for files ending in *.pcap"
cd $PCAPDIR
ls -l *.pcap >/dev/null 2>&1
if [ $? -eq "0" ]
	then
	log_me "Found the following files to extract:"
	echo
	ls -lhart *.pcap
	echo
else
	log_me "Unable to find files ending in .pcap, please rename files to have extension as \".pcap\" if pcaps are in a different directory pass \"-d\" argument " w
	ls -l *.pcap* >/dev/null 2>&1
	if [ $? -eq "0" ]
		then
		echo -n "I could find files that contains the pcap in the name but are not ending as \.pcap, should I rename them?(make sure that we only have the pcaps to be extracted here $PCAPDIR): (Y/N)"
		read RNM_PCAP
		case $RNM_PCAP in
		"y"|"Y"|"yes"|"yeah"|"YES"|"Yes")
			for pcap_file in `ls *pcap*`
			do
				log_me "renaming $pcap_file to ${pcap_file}.pcap"
				mv $pcap_file ${pcap_file}.pcap
			done
		;;
		"n"|"N"|"no"|"nope"|"NO"|"No")
			exit 10
		;;
		*)
			log_me "No sure what you meant by \"$RNM_PCAP\"" w
			exit 10
		;;
		esac
	else
		log_me "Could not not find any files that had pcap in the name , please check $PCAPDIR ...." e
		exit 11
	fi
fi


}
#############
merge_pcaps()
#############
{
mkdir -p ${PCAPDIR}/$SIPID 2>/dev/null
mergecap -a -F libpcap -w ${PCAPDIR}/$SIPID/${SIPID}.pcap ${TMP}/${TMPFILES}_$$ 2>/dev/null
if [ $? -ne 0 ]
	then
	log_me "Unable to find files to merge on ${TMP} " e
	exit 1
fi
log_me "Extracted pcap saved to: $SIPID/${SIPID}.pcap" i
ls -lhart $PCAPDIR/$SIPID/$SIPID.pcap
}


clear
main_menu $@
