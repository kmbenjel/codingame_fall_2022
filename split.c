/**

make ft_split() that takes a string and a character as arguments and returns an array of strings obtained by splitting the string at the character.

prototype: ft_split(const char *str, char c);


*/
if(!str)
	return NULL;	// if str is NULL, return NULL
int i = 0;
int j = 0;
int k = 0;
int count = 0;
while(str[i] != '\0')	// count the number of words
{
	if(str[i] == c)
		count++;
	i++;
}
