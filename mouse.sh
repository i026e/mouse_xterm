#!/usr/bin/bash

# Mouse click listener implmentation on Bash by Tinmarino
# Source me and your readline cursor should move on mouse click

# Depends : xterm, readline


function log {
	# Log for debug
  echo $1 >> /tmp/xterm_monitor
}


function read_keys {
	# Read $keys <- Stdin (until 'm')
  log "---------------"
  keys=""
  while  read -n 1 c; do
    keys="$keys$c"
    [[ $c == 'M' || $c == 'm' ]] && break
  done
  log "keys = $keys"
}

function read_cursor_pos {
	# Read $cursor_pos <- xterm <- readline
  echo -en "\E[6n"
  read -sdR cursor_pos
  cursor_pos=${cursor_pos#*[}
  log "cursor_pos $cursor_pos"
}


preexec () { :; }
function trap_disable_mouse {
	# Callback traped to debug : Disable XTERM escape
	log "trap for : $BASH_COMMAND"
	[ -n "$COMP_LINE" ] && return  # do nothing if completing
	[ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return # don't cause a preexec for $PROMPT_COMMAND
	local cmd='echo -ne "\e[?1000;1006;1015l"'
	log "Preexc should stop tracking with : $cmd"
  local this_command=`$cmd`;
	$cmd
	preexec "$this_command"
}


function mouse_0_cb {
	# Callback for mouse button 0 click/release
  # Read rest
  read_keys
  xy=${keys:0:-1}
  let x1=${xy%%;*}
  let y1=${xy##*;}

  # Get mouse position (bol)
  read_cursor_pos
  x0=${cursor_pos##*;}
  y0=${cursor_pos%%;*}

  # Calculate line position
  let col=$y1-$y0
  [[ col -lt 0 ]] && let col=0
  let col=$col*$COLUMNS
  let line_pos="$x1 - $x0 - 2 + $col"
  log "x1 = $x1 && y1 = $y1 && line_pos = $line_pos"
  log "x0 = $x0 && y0 = $y0 && cursor_pos = $cursor_pos"
	log "col = $col"
  # TODO if too low, put on last line

  # Move cursor
  READLINE_POINT=$line_pos

  # Enable listen for next click
	echo -ne "\e[?1000;1006;1015h"
}

function mouse_void_cb {
	# Callback : clean xterm and disable mouse escape
  read_keys
	echo -ne "\e[?1000;1006;1015l"
}

function mouse_track {
	# Init
	# Track mouse
	echo -ne "\e[?1000;1006;1015h"

	# Utils
	bind '"\C-91": clear-screen'
	bind -x '"\C-92": printf "\e[?1000h"'
	bind -x '"\C-99": mouse_0_cb'

	# Bind Click
	bind '"\e[<0;": "\C-A\C-99"'
	bind -x '"\e[<64;": mouse_void_cb'
	bind -x '"\e[<65;": mouse_void_cb'

	# Bind C-l to reenable mouse
	bind '"\C-l": "\C-91\C-92"'

	# Disable mouse tracking before each command
	trap 'trap_disable_mouse' DEBUG

	# Enable mouse tracking after command return
	export PROMPT_COMMAND+='echo -ne "\e[?1000;1006;1015h";'
}

function mouse_ignore {
	# Stop
	echo -ne "\e[?1000;1006;1015l"
}