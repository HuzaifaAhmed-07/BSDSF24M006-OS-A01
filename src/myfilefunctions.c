#include "myfilefunctions.h"
#include "mystrfunctions.h"
#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 1024

int mycat(const char *filename) {
    if (!filename) return -1;
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        perror("Error opening file in mycat");
        return -1;
    }

    char buffer[BUFFER_SIZE];
    while (fgets(buffer, sizeof(buffer), fp)) {
        fputs(buffer, stdout);
    }

    fclose(fp);
    return 0;
}

int myfile_stats(const char *filename, int *line_count, int *word_count) {
    if (!filename || !line_count || !word_count) return -1;
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        perror("Error opening file in myfile_stats");
        return -1;
    }

    *line_count = 0;
    *word_count = 0;
    char buffer[BUFFER_SIZE];

    while (fgets(buffer, sizeof(buffer), fp)) {
        (*line_count)++;
        *word_count += mywordcount(buffer);
    }

    fclose(fp);
    return 0;
}

int mygrep(const char *filename, const char *pattern) {
    if (!filename || !pattern) return -1;
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        perror("Error opening file in mygrep");
        return -1;
    }

    char buffer[BUFFER_SIZE];
    int line_number = 0;
    int matches = 0;

    while (fgets(buffer, sizeof(buffer), fp)) {
        line_number++;
        if (strstr(buffer, pattern) != NULL) {
            printf("%s:%d: %s", filename, line_number, buffer);
            matches++;
        }
    }

    fclose(fp);
    return matches;
}