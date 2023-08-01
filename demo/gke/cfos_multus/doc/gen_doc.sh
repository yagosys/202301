filename="README.md"
echo "README" > $filename
files=$(ls -l ./../??_*.md | awk '{print $9}')
for file in $files; do
echo cat "$file" >> $filename
echo -e "\n" >> $filename
cat $file >> $filename
echo "end of $file" >> $filename
echo -e "\n" >> $filename
done
