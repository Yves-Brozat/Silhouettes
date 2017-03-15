class Onde extends SubSketch
{
   String[] alphabet = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"};
   int totalLetters = 30;
   String[] letters = new String[totalLetters];
   
   int mot = 0;
   
   int maxOndeLife = 3000;
   int maxCurOnde = 800;
   ArrayList<Integer> ondes;
   int m;

   public Onde(PApplet parent, int _width, int _height)
   {
      super(parent,_width,_height);
      name = "Onde";
      ondes = new ArrayList<Integer>();
      
      for (int i=0; i < totalLetters; i++) {
         letters[i] = alphabet[int(random(0, 26))];
      }
   }

   public void draw()
   {
      clear();
      m = millis();
           
      strokeWeight(2);
      textSize(30);
      for (int i = 0; i < ondes.size(); i++) {
         int curOnde = ondes.get(i);
         if (m > curOnde+maxOndeLife)
         {
            ondes.remove(i);
            i--;
            continue;
         }
         fill(0, 0, 0, map(m-curOnde, 0, maxOndeLife, 255, 0));

         for (int l = 0; l < totalLetters; l++) {
            if (m-curOnde > 0) {
               text(letters[(l+curOnde)%curOnde], cos(l+curOnde/10)*map(m-curOnde, 0, maxOndeLife, 0, maxCurOnde), sin(l+curOnde/10)*map(m-curOnde, 0, maxOndeLife, 0, maxCurOnde));
            }
         }
      }
   }
   
   public void keyPressed()
   {
      if (key == 'o') {
         ondes.add(m);
         ondes.add(m+100);
         ondes.add(m+200);
         println(ondes);
      }
   }
}