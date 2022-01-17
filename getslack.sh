#get and concatenates the relevant lines
data=$(grep -o 'SLACK: \$....\|EMPTY\|\(\(ROM\|WRAM\)[01X]\|HRAM\) bank #[[:digit:]]\+' build/map.sym)
#test="test"
#echo $test
#kill newlines
#data=${data//"\n"/" "}
#data=$(sed 's/\n$//g' <<< "$data")
#awk needs numbers denoted as such
#data=${data//"\$"/"0x"}
#specify number for empty banks
#data=${data//"EMPTY"/"0x4000"}
#echo $data
#romx=$(grep -o 'ROM[0X] bank #[[:digit:]]\+' <<< "$data")
#od -c <<< "$data"
#echo $data
#
#so now we can grab all the romx numbers with sed, and then add them with awk?
#
#
#we can use awk like this
#echo 0x4000 | awk --non-decimal-data '{ printf "%x\n", $1, $1 }'
#echo $lines
#
#
#until i get the rest figured out, here's the simple print
grep -o 'SLACK: \$....\|EMPTY\|\(\(ROM\|WRAM\)[01X]\|HRAM\) bank #[[:digit:]]\+' build/map.sym