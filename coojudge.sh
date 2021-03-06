#!/bin/bash
chmod +x judge.sh
chmod +x judge_checker.sh

bold='\e[1m'
normal=$(tput sgr0)

cyan='\033[0;36m'
red='\033[0;31m'
green='\033[0;32m'
blue='\033[0;34m'
yellow='\033[0;33m'
purple='\033[0;35m'
plain='\033[0m'

if [ -e Result ]; then 
	:
else 
	mkdir Result
fi

echo -e "${cyan}${bold}Welcome to Coo Judge ${normal}"
sleep 0.300
foo=0
while [ $foo -lt 1 ]; do

	printf "\n" 
	if [ -e .tmp ] ; then 
		:
	else
		 mkdir .tmp
	fi
	
	totalScore=0
	totalTest=0
	totalproblem=0
	totalACproblem=0

	printf "\t${red}${bold}Set All Time Limit to 1 ? [y/N] ${normal}"
	superJudge=0
	read checkContinuos
	if [[ "$checkContinuos" =~ ^([yY][eE][sS]|[yY])+$ ]] ;
        then
            superJudge=1
        fi
	printf "\n"

	for f in Submit/*.cpp ; do

		filename=$(basename -- $f)
		name="${filename%.*}"
		cname="${purple}"$name
		cname=$cname"${plain}"
		echo -e "\t${bold}Problem ${normal}: $cname"
		let totalproblem=totalproblem+1

		log="result_$name.log"
		if [ -e $log ] ; then
			> $log
		else
			touch $log
		fi

		if g++ -std=c++11 -O2 $f -o ".tmp/$name" &> $log ; then
			:
		else
			echo -e "\t \e[38;5;199m${bold}Compile Error !!!${normal}${plain}"
			echo -e "\t \e[38;5;202m${bold}Skip ${normal}Problem $cname"
			printf "\n"
			continue
		fi

		if [ -e  "Test/$name" ] ; then
			echo -e "\t ${green}${bold}Ready!${normal}${plain} Start Judging $cname"

			flag_checker=0
			if [ -e "Test/$name/checker" ] ; then
				./judge_checker.sh ".tmp/$name" "Test/$name" $superJudge #2> /dev/null
				flag_checker=1
			else 
				./judge.sh ".tmp/$name" "Test/$name" $superJudge #2> /dev/null
			fi
						
			numAC="$(< .numAC.splog)"
			numAll="$(< .numAll.splog)"

			totalScore=`echo $totalScore + $numAC | bc`

			let totalTest=totalTest+numAll
			if [ $flag_checker -eq 0 ] &&  [ "$numAll" -eq "$numAC" ] ; then
				let totalACproblem=totalACproblem+1
			fi
			
			find -path './.*.splog' -delete
			echo -e "\t ${cyan}${bold}Done${normal} Judging $cname"	

		else

			echo -e "\t ${red}${bold}Error!${plain}${normal} Missing Test for Problem $cname"
			echo -e "\t \e[38;5;202m${bold}Skip ${normal}Problem $cname"

		fi

		printf "\n"

	done

	if [ $totalACproblem = $totalproblem ] && [ $totalACproblem -gt 0 ] && [ $totalScore -gt 0 ] ; then
		echo -e "\t     \e[48;5;27m\e[38;5;234m${bold}(っ◔◡◔)っ \e[38;5;196m♥ \e[38;5;121mꓚooPletꓱ \e[38;5;196m♥ ${normal}"
			# spd-say -r -50 -p -55 -i -65 -t female2 "cupleted"
	else
		:
	#	spd-say -r -50 -p -55 -i -65 -t female2 -l UG ""
	fi

	printf "\t ${cyan} \e[1m\e[4m"
       	echo "$totalScore" |bc | awk '{printf "%.4f", $0}' 
	printf " score \e[38;5;9m in \e[38;5;57m$totalTest Tests${normal} \n"

	rm -r .tmp

	printf "${blue}${bold}Continue Judging ? [y/N] ${normal}"
	read response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] ;
	then
	    :
	else
	    break ;
	fi
done

mv *.log Result &> /dev/null

echo -e "${blue}${bold}Press Any Key to Exit"
read -rn1
