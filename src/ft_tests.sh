# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    ft_tests.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tbouder <tbouder@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/17 14:58:50 by tbouder           #+#    #+#              #
#    Updated: 2016/05/31 18:05:51 by tbouder          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
source src/ft_var.sh

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

ft_errors ()
{
	comm="NULL"
	len=0
	for d in lem-in_maps/error/*
	do
		printf "%-50s" "$yellow$(basename $d) : $normal"
		for f in lem-in_maps/error/$(basename $d)/*
		do
			err=$(ft_leaks $EXEC/lem-in < $f)
			lik=$?
			len=$($EXEC/lem-in < $f | wc -l | tr -d ' ')
			ft_signal $lik "$err" $i $f $len
			count=$((count + 1))
		done
		printf "\n"
	done
	err=""
}

ft_cmp_to_trace ()
{
	err="NULL"
	printf "%-50s" "$yellow""$1 : ""$normal"
	for f in lem-in_maps/$1/*
	do
		err=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		comm=$(bash -c 'diff -u <(cat '$MAPS'/'$1'_trace/'$(basename $f)'_trace) <('$EXEC'/lem-in < '$f')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_valid_maps_part_1 ()
{
	err="NULL"
	printf "%-50s" "$yellow""valid_maps_part_1 : ""$normal"
	for f in lem-in_maps/valid_maps_part_1/*
	do
		err=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		comm=$(bash -c 'diff -u <(cat '$MAPS'/valid_maps_part_1_trace/'$(basename $f)'_trace) <('$EXEC'/lem-in < '$f')')
		if [[ $comm != "" && -e $MAPS/valid_maps_part_1_trace/$(basename $f)_alt_trace ]]; then
			comm=$(bash -c 'diff -u <(cat '$MAPS'/valid_maps_part_1_trace/'$(basename $f)_alt_trace') <('$EXEC'/lem-in < '$f')')
		fi
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
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
