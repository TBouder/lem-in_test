# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    ft_tests.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tbouder <tbouder@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/17 14:58:50 by tbouder           #+#    #+#              #
#    Updated: 2016/05/24 22:02:53 by tbouder          ###   ########.fr        #
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
	for d in lem-in_maps/error/*
	do
		printf "%-50s" "$yellow$(basename $d) : $normal"
		for f in lem-in_maps/error/$(basename $d)/*
		do
			leak=$(ft_leaks $EXEC/lem-in < $f)
			lik=$?
			err=$(ft_leaks $EXEC/lem-in < $f)
			len=$($EXEC/lem-in < $f | wc -l | tr -d ' ')
			ft_signal $lik "$err" $i $f
			count=$((count + 1))
		done
		printf "\n"
	done
	err=""
}

ft_comments ()
{
	err="NULL"
	printf "%-50s" "$yellow""comments : ""$normal"
	for f in lem-in_maps/comment/*
	do
		leak=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		len=-$(cat $f | wc -l | tr -d ' ')
		comm=$(bash -c 'diff -u <(cat '$f') <('$EXEC'/lem-in < '$f' | head '$len')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_cmds ()
{
	err="NULL"
	printf "%-50s" "$yellow""cmd : ""$normal"
	for f in lem-in_maps/cmd/*
	do
		leak=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		if [ "$(basename $f)" = "cmd_before_end" ]; then
			len=-$(cat lem-in_maps/cmd_trace/cmd_trace_beta | wc -l | tr -d ' ')
			comm=$(bash -c 'diff -u <(cat '$MAPS'/cmd_trace/cmd_trace_beta) <('$EXEC'/lem-in < '$f' | head '$len')')
		elif [ "$(basename $f)" == "cmd_before_start" ]; then
			len=-$(cat lem-in_maps/cmd_trace/cmd_trace_omega | wc -l | tr -d ' ')
			comm=$(bash -c 'diff -u <(cat '$MAPS'/cmd_trace/cmd_trace_omega) <('$EXEC'/lem-in < '$f' | head '$len')')
		else
			len=-$(cat lem-in_maps/cmd_trace/cmd_trace_alpha | wc -l | tr -d ' ')
			comm=$(bash -c 'diff -u <(cat '$MAPS'/cmd_trace/cmd_trace_alpha) <('$EXEC'/lem-in < '$f' | head '$len')')
		fi
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_pipes_error ()
{
	err="NULL"
	printf "%-50s" "$yellow""pipes_error : ""$normal"
	for f in lem-in_maps/pipes_error/*
	do
		leak=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		len=-$(cat lem-in_maps/pipes_error_trace/$(basename $f) | wc -l | tr -d ' ')
		comm=$(bash -c 'diff -u <(cat '$MAPS'/pipes_error_trace/'$(basename $f)') <('$EXEC'/lem-in < '$f' | head '$len')')
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
		err=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		len=$($EXEC/lem-in < $f | wc -l | tr -d ' ')
		ft_signal $lik "$err" $i $f $len
		count=$((count + 1))
	done
	printf "\n"
	len=0
	err=""
}

ft_mult_ways ()
{
	err="NULL"
	printf "%-50s" "$yellow""multiple_ways : ""$normal"
	for f in lem-in_maps/multiple_ways/*
	do
		leak=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		comm=$(bash -c 'diff -u <(cat '$MAPS'/multiple_ways_trace/'$(basename $f)') <('$EXEC'/lem-in < '$f')')
		ft_signal $lik "$comm" $i $f
		count=$((count + 1))
	done
	printf "\n"
}

ft_valid_maps_part_1 ()
{
	printf "%-50s" "$yellow""valid_maps_part_1 : ""$normal"
	for f in lem-in_maps/valid_maps_part_1/*
	do
		leak=$(ft_leaks $EXEC/lem-in < $f)
		lik=$?
		err=$(ft_leaks $EXEC/lem-in < $f)
		len=$($EXEC/lem-in < $f | wc -l | tr -d ' ')
		comm=$(bash -c 'diff -u <(cat '$MAPS'/valid_maps_part_1_trace/'$(basename $f)') <('$EXEC'/lem-in < '$f')')
		if [[ $comm != "" && -e $MAPS/valid_maps_part_1_trace/$(basename $f)_alt ]]; then
			comm=$(bash -c 'diff -u <(cat '$MAPS'/valid_maps_part_1_trace/'$(basename $f)_alt') <('$EXEC'/lem-in < '$f')')
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
