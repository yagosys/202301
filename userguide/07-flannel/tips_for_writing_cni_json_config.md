cni config is a json formmated file. 
here is some tips for make write json file easier

Use four spaces for indentation  Do not use tab characters in the code, always use spaces.
put one space after the name-separator (colon). for example "key": "value"
Obey the formal JSON format; in particular, wrap strings in double (not single) quotes.

below are some mistake they happen 

- #### included Tab key in the file. 
sometime, when you copy json file from browser webpage. it often include TAB key which will not be accpted by cni plugin.

although , you can create a CRD resource that include cni json config file. however, when the json file passed to CNI binary. CNI binary will complain.

you may use  grep to check whether your config include a tab key. 
```
grep -P '\t' test.conf
        "hairpinMode": true,
```


- #### unpaired {} , [] or missing separator  etc 

you may use jq tool to check the json file formatting and syntax errors

for example

```
jq  empty test.conf
parse error: Expected separator between values at line 15, column 14

```
