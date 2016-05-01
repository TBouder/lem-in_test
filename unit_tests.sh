#!/bin/bash

echo '    __                         _          __            __ '
echo '   / /   ___  ____ ___        (_)___     / /____  _____/ /_'
echo '  / /   / _ \/ __ `__ \______/ / __ \   / __/ _ \/ ___/ __/'
echo ' / /___/  __/ / / / / /_____/ / / / /  / /_/  __(__  ) /_  '
echo '/_____/\___/_/ /_/ /_/     /_/_/ /_/   \__/\___/____/\__/  '
echo '                                     Tbouder@student.42.fr '
echo

WAY=/Volumes/USB/lem-in/lem-in_maps
red=$(tput bold ; tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput bold ; tput setaf 3)
blue=$(tput bold ; tput setaf 6)
normal=$(tput sgr0)
i=0
j=0
good=0
count=0
leaks=""

function	ft_signal
{
	if [[ $1 -ge 129 && $1 -le 140 ]]; then
		errors[$i]=$(basename $4)
		motif[$i]="SEGFAULT"
		i=$((i+1))
		printf "%s" "$red[SEGFAULT]$normal"
	elif [[ $1 -eq 42 ]]; then
		errors[$i]=$(basename $4)
		motif[$i]="LEAKS"
		i=$((i+1))
		printf "%s" "$red[LEAKS]$normal"
	elif [[ "$err" == *"error"* || "$err" == *"ERROR"* || "$err" == *"Error"* ]]; then
		good=$((good + 1))
		printf "%s" "$green.$normal"
	elif [[ "$comm" == "" ]]; then
		good=$((good + 1))
		printf "%s" "$green.$normal"
	else
		errors[$i]=$(basename $4)
		motif[$i]="KO"
		i=$((i+1))
		printf "%s" "$red[KO]$normal"
	fi
}

function	ft_author
{
	if [ -e "auteur" ]; then
		user=$(cat auteur)
		iam=$(whoami)
		if [ "$user" = "$iam" ] ; then
			echo "Author file : \033[32;1mOK\033[00;0m"
		else
			echo "Author file : \033[31;1mKO\033[00;0m"
		fi
	else
		echo "\033[31;1mAuthor file missing\033[00;0m"
	fi
}

function	ft_makefile
{
	if [ -e "Makefile" ]; then
		make fclean
		make
		make2=$(make)
		make clean
		# make3=$(make)
		# make re
		make
		make fclean
		# if [ "$make2" = "make: Nothing to be done for \`all'." -a "$make3" = "make: Nothing to be done for \`all'." ] ; then
		if [ "$make2" = "make: Nothing to be done for \`all'." ] ; then
			echo "Makefile : \033[32;1mOK\033[00;0m"
		else
			echo "Makefile : \033[31;1mKO\033[00;0m"
		fi
	else
		echo "\033[31;1mMakefile missing\033[00;0m"
	fi
}

function	ft_norme
{
	norme_error=$(norminette . | grep -B1 Error | grep -w "Error" -c)
	if [ $norme_error != 0 ] ; then
		echo "Norminette : \033[31;1mKO\033[00;0m"
		norminette . | grep -B1 Error
	else
		echo "Norminette : \033[32;1mOK\033[00;0m"
	fi
}

function	ft_errors
{
	comm="NULL"
	for d in lem-in_maps/error/*
	do
		printf "%-50s" "$yellow$(basename $d) : $normal"
		for f in lem-in_maps/error/$(basename $d)/*
		do
			err=$($leaks ./lem-in < $f)
			lik=$?
			ft_signal $lik "$err" $i $f
			count=$((count + 1))
		done
		printf "\n"
	done
	err=""
}

function	ft_comments
{
	printf "%-50s" "$yellow""Comments : ""$normal"
	for f in lem-in_maps/comment/*
	do
		leak=$($leaks ./lem-in < $f)
		lik=$?
		comm=$(bash -c 'diff -u <(cat '$f') <(./lem-in < '$f')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

function	ft_cmds
{
	printf "%-50s" "$yellow""Cmd : ""$normal"
	for f in lem-in_maps/cmd/*
	do
		leak=$($leaks ./lem-in < $f)
		lik=$?
		if [ "$(basename $f)" = "cmd_before_end" ]; then
			comm=$(bash -c 'diff -u <(cat '$WAY'/cmd_trace/cmd_trace_beta) <(./lem-in < '$f')')
		elif [ "$(basename $f)" == "cmd_before_start" ]; then
			comm=$(bash -c 'diff -u <(cat '$WAY'/cmd_trace/cmd_trace_omega) <(./lem-in < '$f')')
		else
			comm=$(bash -c 'diff -u <(cat '$WAY'/cmd_trace/cmd_trace_alpha) <(./lem-in < '$f')')
		fi
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

function	ft_pipes_error
{
	printf "%-50s" "$yellow""pipes_error : ""$normal"
	for f in lem-in_maps/pipes_error/*
	do
		leak=$($leaks ./lem-in < $f)
		lik=$?
		comm=$(bash -c 'diff -u <(cat '$WAY'/pipes_error_trace/'$(basename $f)') <(./lem-in < '$f')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

function	ft_logs
{
	if [ ${#errors[@]} -ne 0 ]; then
	echo "-------------------------------------------------------------------------"
	echo "$red""Errors in""$normal"
		for nb in "${errors[@]}"
		do
			if [[ $j%2 -eq 0 ]]; then
				printf "%-20s : %-30s" "$nb" "$red${motif[$j]}$normal"
			else
				printf "%-20s : %s\n" "$nb" "$red${motif[$j]}$normal"
			fi
			j=$((j+1))
		done
	fi
	printf "\n\n"
}

# Extract args
# ---------------------------------------------------------------------------- #
while [ $# -ne 0 ];do
	if [ "$1" = "leaks" ]; then
		leaks="sh /Volumes/USB/.files/valgrind/vg-in-place -q --leak-check=full --suppressions=/Volumes/USB/.files/valgrind/osx.supp --error-exitcode=42"
	elif [ $1 = "author" ]; then
		ft_author
	elif [ $1 = "makefile" ]; then
		ft_makefile
	elif [ $1 = "norme" ]; then
		ft_norme
	elif [ $1 = "all" ]; then
		ft_author
		ft_makefile
		ft_norme
	fi
	shift
done
make fclean && make
# ---------------------------------------------------------------------------- #

# Process tests
# ---------------------------------------------------------------------------- #
ft_errors
ft_comments
ft_cmds
ft_pipes_error
# ---------------------------------------------------------------------------- #

# Display results
# ---------------------------------------------------------------------------- #
ft_logs

printf "%47s\n" "$blue[$good/$count]$normal"
echo "                       \/       \/"
echo "                 ___  _@@       @@_  ___"
echo "                (___)(_)         (_)(___)"
echo "                //|| ||           || ||\\"



# echo "\033[33;1mPipe to itself\033[00;0m :" && ./lem-in < lem-in_maps/pipe_to_itself
# echo "\033[33;1mError middle pipe (Room not found)\033[00;0m :" && ./lem-in < lem-in_maps/error_middle_pipe
# echo "\033[33;1mSame pipe\033[00;0m :" && ./lem-in < lem-in_maps/same_pipe
# echo "\033[33;1mSame pipe2\033[00;0m :" && ./lem-in < lem-in_maps/same_pipe2
# echo "\033[33;1mSame pipe3\033[00;0m :" && ./lem-in < lem-in_maps/same_pipe3
# echo "\033[33;1mOne map\033[00;0m :" && ./lem-in < lem-in_maps/subject0.map
# echo "\033[33;1mTwo maps\033[00;0m :" && ./lem-in < lem-in_maps/subject0.map < lem-in_maps/subject1.map
# echo "\033[33;1mThree maps\033[00;0m :" && ./lem-in < lem-in_maps/subject0.map lem-in_maps/subject1.map lem-in_maps/subject2.map
# echo "\033[33;1mSpace middle of pipe\033[00;0m :" && ./lem-in < lem-in_maps/space_middle_pipe
# echo "\033[33;1mSpace after of pipe\033[00;0m :" && ./lem-in < lem-in_maps/space_after_pipe
