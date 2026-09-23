#include <stdio.h>
#include <string.h>
#include "mystrfunctions.h"
#include "myfilefunctions.h"

int main(void) {
    printf("===========================================\n");
    printf("   TESTING STRING FUNCTIONS (mystrfunctions)\n");
    printf("===========================================\n");

    const char *sample_text = "Operating Systems Assignment Core Utilities";
    printf("Original text: \"%s\"\n", sample_text);
    printf("Length: %zu\n", mystrlen(sample_text));
    printf("Word count: %d\n", mywordcount(sample_text));

    char rev_buffer[100];
    strcpy(rev_buffer, "Hello World");
    printf("\nReversing \"%s\":\n", rev_buffer);
    mystrrev(rev_buffer);
    printf("Reversed: \"%s\"\n", rev_buffer);

    printf("\nString comparison:\n");
    printf("mystrcmp(\"apple\", \"banana\") = %d\n", mystrcmp("apple", "banana"));
    printf("mystrcmp(\"test\", \"test\")     = %d\n", mystrcmp("test", "test"));

    printf("\n===========================================\n");
    printf("   TESTING FILE FUNCTIONS (myfilefunctions)\n");
    printf("===========================================\n");

    /* Create a temporary test file */
    const char *dummy_file = "test_sample.txt";
    FILE *fp = fopen(dummy_file, "w");
    if (fp) {
        fputs("First line of dummy file.\n", fp);
        fputs("Second line contains target word.\n", fp);
        fputs("Third line with target word again.\n", fp);
        fclose(fp);
    }

    printf("1. Content display via mycat:\n");
    mycat(dummy_file);

    int lines = 0, words = 0;
    if (myfile_stats(dummy_file, &lines, &words) == 0) {
        printf("\n2. File stats -> Lines: %d, Words: %d\n", lines, words);
    }

    printf("\n3. Pattern search via mygrep for 'target':\n");
    int matches = mygrep(dummy_file, "target");
    printf("Total matches: %d\n", matches);

    /* Clean up temporary file */
    remove(dummy_file);

    printf("\nAll module tests completed successfully.\n");
    return 0;
}