#ifndef MYFILEFUNCTIONS_H
#define MYFILEFUNCTIONS_H

/* Reads and prints the contents of a file to stdout (similar to cat).
 * Returns 0 on success, -1 on failure.
 */
int mycat(const char *filename);

/* Counts lines and words in a file.
 * Returns 0 on success, -1 on failure.
 */
int myfile_stats(const char *filename, int *line_count, int *word_count);

/* Searches for occurrences of a pattern in a file and prints matching lines.
 * Returns the number of matching lines found, or -1 on file read failure.
 */
int mygrep(const char *filename, const char *pattern);

#endif /* MYFILEFUNCTIONS_H */