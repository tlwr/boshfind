# Boshfind

Get a match from a bosh ops-file

Usage and abusage:

```
crystal spec
crystal build -o boshfind src/entrypoint
./boshfind -f opsfile.yml /path/in/yaml
# OR
./boshfind /path/in/yaml < opsfile.yml
# OR
./boshfind -f - /path/in/yaml < opsfile.yml
```
