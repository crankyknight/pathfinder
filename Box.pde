class Box {
    private int[] fill_val = {255, 255, 255};
    boolean open = false;
    boolean closed = false;
    Node node = null;
    int[] cameFrom = {-1, -1};
    void reInit(){
      fill_val = new int[] {255, 255, 255};
    }

    void setFill(int r, int g, int b){
      fill_val = new int[] {r, g, b};  
    }
    
    boolean isWall(){
      if(fill_val[0] == 0 && fill_val[1] == 0 && fill_val[2] == 0){
        return true;
      } else {
        return false;
      }     
    }
    
    void setOpen(){
      this.open = true;
      this.closed = false;
    }
    void setClosed(){
      this.open = false;
      this.closed = true;
    }
    boolean isOpen(){
      if(this.open)
        return true;
      else 
        return false;
    }
    boolean isClosed(){
      if(this.closed)
        return true;
      else 
        return false;
    }
    void setNode(Node n){
      this.node = n;
    }
    Node getNode(){
      return this.node;
    }
    void setCameFrom(int row_num, int col_num){
        this.cameFrom[0] = row_num;
        this.cameFrom[1] = col_num;
    }
    int[] getCameFrom(){
        return this.cameFrom;
    }
    
}

int[][] neighbour_offsets = {{-1,-1}, {-1,0}, {-1,1},
                             {0, -1}, /*Box*/ {0, 1},
                             {1, -1}, {1, 0}, {1, 1}};
int[][] getNeighbours(int row_num, int col_num){
      int[][] neighbours = new int[8][2];
      int i;
      for(i=0;i<NUM_NEIGH;i++){
        neighbours[i][0] = (row_num  + neighbour_offsets[i][0] < 0 || 
                           row_num + neighbour_offsets[i][0] >= NUM_BOX) ? 
                           INVALID_BOX : row_num+neighbour_offsets[i][0];
        neighbours[i][1] = (col_num  + neighbour_offsets[i][1] < 0 || 
                           col_num + neighbour_offsets[i][1] >= NUM_BOX) ? 
                           INVALID_BOX : col_num+neighbour_offsets[i][1];
      }
      return neighbours;
    }

void highlight_best_path(){
    int[] cameFrom = {end.row_num, end.col_num};
    /*Make sure end node is green */
    obj_arr[end.row_num][end.col_num].setFill(0, 255, 0);
    while((cameFrom[0] != start.row_num) || (cameFrom[1] != start.col_num)){
        cameFrom = obj_arr[cameFrom[0]][cameFrom[1]].getCameFrom();
        obj_arr[cameFrom[0]][cameFrom[1]].setFill(217, 244, 66);
    }
    /*Make sure start node is red */
    obj_arr[start.row_num][start.col_num].setFill(255, 0, 0);
}
