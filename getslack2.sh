#test
data= 'build/map.sym'
while read -r line
do 
    echo "$line" 
done < "$data"