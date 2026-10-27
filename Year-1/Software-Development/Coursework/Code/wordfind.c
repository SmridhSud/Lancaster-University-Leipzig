#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <limits.h>

int main(void){
    int a, b;
    if(scanf("%d %d", &a, &b) != 2){
        fprintf(stderr, "Failing to read a andb\n");
        return 1;
    }
    if(a <=0 || b <0){
        printf("-1\n");
        return 0;
    }

    char **grids = malloc(a * sizeof(char*));
    for(int i = 0; i < a; ++i){
        grids[i] = malloc((a+1) * sizeof(char));
        if(scanf("%s", grids[i]) != 1){
            fprintf(stderr, "Failing to read the grid lines %d\n", i);
            return 1;
        }

        for(int j = 0; j < a; ++j) grids[i][j] = (char)tolower((unsigned char)grids[i][j]);
    }

    long long mistakes_total = 0;

    const int row[4] = {0, 1, 1, -1};
    const int column[4] = {1, 0, 1, 1};

    const int maximum_allowed_string = 2000;
    char *words = malloc(maximum_allowed_string);

    for(int w = 0; w < b; ++w){
        int t;
        if(scanf("%d %s", &t, words) != 2){
            fprintf(stderr, "Failing to read words %d\n", w+1);
            return 1;
        }
        if(t>a){
            printf("-1\n");

            for(int i = 0; i < a; ++i) free(grids[i]);
            free(grids);
            free(words);
            return 0;
        }

        for(int e = 0; e < t; ++e) words[e] = (char)tolower((unsigned char)words[e]);

        int max = INT_MAX;

        for(int r = 0; r < a; ++r){
            for(int c = 0; c < a; ++c){
                for(int d = 0; d < 4; ++d){
                    int r_end = r + (t - 1) * row[d];
                    int c_end = c + (t-1) * column[d];

                    if(r_end < 0 || r_end >= a || c_end < 0 || c_end >= a) continue;

                    int mismatch_counter = 0;
                    int current_row = r, current_column = c;
                    for(int e=0; e < t; ++e){
                        if(grids[current_row][current_column] != words[e]) ++mismatch_counter;
                        current_row += row[d];
                        current_column += column[d];

                        if(mismatch_counter >= max) break;
                    }
                    if(mismatch_counter < max) max = mismatch_counter;
                }
            }
        }
        if(max == INT_MAX){
            printf("-1\n");
            for(int i = 0; i < a; ++i) free(grids[i]);
            free(grids);
            free(words);
            return 0;
        }
        mistakes_total += max;
    }
    printf("%lld\n", mistakes_total);

    for(int i = 0; i < a; ++i) free(grids[i]);
    free(grids);
    free(words);

    return 0;
}