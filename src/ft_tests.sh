# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    ft_tests.sh                                        :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tbouder <tbouder@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/17 14:58:50 by tbouder           #+#    #+#              #
#    Updated: 2016/05/17 16:27:27 by tbouder          ###   ########.fr        #
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
			err=$(ft_leaks $EXEC/lem-in < $f)
			len=$($EXEC/lem-in < $f | wc -l | tr -d ' ')
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
		len=$($EXEC/lem-in < $f | wc -l | tr -d ' ')
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
