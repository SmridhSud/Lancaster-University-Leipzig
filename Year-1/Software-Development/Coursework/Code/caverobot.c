/*
This program determines whether a path exist that allows the robot to reach an exit in maze

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define max_height 55
#define max_weight 55
#define max_queue 4000000

typedef struct {
    int r, c;
    int mask;
}node;

//Grid for maze
char grid[max_height][max_weight];
int h, w;

int total_pressure_plates[26];
int visit[max_height][max_weight][1 << 10];

int pressure_plate_index[26];
int pressure_plate_count = 0;

//movement of directions: down, up, right, left
int dr[4] = {1, -1, 0, 0};
int dc[4] = {0, 0, 1, -1};

typedef struct{
    int r, c;
}pos;

pos worm_holes[10][max_height *  max_weight];
int worm_count[10];

node queue[max_queue];

int main() {
    //width and height
    scanf("%d %d", &w, &h);

    int ir, ic; //start position

    for (int i = 0; i < h; i++){
        scanf("%s", grid[i]);

        for(int j = 0; j < w; j++){
            char ch = grid [i][j];

            if (ch == '='){
                ir = i;
                ic = j;
            }

            if (ch >= 'a' && ch <= 'z'){
                total_pressure_plates[ch - 'a']++;
            }

            /*wormhole position stored*/
            if (ch >= '1' && ch <= '9'){
                int d = ch -'0';
                worm_holes[d][worm_count[d]++] = (pos){i, j};

            }
        }
    }
    
    for (int i = 0; i < 26; i++){
        if (total_pressure_plates[i] > 0) {
            pressure_plate_index[i] = pressure_plate_count++;
        }else {
            pressure_plate_index[i] = -1;
        }
    }

    int front = 0, back = 0;

    /*robot position with no doors opened*/
    queue[back++] = (node){ir, ic, 0};
    visit[ir][ic][0] = 1;

    while (front < back) {
        node cur = queue[front++];

        int r = cur.r;
        int c = cur.c;
        int mask = cur.mask;

        //if we reach an exit, possible escape
        if (grid[r][c] == '!'){
            printf("Yes\n");
            return 0;
        }

        for(int d = 0; d < 4; d++){
            int nr = r + dr[d];
            int nc = c + dc[d];

            /*remains in maze boundaries*/
            if(nr < 0 || nr >= h || nc < 0 || nc >= w)
                continue;
            
            char cell = grid[nr][nc];

            /*skips walls*/
            if (cell == '#') continue;

            int mask_new = mask;

            if (cell >= 'A' && cell <= 'Z') {
                int id = pressure_plate_index[cell - 'A'];
                if (id == -1) continue;

                //check whether associated plate is activated
                if (!(mask & (1 << id))) continue;
            }

            /*pressure plate activation*/
            if (cell >= 'a' && cell <= 'z'){
                int original = cell - 'a';
                int id = pressure_plate_index[original];

                if(id != -1){

                    mask_new |= (1 << id);
                }
            }
            if (!visit[nr][nc][mask_new]){
                visit[nr][nc][mask_new] = 1;
                queue[back++] = (node){nr, nc,mask_new};
            }
            if(cell >= '1' && cell <= '9'){
                int dgt = cell - '0';
                for(int k = 0; k < worm_count[dgt]; k++){
                    int wr = worm_holes[dgt][k].r;
                    int wc = worm_holes[dgt][k].c;

                    if(!visit[wr][wc][mask_new]){
                        visit[wr][wc][mask_new] = 1;
                        queue[back++] = (node){wr, wc, mask_new};
                    }
                }
            }
        }
    }
    printf("No\n");
    return 0;
}