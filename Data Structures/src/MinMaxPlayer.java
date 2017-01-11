public class MinMaxPlayer implements AbstractPlayer//Δήλωση της κλάσης MinMaxPlayer
{
  // TODO Fill the class code.

  int score;//Δήλωση μεταβλητής score 
  int id;//Δήλωση μεταβλητής id που μας δείχνει το χρώμα του κάθε παίκτη
  String name;//Δήλωση μεταβλητής name που δηλώνεται το όνομα του παίκτη
  int [][]weight = new int [GomokuUtilities.NUMBER_OF_COLUMNS][GomokuUtilities.NUMBER_OF_ROWS];//Δήλωση του δισδιάστατου πίνακα weight τον οποίο χρησιμοποιήσαμε για να δώσουμε value κεντρικότητας σε κάθε τετράγωνο

  public MinMaxPlayer (Integer pid)//Δήλωση του constructor MinMaxPlayer
  {
    id = pid;//Εκχώρηση τιμής στην μεταβλητή id
    score = 0;//Αρχικοποιώ την μεταβλητή score
    setWeight();  //Κλήση της συνάρτησης weight
  }

  public String getName ()//Συνάρτηση επιστροφής του ονόματος του παίκτη
  {

    return "MinMax";//Επιστροφή του ονόματος του παίκτη

  }

  public int getId ()//Συνάρτηση επιστροφής του id του παίκτη
  {
    return id;//Eπιστροφή του id του παίκτη
  }

  public void setScore (int score)//Συνάρτηση που αναθέτει το σκορ του παίκτη
  {
    this.score = score; //εκχώρηση τιμής στην μεταβλητή score
  }

  public int getScore () //Συνάρτηση επιστροφής του σκορ του παίκτη
  {
    return score;  //Επιστροφή του σκορ του παίκτη
  }

  public void setId (int id) //Συνάρτηση που αναθέτει το id του παίκτη
  {
    this.id = id; // Εκχώρηση τιμής στην μεταβλητή id
  }

  public void setName (String name)  //Συνάρτηση που αναθέτει το name του παίκτη 
  {
    this.name = name; // Εκχώρηση τιμής στν μεταβλτή name
  }
  
  void setWeight(){ //Συνάρτηση που αναθέτει τιμές στον πίνακα Weight που αντιστοιχεί στο value κεντρικότητας των θέσεων
	  
	  weight[(GomokuUtilities.NUMBER_OF_COLUMNS-1)/2][(GomokuUtilities.NUMBER_OF_ROWS-1)/2] = 7; //Ανάθεση της τιμής 7 (μέγιστη τιμή του πίνακα) στο κεντρικότερο κελί του πίνακα 
	  //Διπλή επανάληψη για εκχώρηση τιμών στα τρίγωνα που ενώνουν την πάνω αριστερή γωνία και την κάτω αριστερή γωνία με το κέντρο καθώς και την πάνω δεξία και την κάτω δεξιά γωνία και το κέντρο του board.
	  for(int i = 0 ; i <= 6 ; i++ ){
		  for(int j = i ; j <= GomokuUtilities.NUMBER_OF_ROWS - i - 1 ; j++){
			  
			  weight[i][j] = i;  // Ανάθεση τιμών στα κελιά του πίνακα μέσω διπλής επανάληψης ανάλογα με την κεντρικότητα τους 
			  weight[GomokuUtilities.NUMBER_OF_COLUMNS-1-i][j] = i;   // Ανάθεση τιμών στα κελιά του πίνακα μέσω διπλής επανάληψης ανάλογα με την κεντρικότητα τους 
		  }
	  }
	  //Διπλή επανάληψη για εκχώρηση τιμών στα τρίγωνα που ενώνουν την πάνω αριστερή γωνία και την πάνω δεξιά γωνία με το κέντρο καθώς και την κάτω δεξιά και την κάτω αριστερή γωνία και το κέντρο του board.
	  for(int j = 0 ; j <= 6 ; j++ ){
		  for(int i = j ; i <= GomokuUtilities.NUMBER_OF_COLUMNS - j - 1 ; i++){
			  weight[i][j] = j;  // Ανάθεση τιμών στα κελιά του πίνακα μέσω διπλής επανάληψης ανάλογα με την κεντρικότητα τους 
			  weight[i][GomokuUtilities.NUMBER_OF_ROWS-1-j] = j;  // Ανάθεση τιμών στα κελιά του πίνακα μέσω διπλής επανάληψης ανάλογα με την κεντρικότητα τους 
		  }
	  }
}

  public int[][] getWeight(){ //Συνάρτηση επιστροφής του πίνακα  getWeight
	  
	  return weight;  //Επιστροφή τιμής του πίνακα που στο αντιστοιχεί στο value κεντρικότητας της θέσης x,y
	  
  }
  
  public int[] getNextMove ( Board board) //  Συνάρτηση που επιστρέφει την επόμενη κίνηση του παίκτη
  {

    // TODO Fill the code
	  int position = 0; // Δήλωση και εκχώρηση τιμής στην μεταβλητή position η οποία αποθηκεύει τον δείκτη που δείχνει στο παιδί του root με την max κίνηση 
	  int[] bestTile = {0,0}; // Πίνακας με τις συντεταγμένες της κίνησης που τελικά επιλέγεται 
	  Board instanceBoard = GomokuUtilities.cloneBoard(board); // Δήλωση της μεταβλητής instanceBoard και εκχώρηση ενός κλώνου του board
	  Node80127706 root = new Node80127706(null,0,instanceBoard,0); //Δήλωση μεταβλητής root τύπου Node80127706 και κλήση του αντίστοιχου constructor 
	  createMySubTree(root,1); // Κλήση της συνάρτησης createMySubtree με ορίσματα τον αρχικό κόμβο του δέντρου  και την μονάδα που αντιστοιχεί στο βάθος του παιδιού του root
	  position = chooseMove(root); // Εκχώρηση τιμής στην position μέσω κλήσης την συνάρτησης chooseMove με όρισμα root 
	  root = root.getChildren(position);  // Εκχώρηση τιμής στο root που αντιστοιχεί στο παιδί που μας δίνει την βέλτιση κίνηση 
	  if(position < 0){ // Έλεγχος για μη ύπαρξη παιδιού στο δέντρο
		  System.out.println("Houston we got a problem");
	  }else{ //Περίπτωση ύπαρξης παιδιού  
		  bestTile = root.getNodeMove(); //Εκχώρηση τιμής στην μεταβλητή bestTile με κλήση της συνάρτησης getNodeMove που επιστρέφει την βέλτιστη κίνηση
	  }
    return bestTile; // Επιστροφή μεταβλητής bestTile
  }

  private void createMySubTree(Node80127706 parent, int depth) //Δήλωση συνάρτησης που δημιουργεί την σειρά βάθους 1 του δέντρου
  {
    // TODO Fill the code
	  for(int i = 0 ; i < GomokuUtilities.NUMBER_OF_COLUMNS;i++){//Εκκίνηση επανάληψης για σάρωση όλου του ταμπλό
		  for(int j = 0 ; j < GomokuUtilities.NUMBER_OF_ROWS;j++){
			  if(parent.getNodeBoard().getTile(i, j).getColor() == 0){//Έλεγχος ύπαρξης κενού κελιού
				  Board cloneA = GomokuUtilities.cloneBoard(parent.getNodeBoard());//Εκχώρηση στην μεταβλητή cloneA τύπου Board το αντίγραφο του αρχικού ταμπλό
				  GomokuUtilities.playTile(cloneA, i, j, getId()); //Προσωμοίωση κίνησης στο αντίγραφο του ταμπλό
				  Node80127706 child = new Node80127706(parent,depth,cloneA,0);//Δήλωση αντικειμένου child
				  parent.setChildren(child);//Εκχώρηση αντικειμένου child στην ArrayList children του αντικειμένου parent
				  createOpponentSubTree(child,depth+1,i,j);//Κλήση συνάρτησης που υλοποιεί την σειρά βάθους 2 του δέντρου
			  }
		  }
	  }
	  
  }

  private void createOpponentSubTree (Node80127706 parent, int depth,int x,int y)//Δήλωση συνάρτησης που δημιουργεί την σειρά βάθους 2 του δέντρου
  {		
	// TODO Fill the code
	  int enemyId; //Δήλωση μεταβλητής enemyId
	  double myValue,enemyValue,value = 0 ;//Δήλωση μεταβλητής myValue,enemyValue και value
	  for(int i = 0 ; i < GomokuUtilities.NUMBER_OF_COLUMNS;i++){//Εκκίνηση επανάληψης για σάρωση όλου του ταμπλό
		  for(int j = 0 ; j < GomokuUtilities.NUMBER_OF_ROWS;j++){
			  if(parent.getNodeBoard().getTile(i, j).getColor() == 0){//Έλεγχος ύπαρξης κενού κελιού
				  Board cloneB = GomokuUtilities.cloneBoard(parent.getNodeBoard());//Εκχώρηση στην μεταβλητή cloneΒ τύπου Board το αντίγραφο του ταμπλό που έχει γίνει ήδη μία κίνηση από τον πρώτο παίκτη
				  if (getId()==1){//Έλεγχος ώστε να προσδιορίσουμε το id του άλλου παίκτη
					   enemyId=2;
				  }else {
					  enemyId=1;
				  }
				  GomokuUtilities.playTile(cloneB, i, j, enemyId);//Προσωμοίωση κίνησης στο αντίγραφο του νέου ταμπλό
				  Node80127706 child = new Node80127706(parent,depth,cloneB,0);//Δήλωση αντικειμένου child
				  myValue = child.evaluate(x, y,parent.getNodeBoard(),getId(), getWeight());//Εκχώρηση myValue με κλήση της συνάρτησης evaluate του αντικειμένου child με τα κατάλληλα ορίσματα
				  enemyValue = child.evaluate(i, j, cloneB,enemyId, getWeight());//Εκχώρηση enemyValue με κλήση της συνάρτησης evaluate του αντικειμένου child με τα κατάλληλα ορίσματα
				  if(myValue == 400){//Έλεγχος για σενάριο σίγουρης νίκης 
					  value = Double.POSITIVE_INFINITY;//Ανάθεση άπειρου value σε περίπτωση νίκης
				  }else if(enemyValue == 400){ // Σενάριο ήττας
					  value = Double.NEGATIVE_INFINITY; // Ανάθεση -άπειρου value σε περίπτωση ήττας
				  }else{
					  value = myValue - enemyValue; // Διαφορά του δίκους μας value από του αντιπάλου
				  }
				  child.setNodeMove(x, y); // Ανάθεση συντεταγμένων που θα χρησιμοποιηθούν 
				  child.setNodeEvaluation(value); // Ανάθεση value της θέσης που παίζεται
				  parent.setChildren(child); // Δήλωση παιδιού στο ArrayList του αντικειμένου parent
			  }
		  }
	  }
	  
  }

  private int chooseMove (Node80127706 root){   // Συνάρτηση επιλογής επόμενης κίνησης 
    // TODO Fill the code
	  double bestValue; // Μετάβλητη που θα αντιστοιχεί στο βέλτιστο value
	  Node80127706 exp; // Αντικείμενο προσώρινης αποθήκευσης του παιδιού του root(παιδί του αρχικού κόμβου) με την χειρότερη κίνηση
	  int flagPos = 0; // Δήλωση μεταβλητής flagPos όπου αποθηκεύεται η θέση του δέντρου με την καλύτερη κίνηση 
	  if(root.getFlag() == 0){ // Έλεγχος για μη ύπαρξη παιδιών 
		  return flagPos; // Επιστροφή θέσης με την καλύτερη κίνηση
	  }
	  bestValue = Double.NEGATIVE_INFINITY; // Αρχικοποίηση της μεταβλητής bestValue 
	  for (int i=0; i<root.getFlag(); i++){ // Επανάληψη από 0 μέχρι το πλήθος των παιδιών 
		  exp = MinMove(root.getChildren(i)); // Εκχώρηση στο αντικείμενο προσώρινης αποθήκευσης του παιδιού του root(παιδί του αρχικού κόμβου) με την χειρότερη κίνηση
		  root.getChildren(i).setNodeMove(exp.getNodeMove()[0],exp.getNodeMove()[1]); //Εκχωρούμε στο παιδί βάθους 1 τις συντεταγμένες της χειρότερης θέσης του υποδένδρου 
		  root.getChildren(i).setNodeEvaluation(exp.getNodeEvaluation()); //Εκχωρούμε στο παιδί βάθους 1 το value της χειρότερης θέσης του υποδένδρου του
		  if (root.getChildren(i).getNodeEvaluation()>=bestValue){ // έλεγχος για εύρεση της βέλτιστης διακλάδωσης του δένδρου
			  bestValue=root.getChildren(i).getNodeEvaluation(); //Εκχώρηση του βέλτιστου value του παιδιού του αρχικού κόμβου
			  flagPos = i;//Εκχώρηση του δείκτη που βλέπει την βέλτιστη κίνηση
		  }
	  }

	return flagPos;  //Επιστροφή του δείκτη της βέλτιστης κίνησης
  }
 
  
 private Node80127706 MinMove(Node80127706 root){ //Δήλωση και υλοποίηση της συνάρτησης MinMove που υπολογίζει την χειρότερη δυνατή κίνηση για εμάς και επιστρέφει το αντίστοιχο αντικείμενο
	 double worstValue;//Δήλωση μεταβλητής worstValue που αποθηκεύει το χειρότερο value του υποδέντρου
	 int flagPos = 0;//Δήλωση μεταβλητής flagPos που αποθηκεύει τον δείκτη της χειρότερης κίνησης στο υποδέντρο
	 if (root.getFlag()==0){//'Ελεγχος μη ύπαρξης παιδιού
		 return root;//Επιστροφή του αντικειμένου που αντιστοιχεί σε κόμβο με βάθος 1
	 }
	 worstValue = Double.POSITIVE_INFINITY;//Αρχικοποίηση της μεταβλητής worstValue
	 for (int i=0; i<root.getFlag();i++){//Εκκίνηση επανάληψης από το 0 μέχρι το πλήθος των παιδιών του root(κόμβος με βάθος 1)
		 if (root.getChildren(i).getNodeEvaluation()<=worstValue){//Έλεγχος για εύρεση της χειρότερης δυνατής διακλάδωσης για εμάς
			 worstValue=root.getChildren(i).getNodeEvaluation();//Καταχώρηση του value του χειρότερου κόμβου
			 flagPos=i; // Αποθήκευση του δείκτη του χειρότερου κόμβου
			 
		 }
	 }
	 return root.getChildren(flagPos);//Επιστροφή του αντικειμένου με την διακλάδωση που έχει το χειρότερο value   
	
 }
 
}
