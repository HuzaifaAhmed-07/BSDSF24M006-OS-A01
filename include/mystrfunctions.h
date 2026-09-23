#ifndef MYSTRFUNCTIONS_H
#define MYSTRFUNCTIONS_H

#include <stddef.h>

/* Returns the length of the string str */
size_t mystrlen(const char *str);

/* Reverses the string str in-place and returns it */
char *mystrrev(char *str);

/* Compares str1 and str2 lexicographically.
 * Returns negative if str1 < str2, 0 if equal, positive if str1 > str2
 */
int mystrcmp(const char *str1, const char *str2);

/* Counts and returns the total number of words separated by whitespace */
int mywordcount(const char *str);

#endif /* MYSTRFUNCTIONS_H */
