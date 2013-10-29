
void createLogger() {
  output = createWriter("log_" + hour() + "-" + minute() + "_" + day() + "_" + month() + ".txt");  
}

void logItem(String s) {
  output.println( (tick + "," + s) );
}

void stopLog() {
  output.flush(); // Writes the remaining data to the file
  output.close(); // Finishes the file 
}
