# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    ft_var.sh                                          :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tbouder <tbouder@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/17 15:30:09 by tbouder           #+#    #+#              #
#    Updated: 2016/06/02 17:17:01 by tbouder          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
red=$(tput bold ; tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput bold ; tput setaf 3)
blue=$(tput bold ; tput setaf 6)
normal=$(tput sgr0)
i=0
j=0
good=0
count=0
leaks="KO"

ft_leaks()
{
	if [[ $leaks = "OK" ]]; then
		~/.brew/Cellar/valgrind/3.11.0/bin/valgrind -q --leak-check=full --error-exitcode=42 --suppressions=src/false_pos_valgrind.supp $1
		#valgrind -q --leak-check=full --error-exitcode=42 --suppressions=src/false_pos_valgrind.supp $1
	else
		$1
	fi
}

ft_arg ()
{
	make -C $EXEC/ fclean && make -C $EXEC/
	while [ $# -ne 0 ];do
		if [ "$1" = "leaks" ]; then
			leaks="OK"
			null=$(ft_leaks $EXEC/lem-in < lem-in_maps/subject0.map)
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
}
