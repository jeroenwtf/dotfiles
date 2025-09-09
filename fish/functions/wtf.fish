function wtf
    if test (count $argv) -eq 0
        echo "Usage: wtf <port>"
        return 1
    end

    set port $argv[1]
    lsof -i :$port
end
