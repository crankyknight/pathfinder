class Node {
  int row_num, col_num, openSet_index;
  private float gscore, hscore, fscore; 

  Node(int row_num, int col_num){
    this.row_num = row_num;
    this.col_num = col_num;
  }

  void setGscore(float gscore){
      this.gscore = gscore;
  }
  void setHscore(float hscore){
      this.hscore = hscore;
  }
  void setFscore(float fscore){
      this.fscore = fscore;
  }
  float getGscore(){
      return this.gscore; 
  }
  float getHscore(){
      return this.hscore; 
  }
  float getFscore(){
      return this.fscore; 
  }
}

/*Functions taken from :
http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#a-stars-use-of-the-heuristic */
float calGscore(Node start, Node end){
  int dx = abs(start.col_num - end.col_num);
  int dy = abs(start.row_num - end.row_num);
  return ((dx+dy) + (sqrt(2) - 2)*(min(dx,dy)));
}
float calHscore(Node start, Node end){
  int dx = abs(start.col_num - end.col_num);
  int dy = abs(start.row_num - end.row_num);
  return ((dx+dy) + (sqrt(2) - 2)*(min(dx,dy)));
}
  
//Priority queue implementation
class openSet_ops{
  Node[] openSet;
  int openSet_size;
  
  openSet_ops(){
    openSet = new Node[NUM_BOX*NUM_BOX];
    openSet_size = 0;
  }
  
  public void Push(Node n)
  {
    openSet[openSet_size] = n;
    openSet_size++;
    if(openSet_size > 1){
      heapify_openSet_push(openSet_size);
    } else {
      n.openSet_index = 0;
    }
    //For debug
    //print_openSet();
    return;
  }
  
  private void heapify_openSet_push(int size)
  {
      int largest = size;  
      if(size == 1) return;
      if(openSet[largest-1].getFscore() < openSet[(size/2) - 1].getFscore())
        largest = (size/2);
      
      if (largest != size){
        swap(largest-1,size-1);
        heapify_openSet_push(largest);
      }
      return;
  }
  
  private void heapify(int size, int i)
  {
    int smallest = i;
    int l = (2*i + 1) < size ? 2*i + 1 : i;
    int r = (2*i + 2) < size ? 2*i + 2 : i;
    if(openSet[smallest].getFscore() > openSet[l].getFscore()){
      smallest = l;
    }
    if(openSet[smallest].getFscore() > openSet[r].getFscore()){
      smallest = r;
    }
    if(smallest != i){
      swap(smallest, i);
      heapify(size,smallest);
    }
    return;
  }

  public void rev_heapify(int i){
    int parent = (i-1)/2;
    while(parent >= 0){
        if(openSet[i].getFscore() < openSet[parent].getFscore()){
            swap(i, parent);
            i = parent;
            parent = (i-1)/2;
        } else {
            break;
        }
    }
  }
  
  public Node Pop()
  {
    if(openSet_size > 0){
      //Swap largest elemtent(1st) with last
      Node smallest = openSet[0];
      swap(0, openSet_size-1);
      openSet_size--;
      heapify(openSet_size,0);
      return smallest; 
    } else {
      return null;
    }
  }
  
  private void swap(int a, int b)
  {
     Node temp = openSet[a];
     openSet[a] = openSet[b];
     openSet[b] = temp;
     /*Set indices */
     openSet[a].openSet_index = a;
     openSet[b].openSet_index = b;
  }

  private void print_openSet(){
      int i;
      for(i=0; i< openSet_size; i++){
          print(openSet[i].getFscore() + ",");
      }
  }
}
