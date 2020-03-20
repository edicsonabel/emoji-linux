# Emojix
## Getting Started
### Installation
```sh
sh -c "$(wget -O- https://raw.githubusercontent.com/edicsonabel/emojix/master/install.sh 2>/dev/null)"
```
### Example in terminal
```sh
echo "$(printf "$(wget -O- https://raw.githubusercontent.com/edicsonabel/emojix/master/example.txt 2>/dev/null)")"
```
## Installation with update
#### Oneline
```sh
wget https://raw.githubusercontent.com/edicsonabel/emojix/master/install.sh -O /tmp/emojix 2>/dev/null;chmod +x /tmp/emojix;sh /tmp/emojix -u
```
#### Normal
```sh
# Download Emojix installer
wget https://raw.githubusercontent.com/edicsonabel/emojix/master/install.sh -O /tmp/emojix 2>/dev/null

# Execution permit
chmod +x /tmp/emojix

# Execute with option to update '-u' or '--update'
sh /tmp/emojix -u
```
