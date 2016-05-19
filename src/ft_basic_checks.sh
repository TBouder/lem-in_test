# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    ft_basic_checks.sh                                 :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tbouder <tbouder@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/17 15:29:27 by tbouder           #+#    #+#              #
#    Updated: 2016/05/19 16:43:16 by tbouder          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
source src/ft_var.sh

ft_author ()
{
	if [ -e "$EXEC/auteur" ]; then
		user=$(cat $EXEC/auteur)
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
	if [ -e "$EXEC/Makefile" ]; then
		make -C $EXEC/ fclean
		make -C $EXEC/
		make2=$(make -C $EXEC/)
		make -C $EXEC/ clean
		make3=$(make -C $EXEC/)
		make -C $EXEC/ re
		if [ "$make2" = "make: Nothing to be done for \`all'." -a "$make3" = "" ] ; then
			echo "Makefile : \033[32;1mOK\033[00;0m"
		elif [ "$make2" = "make: Nothing to be done for \`all'." -a "$make3" = "make: Nothing to be done for \`all'." ] ; then
			echo "Makefile : \033[38;5;166m~~\033[00;0m"
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
