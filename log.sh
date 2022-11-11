#!/bin/bash

## Variables ##
NC=$'\001'"$(tput sgr0)"$'\002'

colors[0]=$'\001'"$(tput setaf 0)"$'\002'
colors[1]=$'\001'"$(tput setaf 2)"$'\002'
colors[2]=$'\001'"$(tput setaf 3)"$'\002'
colors[3]=$'\001'"$(tput setaf 190)"$'\002'
colors[4]=$'\001'"$(tput setaf 153)"$'\002'
colors[5]=$'\001'"$(tput setaf 4)"$'\002'
colors[6]=$'\001'"$(tput setaf 5)"$'\002'
colors[7]=$'\001'"$(tput setaf 6)"$'\002'
# colors[8]=$'\001'"$(tput setaf 1)"$'\002'
# colors[9]=$'\001'"$(tput setaf 7)"$'\002'

colors_size=${#colors[@]}
colors_index=0
colors_index_pre=0
random_color=${colors[$colors_index]}  # default color is black

__LOG_DEBUG=0

debug() {
	# show log only when have debug.txt file or __LOG_DEBUG env is greater than 0
	if [ -f "debug.txt" -o $__LOG_DEBUG -gt 0 ]; then
		log "${1}"
	fi
}

_replace_tab_by_spaces() {
	echo -e "${1}" | sed 's/\t/    /g'
}

# log print out log
# allow to change prefix, suffix, line_width
# log [--prefix x --suffix y --line_width numb] "log text here"
# or
# log "log text here" [--prefix x --suffix y --line_width numb]
log() {
	local str prefix suffix line_width padding_str
	while [[ $# -gt 0 ]]; do
		case $1 in 
		--suffix) shift; suffix="$1"; debug "got suffix: $1";;
		--prefix) shift; prefix="$1"; debug "got prefix: $1";;
		--line_width) shift; line_width="$1"; debug "got line_width: $1";;
		--padding_str) shift; padding_str="$1"; debug "got padding_str: $1";;
		*) str="$1"; debug "got str: $1";;
		esac
		shift
	done
	# check and set default values
	prefix=${prefix:-"# "}
	suffix=${suffix:-""}
	line_width=${line_width:-${RF_LINE_WIDTH:-90}}
	padding_str="${padding_str:-" "}"
	str=` _replace_tab_by_spaces "${str}" `

	local padding=$(( line_width - ${#str} - ${#prefix} - ${#suffix} ))

	debug "prefix: $prefix, suffix: $suffix, line_width: $line_width, padding: $padding"
	
	_repeat --count $padding --prefix "${random_color}${prefix}${str}" --suffix "${suffix}${NC}" "$padding_str"
}

# log_header log text as header
# allow to change line_width
# log_header [--prefix x --suffix y --line_width numb] "log text here"
# or
# log_header "log text here" [--prefix x --suffix y --line_width numb]
log_header() {
	local str line_width prefix suffix padding_str
	while [[ $# -gt 0 ]]; do
		case $1 in 
		--suffix) shift; suffix="$1"; debug "got suffix: $1";;
		--prefix) shift; prefix="$1"; debug "got prefix: $1";;
		--line_width) shift; line_width="$1"; debug "got line_width: $1";;
		--padding_str) shift; padding_str="$1"; debug "got padding_str: $1";;
		*) str="$1"; debug "got str: $1";;
		esac
		shift
	done
	# check and set default values
	prefix="${prefix:-"####"}"
	suffix="${suffix:-"#"}"
	line_width=${line_width:-${RF_LINE_WIDTH:-90}}
	padding_str="${padding_str:-"="}"
	str=` _replace_tab_by_spaces "${str}" `
	
	_random_color_gen
	debug "random color to "
	str="${prefix} ${str} ${prefix}" # append 2 prefix to str
	local padding=$(( line_width - ${#str} - ${#suffix} ))
	
	debug "prefix: $prefix, suffix: $suffix, line_width: $line_width, padding: $padding"

	_repeat --count ${padding} --prefix "${random_color}${str}" --suffix "${suffix}${NC}" "${padding_str}"
}

# log_title create a log have title and content
# log_title [--title "title here" --prefix x --suffix y --line_width numb] "log text here"
# or
# log_title "log text here" [--title "title here" --prefix x --suffix y --line_width numb]
log_title() {
	local title str line_width prefix suffix padding_str ifs
	while [[ $# -gt 0 ]]; do
		case $1 in 
		--title) shift; title="$1"; debug "got title: $1";;
		--suffix) shift; suffix="$1"; debug "got suffix: $1";;
		--prefix) shift; prefix="$1"; debug "got prefix: $1";;
		--line_width) shift; line_width="$1"; debug "got line_width: $1";;
		--padding_str) shift; padding_str="$1"; debug "got padding_str: $1";;
		--ifs) shift; ifs="$1"; debug "got ifs: $1";;
		*) str="$1"; debug "got str: $1";;
		esac
		shift
	done
	# check and default value
	prefix="${prefix:-"# "}"
	suffix="${suffix:-"#"}"
	line_width=${line_width:-${RF_LINE_WIDTH:-90}}
	padding_str="${padding_str:-" "}"
	title="${title:-""}"
	str=` _replace_tab_by_spaces "${str}" `
	
	ifs=${ifs:-$'\n'}

	# re-calculate line_width with prefix and suffix
	line_width=$(( line_width + ${#prefix} + ${#suffix} ))

	local padding=0

	# print out header
	log_header "${title}" --line_width ${line_width}
	
	local saveIFS="$IFS" && IFS=$ifs
	for line in ${str}; do
		line="$( _replace_tab_by_spaces "${line}" )"
		padding=$(( line_width - ${#line} - ${#prefix} - ${#suffix} ))
		
		# debug "line len: ${#line}, padding: ${padding}"
		
		[[ $padding -lt 1 ]] && padding=0
		_repeat --count ${padding} --prefix "${prefix}${line}" --suffix "${suffix}" "${padding_str}"
	done
	log_end --line_width ${line_width}
	IFS="$saveIFS"
}

# log_end log with no text - seperated line
log_end() {
	local line_width prefix suffix padding_str
	while [[ $# -gt 0 ]]; do
		case $1 in 
		--suffix) shift; suffix="$1"; debug "got suffix: $1";;
		--prefix) shift; prefix="$1"; debug "got prefix: $1";;
		--line_width) shift; line_width="$1"; debug "got line_width: $1";;
		--padding_str) shift; padding_str="$1"; debug "got padding_str: $1";;
		esac
		shift
	done
	line_width=${line_width:-${RF_LINE_WIDTH:-90}}
	prefix="${prefix:-"#"}"
	suffix="${suffix:-"#"}"
	padding_str="${padding_str:-"="}"
	local padding=$(( line_width - ${#prefix} - ${#suffix} )) # -2 because i want to keep line_width but i was added 2 #
	_repeat --count ${padding} --prefix "${prefix}" --suffix "${suffix}" "${padding_str}"
	# echo # make new line
}

log_empty(){
	log_end --prefix " " --suffix " " --padding_str " "
}


__RF_STEP_SEP=$'\n'
__RF_STEP_MESSAGE=""
__RF_STEP_X=0
__RF_STEP_Y=0

# log_step create a log with keeping the step in the top of console for easy following
log_step() {

	clear
	__RF_STEP_MESSAGE="${__RF_STEP_MESSAGE}${__RF_STEP_SEP}${@}\n"
	tput cup ${__RF_STEP_X} ${__RF_STEP_Y} 
	local saveIFS=$IFS
	IFS=${__RF_STEP_SEP}
	for msg in ${__RF_STEP_MESSAGE}; do
		[[ -z "${#msg}" ]] && continue
		if [[ "${msg:0:7}" == "result:" ]]; then
			log "${msg}" --suffix "#"
			continue
		fi
		# [[ "${msg:0:6}" == "title:" ]] && log_title "${msg:6}" && continue
		log_header "${msg}"
	done
	IFS=$saveIFS
	
	# __RF_STEP_Y=$((__RF_STEP_Y + 1))
	# __RF_STEP_Y=$((__RF_STEP_Y + 1))
}

# log_step_title() {
# 	log_step "title: => ${@}"
# }

log_step_result(){
	log_step "result: => ${@}"
}

log_step_reset() {
	__RF_STEP_MESSAGE=""
	__RF_STEP_X=0
	__RF_STEP_Y=0
}

# Repeat given char N times using shell function
# _repeat "repeat str" [--prefix x --suffix y --count numb]
# or
# _repeat [--prefix x --suffix y --count numb] "repeat str"
_repeat() {
	local str count prefix suffix
	while [[ $# -gt 0 ]]; do
		case $1 in 
		--suffix) shift; suffix="$1"; debug "got suffix: $1";;
		--prefix) shift; prefix="$1"; debug "got prefix: $1";;
		--count) shift; count="$1"; debug "got count: $1";;
		*) str="$1"; debug "got str: $1";;
		esac
		shift
	done
	# check and default values
	count=${count:-${RF_LINE_WIDTH:-90}}
	prefix="${prefix:-}"
	suffix="${suffix:-}"

	# add prefix on start
	echo -en "${random_color}${prefix}"
	if [[ $count -gt 0 ]]; then
		# range start at 1
		local range=$( seq 1 ${count} )
		for i in $range; do echo -n "${str}"; done
	fi
	echo -e "${suffix}${NC}"
}

_random_color_gen() {
	# generate random color, RANDOM is a bash shell value
	colors_index=$(( RANDOM % colors_size ))
	if [[ ${colors_index} -eq ${colors_index_pre} ]]; then
		colors_index=$(( RANDOM % colors_size ))
	fi
	colors_index_pre=${colors_index}
	random_color=${colors[$colors_index]}
}

# starting
# "$@"