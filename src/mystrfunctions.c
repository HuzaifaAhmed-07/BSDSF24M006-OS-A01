#include "mystrfunctions.h"
#include <ctype.h>

size_t mystrlen(const char *str) {
    size_t len = 0;
    if (!str) return 0;
    while (str[len] != '\0') {
        len++;
    }
    return len;
}

char *mystrrev(char *str) {
    if (!str) return NULL;
    size_t len = mystrlen(str);
    if (len <= 1) return str;

    size_t i = 0;
    size_t j = len - 1;
    while (i < j) {
        char temp = str[i];
        str[i] = str[j];
        str[j] = temp;
        i++;
        j--;
    }
    return str;
}

int mystrcmp(const char *str1, const char *str2) {
    if (!str1 && !str2) return 0;
    if (!str1) return -1;
    if (!str2) return 1;

    while (*str1 && (*str1 == *str2)) {
        str1++;
        str2++;
    }
    return (unsigned char)*str1 - (unsigned char)*str2;
}

int mywordcount(const char *str) {
    if (!str) return 0;
    int count = 0;
    int in_word = 0;

    while (*str) {
        if (isspace((unsigned char)*str)) {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            count++;
        }
        str++;
    }
    return count;
}