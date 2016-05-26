# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    unit_tests.sh                                      :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tbouder <tbouder@student.42.fr>            +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2016/05/17 19:19:25 by tbouder           #+#    #+#              #
#    Updated: 2016/05/26 18:14:50 by tbouder          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/bin/bash
source src/ft_var.sh
source src/ft_basic_checks.sh
source src/ft_tests.sh

echo '    __                         _          __            __ '
echo '   / /   ___  ____ ___        (_)___     / /____  _____/ /_'
echo '  / /   / _ \/ __ `__ \______/ / __ \   / __/ _ \/ ___/ __/'
echo ' / /___/  __/ / / / / /_____/ / / / /  / /_/  __(__  ) /_  '
echo '/_____/\___/_/ /_/ /_/     /_/_/ /_/   \__/\___/____/\__/  '
echo '                                     Tbouder@student.42.fr '
echo

MAPS=./lem-in_maps

if [ -e "src/path_to_exec" ]; then
	EXEC=$(cat src/path_to_exec)
else
	read -e -p "Enter the path to the file (autocompletion enabled): " FILEPATH
	eval EXEC=${FILEPATH/\~/$HOME}
	echo $EXEC > src/path_to_exec
fi

# Extract args---------------------------------------------------------------- #
ft_arg $@

# Process tests------Error---------------------------------------------------- #
ft_errors
ft_cmp_to_trace comment
ft_cmp_to_trace cmd
ft_cmp_to_trace pipes_error
# Process tests------Success--------------------------------------------------- #
ft_cmp_to_trace multiple_ways
ft_valid_maps_part_1

# Display results------------------------------------------------------------- #
ft_logs

printf "%47s\n" "$blue[$good/$count]$normal"
echo "                       \/       \/"
echo "                 ___  _@@       @@_  ___"
echo "                (___)(_)         (_)(___)"
echo "                //|| ||           || ||\\"
