# Auto-activate Helion venv if it exists
if test -f $HOME/repos/helion/.venv/bin/activate.fish
    source $HOME/repos/helion/.venv/bin/activate.fish
end
