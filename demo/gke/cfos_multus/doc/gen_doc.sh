filename="README.md"
echo "README" > $filename
files=$(ls -l ./../??_*.md | awk '{print $9}')
for file in $files; do
echo -e "\n" >> $filename
cat $file >> $filename
echo -e "\n" >> $filename
done
