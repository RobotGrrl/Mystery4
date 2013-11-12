
void createLogger() {
  output = createWriter("log/log_" + hour() + "-" + minute() + "_" + day() + "_" + month() + ".txt");  
}

void logItem(String s) {
  output.println( (tick + "," + s) );
}

void stopLog() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file 
}

/*
we'll nickname this 'FH' for 'First Hit'
it's measuring the number of ticks it takes to go from the
start of triggering the attraction from O0 to A0, to when
they are first noted in proximity to each other (inside of
updateProximities).

amount of time (in seconds) it takes to run this test...
10 seconds to start
30 seconds for each trigger num
*/
void logFirstHitTest() {
 
 if(numTriggers < triggerLim) {
    if(prevTrigger == 0 && tick >= 30*10) {
      println("triggered!");
      runningBehaviour = 1;
      prevTrigger = tick;
      numTriggers++;
    } else if(tick-prevTrigger >= 30*30) {
      println("triggered!");
      runningBehaviour = 1;
      prevTrigger = tick;
      numTriggers++;
    }
  } else if(runningBehaviour == 99) {
    println("done");
    stopLog();
    exit(); 
  }
  
}

// numtriggers, tick, (firstRecO0A0-startBehaviour), desc
void logItemFH(int i, String s) {
  output.println( (numTriggers + "," + tick + "," + i + "," + s) );
}


