/* Change these for default */
final int NUM_BOX = 120;
final int DEFAULT_BOX_SIZE = 640 / NUM_BOX;
final int INVALID_BOX = -999;
final int NUM_NEIGH = 8;
/***********************************/

int num_box = NUM_BOX;
int box_size = DEFAULT_BOX_SIZE;
boolean redraw = true;
boolean start_astar = true;
boolean astar_active = true;
float xo=0, yo = 0;
float zoom = 1;
Node start = null, end = null;

Box[][] obj_arr = new Box[NUM_BOX][NUM_BOX]; 
openSet_ops openSet = new openSet_ops();

void init_objs(Box[][] objArr, int maxNumBox) {
    /*Allocate new objects*/
    for(int i = 0; i< maxNumBox; i++) {
        for(int j = 0; j < maxNumBox; j++) {
            objArr[i][j] = new Box();
        }
    }
}

void setup() {
    size(650, 650); // 50*13
    smooth();
    init_objs(obj_arr, NUM_BOX);   
}

void draw() {
    if(redraw){
      background(200,200,200);     
      translate(xo,yo);
      scale(zoom);
      strokeWeight(1/zoom);
      for(int i=0; i<num_box; i++){
          for(int j=0; j<num_box; j++){
              fill(obj_arr[i][j].fill_val[0],obj_arr[i][j].fill_val[1],obj_arr[i][j].fill_val[2]);
              rect(j*box_size, i*box_size, box_size, box_size);
          }
      }
      redraw = false;
    }
    
    if(keyPressed && mousePressed){
        if(mouseButton == LEFT){
            int col_num = (int)((mouseX - xo)/(box_size * zoom));
            int row_num = (int)((mouseY - yo)/(box_size * zoom));
            if(col_num>=0 && col_num<NUM_BOX &&
                    row_num >=0 && row_num<NUM_BOX){
              if(key == 's') {
                  obj_arr[row_num][col_num].setFill(255, 0 ,0);
                  start = new Node(row_num, col_num);
                  redraw = true;
              }
              if(key == 'e') {
                  obj_arr[row_num][col_num].setFill(0, 255, 0);
                  end = new Node(row_num, col_num);
                  redraw = true;
              }
              if(start!=null && end!=null && start_astar){
                 // Start node hscore = fscore;
                 start.setGscore(0);
                 start.setFscore(calHscore(start, end));
                 start.setHscore(start.getFscore());
                 obj_arr[start.row_num][start.col_num].setNode(start);
                 obj_arr[start.row_num][start.col_num].setOpen();
                 openSet.Push(start);    
                 end.setHscore(0);
                 start_astar = false;
              }
            }
        }
    } else if(mousePressed && mouseButton == LEFT){      
        int col_num = (int)((mouseX - xo)/(box_size * zoom));
        int row_num = (int)((mouseY - yo)/(box_size * zoom));
        if(col_num>=0 && col_num<NUM_BOX &&
                    row_num >=0 && row_num<NUM_BOX){
          obj_arr[row_num][col_num].setFill(0, 0, 0);
          redraw = true;
        }
    } else if(keyPressed){
        float grid_side = num_box * box_size;
        if(key == CODED){
          if(keyCode == LEFT && xo < 50){
              xo += 3;
              redraw = true;
          }
          else if(keyCode == RIGHT && xo > -((grid_side*zoom) - 600)){ 
          /* ((num_box - 650(screen size)/(zoom*box_size) - constant(50 here)) * (box_size*zoom)) */
              xo -= 3;
              redraw = true;
          }
          else if(keyCode == UP && yo < 50){
            yo += 3;
            redraw = true;
          }
          else if(keyCode == DOWN && yo > -((grid_side*zoom) - 600)){
            yo -= 3;
            redraw = true;
          }
        }
    }
    /* A* algorithm */
    run_A_star();  
}

void mouseWheel(MouseEvent event) {
  if(keyPressed && key == CODED && keyCode == CONTROL){
    float e = event.getCount();
    if(e>0){
      zoom += 0.03;
      redraw = true;
    } else {      
      zoom -= 0.03;     
      redraw = true;
    }
  }
}

void run_A_star() {
    Node n, new_n;
    int i;
    float gscore_temp;
    int [][] neighbours;
    if((n=openSet.Pop()) != null && astar_active){
      if(n.row_num==end.row_num && n.col_num==end.col_num){
        /*Goal reached */
        println("Goal reached!!!");
        highlight_best_path();
        astar_active = false;
      } else {
          obj_arr[n.row_num][n.col_num].setClosed();
          //For debug
          //println("Closing : " + n.row_num + ", " + n.col_num);
          obj_arr[n.row_num][n.col_num].setFill(255, 170, 60);
          
          neighbours = getNeighbours(n.row_num, n.col_num);
          for(i=0;i<NUM_NEIGH;i++){
            int row_num = neighbours[i][0];
            int col_num = neighbours[i][1];
            if(row_num == INVALID_BOX || col_num == INVALID_BOX)
              continue;
            
            if(obj_arr[row_num][col_num].isClosed())
              continue;
            
            if(obj_arr[row_num][col_num].isWall()){
              /*Close wall boxes */
              obj_arr[row_num][col_num].setClosed();
              continue;
            }
            new_n = new Node(row_num, col_num);
            gscore_temp = obj_arr[n.row_num][n.col_num].node.getGscore() +
                            calGscore(n, new_n);
            if(obj_arr[row_num][col_num].isOpen()){
                if(gscore_temp >= obj_arr[row_num][col_num].node.getGscore())
                   continue;
                else{
                  /*This gscore is lower. Replace old params */
                  obj_arr[row_num][col_num].node.setGscore(gscore_temp);
                  float new_hscore = calHscore(new_n, end);
                  obj_arr[row_num][col_num].node.setHscore(new_hscore);
                  obj_arr[row_num][col_num].node.setFscore(gscore_temp + new_hscore);
                  obj_arr[row_num][col_num].setCameFrom(n.row_num, n.col_num);
                  obj_arr[row_num][col_num].setFill(66, 158, 244);
                  /*Maintain heap */
                  openSet.rev_heapify(obj_arr[row_num][col_num].node.openSet_index);
                }
            } else {
              /*If control comes here, we know it also cannot be closed,
              as close is already checked. Here the node is new and should be added to 
              openSet*/
              new_n.setGscore(gscore_temp);
              float new_hscore = calHscore(new_n, end);
              new_n.setHscore(new_hscore);
              new_n.setFscore(gscore_temp + new_hscore);
              obj_arr[row_num][col_num].setNode(new_n);  
              obj_arr[row_num][col_num].setCameFrom(n.row_num, n.col_num);
              openSet.Push(new_n);
              obj_arr[row_num][col_num].setOpen();  
              obj_arr[row_num][col_num].setFill(66, 158, 244);
            }
            
          }
      }
      redraw = true;
    } else if((n=openSet.Pop()) == null && astar_active && start!=null && end!=null){
        println("No path possible from start to end!! Exiting...");
        obj_arr[start.row_num][start.col_num].setFill(255, 0, 0);
        astar_active = false;
        redraw = true;
    }
}
