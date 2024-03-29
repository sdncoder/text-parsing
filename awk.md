### awk notes

in an awk rule either the pattern or the action can be omitted, but not both
- if the pattern is omitted -> action is performed for every input line
- if the action is omitted -> default is to print all lines that match the pattern

*pattern and action*  
_awk options 'selection _criteria {action }' input-file > output-file_

#### filter and print  
| syntax | use |
|--------|-----|
| awk '/xxx/ | filter on character string xxx |
| { print $0 } | print the current line |
| { print $1 } | print first field |
| { OFS = ":" } | output field selector, instead of default space |
| {printf "%-8s %s\n", $1, $4} | printf width modifier |
| sed 's/,/\n/g' | use sed on command line |
| gsub(/,/, "\n") | global replace , with \n |

##### options
- -f file
- -F field separator

##### basic filter and print examples
cisco show interface brief saved in *cisco_int*
```yaml
INTF                    ADDR             STATUS    PROTO
----------------------  ---------------  --------  -------
TenGigabitEthernet1/24  unassigned       down      down
TenGigabitEthernet1/30  unassigned       down      down
TenGigabitEthernet1/31  unassigned       up        up
Loopback0               10.125.191.36   up        up
Loopback40              10.123.66.57    up        up
Port-channel1           unassigned       up        up
Tunnel0                 10.125.172.181  up        up
Tunnel1                 10.125.172.166  up        up
Tunnel2                 10.125.172.181  up        up
Vlan1                   unassigned       up        up
Vlan40                  10.123.66.2     up        up
```

filter on tunnel interfaces that are up:  
`awk '/Tun/ { print $1 " " $3 }' cisco-int`
```yaml
Tunnel0 up  
Tunnel1 up  
Tunnel2 up  
```
filter record where first field contains "Po":  
`awk '$1 ~ /Po/ { print $0 }' cisco-int`
```yaml
Port-channel1           unassigned       up        up
Port-channel2           unassigned       up        up
Port-channel10          unassigned       up        up
```
filter for Loopbacks /Lo/ and print field 1 and 4 with OFS of:  
`awk 'BEGIN { OFS = ":" } ; /Lo/ {print $1, $4 }' cisco-int`
```yaml
Loopback0:up
Loopback40:up
```
printf to make algined table  
* minus (-) is width modifier _left justftify width of 4 = printf "%-4s"

filter for Vlan and print field 1 4 2 separated by 8 spaces:     
`awk '/Vl/ {printf "%-8s %-8s %s\n", $1, $4, $2}' cisco-int`  
```yaml
Vlan1    up       unassigned
Vlan10   up       10.125.172.2
Vlan32   up       10.125.172.34
Vlan40   up       10.123.66.2
```
add header using BEGIN:

```
awk 'BEGIN {   
      print "Interface   Status   Address"
  } /Vl/ {printf "%-12s %-6s %s\n", $1, $3, $2}' cisco-int
  ```
```yaml
Interface   Status   Address
Vlan1        up     unassigned
Vlan10       up     10.125.172.2
Vlan32       up     10.125.172.34
Vlan40       up     10.123.66.2
```
#### using sed with awk on the command line
_awk has its own string manipulation functions_

output from ansible where a row is a single comma separated field:  
`awk -F ", " '{print $1}' sh-int-brief`  
 `'Interface      IP-Address      Status     Protocol Vrf-Name'`

use sed to replace "," with newline and create columns:  
`sed 's/,/\n/g' sh-int-brief`
```yaml
'Interface                      IP-Address      Status          Protocol Vrf-Name'
'MgmtEth0/RP0/CPU0/0            10.125.252.248 Up              Up      management'
'MgmtEth0/RP1/CPU0/0            unassigned      Shutdown        Down     default '
'TenGigE0/0/0/0                 unassigned      Shutdown        Down     default '
'TenGigE0/0/0/1                 unassigned      Shutdown        Down     default '
```
combine sed and awk to filter as needed:

`sed 's/,/\n/g' sh-int-brief | awk '{print $1 "   " $3}'`
```yaml
'Interface   Status
'MgmtEth0/RP0/CPU0/0   Up
'MgmtEth0/RP1/CPU0/0   Shutdown
'TenGigE0/0/0/0   Shutdown
'TenGigE0/0/0/1   Shutdown
```
use Ansible to copy command output to a text file her host:
```yaml
- name: copy output to file
      copy:
        content: "{{ output.stdout[0] }}
        dest: "output-{{ inventory_hostname }}.txt"
```
then sed and awk to parse all text files and output Mgmt port info per host:  
`sed 's/,/\n/g' *.txt | awk '/Mgmt/ { print $0 }'`
```yaml
"MgmtEth0/RP0/CPU0/0            10.125.252.240 Up              Up       management"
"MgmtEth0/RP1/CPU0/0            unassigned      Shutdown        Down     default"]
"MgmtEth0/RP0/CPU0/0            unassigned      Up              Up       default "
"MgmtEth0/RP1/CPU0/0            10.125.252.241 Up              Up       management"]
```
use sed to parse multiple Ansible show and run commands:  
`sed 's/"/\n/g' sh_ver-10.125.252.240.txt | sed '1d;2d;3d;5d;6d;7d;9d;11d' | sed '/]/d'`
```yaml
hostname sitex-pe01
MgmtEth0/RP0/CPU0/0            100.125.252.240 Up              Up       management
MgmtEth0/RP1/CPU0/0            unassigned      Shutdown        Down     default
Cisco IOS XR Software, Version 6.8.2
```

#### awk string manipulation functions with gsub - global substitution  
`awk '{ gsub(/,/, "\n"); print }' sh-int-brief`  # global replace , with \n
```yaml
'Interface                      IP-Address      Status          Protocol Vrf-Name'
'MgmtEth0/RP0/CPU0/0            10.125.252.248 Up              Up       management'
'MgmtEth0/RP1/CPU0/0            unassigned      Shutdown        Down     default '
'TenGigE0/0/0/0                 unassigned      Shutdown        Down     default '
```
#### awk processing - BEGIN and END

**BEGIN** - awk will execute actions once before input is read

**END** - awk will execute actions before program exits

**awk flow**
- BEGIN - execute once
- input line is read
- patterns are compared, matches, and executed for all lines
- END - after all input lines exeucte these actions
