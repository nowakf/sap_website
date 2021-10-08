gcc -E -nostdinc /usr/include/yaml.h 2>/dev/null | sed s/#.*// | tr -s n
