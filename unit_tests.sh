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

ft_signal ()
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
	elif [[ ("$err" == *"error"* || "$err" == *"ERROR"* || "$err" == *"Error"*) && $len -eq 1 ]]; then
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

ft_author ()
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

ft_makefile ()
{
	if [ -e "Makefile" ]; then
		make fclean
		make
		make2=$(make)
		make clean
		# make3=$(make)
		# make re
		make
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

ft_norme ()
{
	norme_error=$(norminette . | grep -B1 Error | grep -w "Error" -c)
	if [ $norme_error != 0 ] ; then
		echo "Norminette : \033[31;1mKO\033[00;0m"
		norminette . | grep -B1 Error
	else
		echo "Norminette : \033[32;1mOK\033[00;0m"
	fi
}

ft_errors ()
{
	comm="NULL"
	for d in lem-in_maps/error/*
	do
		printf "%-50s" "$yellow$(basename $d) : $normal"
		for f in lem-in_maps/error/$(basename $d)/*
		do
			err=$($leaks ./lem-in < $f)
			len=$(./lem-in < $f | wc -l | tr -d ' ')
			lik=$?
			ft_signal $lik "$err" $i $f
			count=$((count + 1))
		done
		printf "\n"
	done
	err=""
}

ft_comments ()
{
	printf "%-50s" "$yellow""comments : ""$normal"
	for f in lem-in_maps/comment/*
	do
		leak=$($leaks ./lem-in < $f)
		lik=$?
		len=-$(cat $f | wc -l | tr -d ' ')
		comm=$(bash -c 'diff -u <(cat '$f') <(./lem-in < '$f' | head '$len')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_cmds ()
{
	printf "%-50s" "$yellow""cmd : ""$normal"
	for f in lem-in_maps/cmd/*
	do
		leak=$($leaks ./lem-in < $f)
		lik=$?
		if [ "$(basename $f)" = "cmd_before_end" ]; then
			len=-$(cat lem-in_maps/cmd_trace/cmd_trace_beta | wc -l | tr -d ' ')
			comm=$(bash -c 'diff -u <(cat '$WAY'/cmd_trace/cmd_trace_beta) <(./lem-in < '$f' | head '$len')')
		elif [ "$(basename $f)" == "cmd_before_start" ]; then
			len=-$(cat lem-in_maps/cmd_trace/cmd_trace_omega | wc -l | tr -d ' ')
			comm=$(bash -c 'diff -u <(cat '$WAY'/cmd_trace/cmd_trace_omega) <(./lem-in < '$f' | head '$len')')
		else
			len=-$(cat lem-in_maps/cmd_trace/cmd_trace_alpha | wc -l | tr -d ' ')
			comm=$(bash -c 'diff -u <(cat '$WAY'/cmd_trace/cmd_trace_alpha) <(./lem-in < '$f' | head '$len')')
		fi
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_pipes_error ()
{
	printf "%-50s" "$yellow""pipes_error : ""$normal"
	for f in lem-in_maps/pipes_error/*
	do
		leak=$($leaks ./lem-in < $f)
		lik=$?
		len=-$(cat lem-in_maps/pipes_error_trace/$(basename $f) | wc -l | tr -d ' ')
		comm=$(bash -c 'diff -u <(cat '$WAY'/pipes_error_trace/'$(basename $f)') <(./lem-in < '$f' | head '$len')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_no_way ()
{
	comm="NULL"
	len=0
	printf "%-50s" "$yellow""no_way : ""$normal"
	for f in lem-in_maps/no_way/*
	do
		err=$($leaks ./lem-in < $f)
		len=$(./lem-in < $f | wc -l | tr -d ' ')
		lik=$?
		ft_signal $lik "$err" $i $f $len
		count=$((count + 1))
	done
	printf "\n"
	len=0
	err=""
}

ft_logs ()
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
make fclean && make
while [ $# -ne 0 ];do
	if [ "$1" = "leaks" ]; then
		leaks="sh /Volumes/USB/.files/valgrind/vg-in-place -q --leak-check=full --suppressions=/Volumes/USB/.files/valgrind/osx.supp --error-exitcode=42"
		null=$($leaks ./lem-in < lem-in_maps/subject0.map)
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
# ---------------------------------------------------------------------------- #

# Process tests
# ---------------------------------------------------------------------------- #
ft_errors
ft_comments
ft_cmds
ft_pipes_error
ft_no_way
# ---------------------------------------------------------------------------- #

# Display results
# ---------------------------------------------------------------------------- #
ft_logs

printf "%47s\n" "$blue[$good/$count]$normal"
echo "                       \/       \/"
echo "                 ___  _@@       @@_  ___"
echo "                (___)(_)         (_)(___)"
echo "                //|| ||           || ||\\"
