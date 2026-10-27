/*
This program identifies the optimal location of a lighthouse using elevation data while adhering to the constraints imposed by the Treaty of Erebus

The lighthouse must be reachable from research station(x, y) via that does not cross terrain exceeding elevation k
A  lighthouse must be constructed at position where ground elevation is less than or equal to k

output: 
The program outputs the maximum number of locations visible from valid lighthouse placement, or -1 if no such placement is possible
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

//define maximum size for the map to reserve memory
#define max_map_size 505

int grid[max_map_size][max_map_size]; //elevation points stored
bool reach[max_map_size][max_map_size];

typedef struct{
    int x, y;
} node;

node queue[max_map_size*max_map_size];
int head = 0, tail = 0;

void queue_a(int x, int y){
    queue[tail++] = (node){x, y};
}

node queue_b(){
    return queue[head++];
}

bool empty(){
    return head == tail;
}

int main(){
    int n, k, begin_a, begin_b;
    //it reads map dimension, max height, and research station coordinates
    if(scanf("%d %d %d %d", &n, &k, &begin_a, &begin_b) != 4) return 0;

    int max_height = -1;
    int visibile_max = -1;
    //elevation data
    for(int j = 0; j < n; j++){
        for(int i = 0; i < n; i++){
            scanf("%d", &grid[j][i]);
            if(grid[j][i] > max_height){
                max_height = grid[j][i];
            }
        }
    }

    begin_a--;
    begin_b--;

    memset(reach, 0, sizeof(reach));
    head = tail = 0;

    if(grid[begin_b][begin_a] <= k){
        queue_a(begin_a, begin_b);
        reach[begin_b][begin_a]= true;
    }

    int dx[] = {0,0,1,-1};
    int dy[] = {1,-1,0,0};
    while(!empty()){
        node current = queue_b();
        for (int i = 0; i < 4; i++){
            int nx = current.x + dx[i];
            int ny = current.y + dy[i];

            if(nx >= 0 && nx < n && ny >= 0 && ny < n){
                if(!reach[ny][nx] && grid[ny][nx] <= k){
                    reach[ny][nx] = true;
                    queue_a(nx, ny);
                }
            }
        }
    }
    int total_covered = -1;

    for(int j = 0; j < n; j++){
        for(int i = 0; i<n; i++){
            if(!reach[j][i])
            continue;

            int cover_current = 1;

            for(int x=0; x<4; x++){
                int nx = i + dx[x];
                int ny = j + dy[x];
            
                int current_height = grid[j][i];
                
                while(nx>=0 && nx < n && ny >= 0 && ny < n){
                    if(grid[ny][nx] > current_height || grid[ny][nx] > k) break;

                    cover_current++;
                    current_height  = grid[ny][nx];

                    nx += dx[x];
                    ny += dy[x];
                }
            }
            if(cover_current > visibile_max){
                visibile_max = cover_current;
            }
        }
    }

    printf("%d\n", visibile_max);
    return 0;
}