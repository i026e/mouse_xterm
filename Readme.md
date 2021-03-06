# Mouse support on readline

The following code enables clicks to move cursor in bash/readline on xterm

1. Enable xterm mouse tracking reporting   
2. Set readline bindings to consume the escape sequence generated by clicks    

## Quickstart

	mkdir Mouse && cd Mouse
	git clone --depth=1 https://github.com/tinmarino/mouse_xterm .
	source mouse.sh && mouse_track_start
	# Press C-l after using mousewhell because it has to disable mouse tracking to work

## Xterm

Xterm have a mouse tracking feature

	echo -e "\e[?1000;1006;1015h" # Enable tracking
	echo -e "\e[?1000;1006;1015l" # Disable tracking

* Mouse click looks like `\e[<0;3;21M` and a release `\e[<0;3;21`. Where `2` is x (from left) and `22` is y (from top)  
* Mouse whell up : `\e[<64;3;21M`
* Mouse whell down : `\e[<65;3;21M`
* Press `C-v` after enabling the mouse tracking to see that

## Bash

Readline can trigger a bash callback

	bind -x '"\e[<64;": mouse_void_cb' # Cannot be put in .inputrc
	bind    '"\C-h"   : "$(date) \e\C-e\ef\ef\ef\ef\ef"' #Can be put in .inputrc

Readline can call multiple functions

	# Mouse cursor to begining-of-line before calling click callback
	bind    '"\C-98" : beginning-of-line'
	bind -x '"\C-99" : mouse_0_cb'
	bind    '"\e[<0;": "\C-98\C-99"'

Readline callback can change cursor (point) position with `READLINE_POINT` environment variable

	bind -x '"\C-h"  : xterm_test'
	function xterm_test {
		echo "line is $READLINE_LINE and point $READLINE_POINT"
		READLINE_POINT=24    # The cursor position (0 for begining of command)
		READLINE_LINE='coco' # The command line current content
	}

## Perl (reply)

TODO no comment yet, I could not invoke a readline command or I would have lost $term->{point}

## Python (ipython)

Ipython supports mouse. See [Ipython/terminal/shortcuts](https://github.com/ipython/ipython/blob/master/IPython/terminal/shortcuts.py) -> [Prompt-toolkit/bingin.mouse](https://github.com/prompt-toolkit/python-prompt-toolkit/blob/master/prompt_toolkit/key_binding/bindings/mouse.py)

	ipython --TerminalInteractiveShell.mouse_support=True

Or to enable at startup write in `.ipython/profile_default/ipython_config.py`

	c = get_config()
	c.TerminalInteractiveShell.mouse_support

## Limitations

* OK : bash, ipython3, tmux
* NO : python, reply
* DISABLED : vim

## Links

* [Xterm control sequences](https://invisible-island.net/xterm/ctlseqs/ctlseqs.html)
* [Ctrl keys as used in vim source](https://github.com/vim/vim/blob/master/src/libvterm/doc/seqs.txt)
* [zsh script for mouse tracking](https://github.com/stephane-chazelas/misc-scripts/blob/master/mouse.zsh) : the same but in zsh (not bash)
