# Auto-activate shared venv if it exists
if test -f $HOME/repos/.venv/bin/activate.fish
    source $HOME/repos/.venv/bin/activate.fish
end
