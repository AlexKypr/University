import java.util.Scanner;//for reading the code
import java.util.ArrayList;//For array list
import java.io.FileWriter;//PartA lib for writing to a text file
import java.io.BufferedWriter;//PartA lib for writing to a text file
import java.io.IOException;//lib for encountering a problem in writing to a file
import java.io.File;//lib for files
import java.io.FileOutputStream;//PartB lib for writing streams of raw bytes(binary files)



public class virtualModem{
	public static void main(String []param){
		//init

		(new virtualModem()).menu();

	}

//START MENU
	public void menu(){
		for(;;){
			int choice;
			Scanner in = new Scanner(System.in);
			System.out.print("      User Application: \r\n");
			System.out.print("      1.Echo Request Code\r\n");
			System.out.print("      2.Image Error Free Request Code\r\n");
			System.out.print("      3.Image with Errors Request Code\r\n");
			System.out.print("      4.Gps Request Code(under construction)\r\n");
			System.out.print("      5.Nack/Ack Request Code\r\n");
			System.out.print("      6.Exit\r\n");
			System.out.print("Choose an application: ");
			try{
				choice = in.nextInt();
				if(choice == 1){
					echo();
				}else if(choice == 2){
					imageWithoutErrors();
				}else if(choice == 3){
					imageWithErrors();
				}else if(choice == 4){
					Gps();
				}else if(choice == 5){
					NackAck();
				}else if(choice == 6){
					return;
				}else{
					System.out.print("      WARNING:\r\n");
					System.out.print("You gave an unacceptable character try again!\r\n");
				}
			}catch(Exception x){
				System.out.print("      WARNING:\r\n");
				System.out.print("You gave an unacceptable character try again!\r\n");
			}

		}
	}
	//END MENU

	//Start ECHO
	public void echo(){

		int echoRequestCode,countP = 0,k,countLoopA = 0;
		long tStartTimeLoop = System.currentTimeMillis();
		long tEndTimeLoop = 0;
		long tDeltaTimeLoop = 0;
		long tStartInterval = 0,tEndInterval = 0,tDeltaInterval = 0;
		ArrayList<Long> sample = new ArrayList<Long>();
		String limit = "";//testing delimiter

		System.out.println("Enter the echo request code EXXXX for this session: ");
		Scanner in = new Scanner(System.in);
		echoRequestCode = in.nextInt();

		Modem modem = new Modem();
		modem.setSpeed(80000);
		modem.setTimeout(3000);
		modem.write("atd2310ithaki\r".getBytes());

		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				System.out.print((char)k);
			}catch (Exception x) {
				break;
			}
		}

		//
		//start of 5 minute loop
		while((tDeltaTimeLoop/1000.0) < 6*60){	//Because we want samples for at least 4 minutes i choose for about 5 minutes
			modem.write(("E"+Integer.toString(echoRequestCode)+"\r").getBytes());
			tStartInterval = System.currentTimeMillis();
			tEndInterval = 0;
			tDeltaInterval = 0;
			for(;;){
				try{
					k=modem.read();
					limit += (char)k;

					if((char)k == 'P'){
						countP++;
					}
					if(countP == 3){
						tEndInterval = System.currentTimeMillis();
						tDeltaInterval = tEndInterval - tStartInterval;
						countP = 0;
					}
					if(k == -1) break;
					System.out.print((char)k);
				}catch (Exception x) {
					break;
				}

			}
			System.out.print("\r\n");
			System.out.print(tDeltaInterval + "\r\n");
			sample.add(tDeltaInterval);
			tEndTimeLoop = System.currentTimeMillis();
			tDeltaTimeLoop = tEndTimeLoop - tStartTimeLoop;
			countLoopA++;
		}
		//End of 5 minute loop

		//START Saving to a file the results
		System.out.print("Count: " + countLoopA);
		System.out.print("\r\n");
		System.out.print("Loop Time: "+tDeltaTimeLoop);
		System.out.print("\r\n");
		for(int i = 0 ; i < countLoopA ; i++){
			System.out.print("Sample " + i + " "+ sample.get(i) +"\r\n");
		}
		//END Saving to a file the results

		//Start handle file
		BufferedWriter bw = null;
		try{
			File file = new File("Echo.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < countLoopA ; i++){
				bw.write("" + sample.get(i));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}
		finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}


		//End handle file
		modem.close();
	}

	//END ECHO

	//START IMAGE without ERRORS

	public void imageWithoutErrors(){
		int imageRequestCode;
		Scanner in = new Scanner(System.in);
		int countInt = 0,k;
		ArrayList<Integer> test = new ArrayList<Integer>();

		Modem modem = new Modem();
		modem.setSpeed(80000);
		modem.setTimeout(3000);
		modem.write("atd2310ithaki\r".getBytes());

		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				System.out.print((char)k);
			}catch (Exception x) {
				break;
			}
		}


		System.out.println("Enter the image request code MXXXX for this session:(error free) ");
		imageRequestCode = in.nextInt();
		modem.write(("M"+Integer.toString(imageRequestCode)+ " "+ "CAM=FIX"+"\r").getBytes());

		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				test.add(k);
				countInt++;
			}catch (Exception x) {
				break;
			}
		}
		String fileName = "image.jpeg";
		try{
				FileOutputStream outputStream = new FileOutputStream(fileName);
		//Converting int to byte and inserting bytes to image arraylist

			for(int i = 0 ; i < countInt ; i++){
				outputStream.write(test.get(i));
			}
			outputStream.close();
		}
		catch(IOException ex){
			System.out.println("error writing file");
		}
		modem.close();



	}



	//END IMAGE WITHOUT ERRORS

	//START IMAGE WITH ERRORS
	public void imageWithErrors(){

		ArrayList<Integer> test = new ArrayList<Integer>();
		int countInt = 0,k;
		int imageErrorRequestCode;
		Scanner in = new Scanner(System.in);

		Modem modem = new Modem();
		modem.setSpeed(80000);
		modem.setTimeout(3000);
		modem.write("atd2310ithaki\r".getBytes());

		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				System.out.print((char)k);
			}catch (Exception x) {
				break;
			}
		}


		System.out.println("Enter the image request code GXXXX for this session:(with errors) ");
		imageErrorRequestCode = in.nextInt();
		modem.write(("G"+Integer.toString(imageErrorRequestCode)+ " "+ "CAM=PTZ"+"\r").getBytes());


		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				test.add(k);
				countInt++;
			}catch (Exception x) {
				break;
			}
		}
		String fileName = "imageError.jpeg";
		try{
				FileOutputStream outputStream = new FileOutputStream(fileName);
		//Converting int to byte and inserting bytes to image arraylist

			for(int i = 0 ; i < countInt ; i++){
				outputStream.write(test.get(i));
			}
			outputStream.close();
		}
		catch(IOException ex){
			System.out.println("error writing file");
		}
		modem.close();


	}

	//END IMAGE WITH ERRORS

	//START GPS

	public void Gps(){

		int gpsRequestCode,k;
		int countInt = 0;
		Scanner in = new Scanner(System.in);
		String testString = "";
		int countChars = 0,countSamples = 0,hour,minutes,seconds,intTime;
		String timeStr = "",widthStr = "",heightStr = "";
		Modem modem = new Modem();
		modem.setSpeed(80000);
		modem.setTimeout(3000);
		modem.write("atd2310ithaki\r".getBytes());
		ArrayList<String> testStr = new ArrayList<String>();
		ArrayList<String> timeStrings = new ArrayList<String>();
		ArrayList<String> widthStrings = new ArrayList<String>();
		ArrayList<String> heightStrings = new ArrayList<String>();
		ArrayList<Integer> timer = new ArrayList<Integer>();
		ArrayList<String> widths = new ArrayList<String>();
		ArrayList<String> heights = new ArrayList<String>();
		ArrayList<Integer> test = new ArrayList<Integer>();
		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				System.out.print((char)k);
			}catch (Exception x) {
				break;
			}
		}


		System.out.println("Enter the gps request code PXXXX for this session: ");
		gpsRequestCode = in.nextInt();
		modem.write(("P"+Integer.toString(gpsRequestCode)+"R=1000199" +"\r").getBytes());


		for(;;){
			try{
				k=modem.read();
				testString += (char)k;
				if((testString.indexOf("GPGGA") > 0)&&(testString.indexOf("\r\n")>0)){
					testStr.add(testString);
					timeStrings.add(timeStr);
					widthStrings.add(widthStr);
					heightStrings.add(heightStr);
					heightStr = "";
					widthStr = "";
					testString = "";
					timeStr = "";
					countChars = 0;
					countSamples++;
				}else if((testString.indexOf("\r\n") > 0)&&(testString.indexOf("GPGGA") < 0)){
					testString = "";
				}else if((testString.indexOf("GPGGA") > 0)&&(testString.indexOf("\r\n") < 0)){
					countChars++;
					if(countChars>2 && countChars<9){
						timeStr += (char)k;
					}
					if(countChars>13 && countChars<23){
						widthStr += (char)k;
					}
					if(countChars>25 && countChars<36){
						heightStr += (char)k;
					}

				}

				if(k==-1) break;

			}catch (Exception x) {
				break;
			}
		}

		BufferedWriter bw = null;
		try{
			File file = new File("GPS.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < testStr.size() ; i++){
				bw.write(testStr.get(i));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}
		finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}




		for(int i = 0 ; i < countSamples ; i++){
			//Start time

			intTime = Integer.parseInt(timeStrings.get(i));
			hour  = intTime/10000;
			minutes = intTime/100;
			minutes = minutes % 100;
			seconds = intTime % 100;
			intTime = seconds + (minutes*60) + (hour*3600);
			timer.add(intTime);
			//System.out.print(intTime);
			//End time

			//start width
			String wid = widthStrings.get(i);
			String[] demo = new String [2];
			demo = wid.split("\\.");
			int intPart2;
			String width;

			intPart2 = Integer.parseInt(demo[1]);
			intPart2 = (intPart2 * 60)/10000;
			width = demo[0] + Integer.toString(intPart2);
			widths.add(width);


			//end width

			//start height
			String heig = heightStrings.get(i);
			String[] demo2 = new String [2];
			demo2 = heig.split("\\.");
			int intPart22,intPart12;
			String height;
			intPart22 = Integer.parseInt(demo2[1]);
			intPart22 = (intPart22 * 60)/10000;
			intPart12 = Integer.parseInt(demo2[0]);
			height = Integer.toString(intPart12) + Integer.toString(intPart22);
			heights.add(height);
			//end height

		}
		int start = timer.get(0);
		int countS = 1;
		int[] points = new int [5];
		points[0] = 0;
		String[] heightsArray = new String [5];
		String[] widthsArray = new String [5];
		heightsArray[0] = heights.get(0);
		widthsArray[0] = widths.get(0);
		for(int i = 1; i<countSamples;i++){

			if((timer.get(i)-start >=20) && (countS<5)){
				points[countS] = i;
				start = timer.get(i);
				heightsArray[countS] = heights.get(i);
				widthsArray[countS] = widths.get(i);
				countS++;

			}

		}
		String toSend = "P"+Integer.toString(gpsRequestCode);
		for (int i = 0 ; i < 4 ; i++){
			toSend += "T="+heightsArray[i]+widthsArray[i];
		}
		toSend += "\r\n";
		System.out.print(toSend);
			modem.write((toSend).getBytes());


			for(;;){
				try{
					k=modem.read();
					if(k==-1) break;
					test.add(k);
					countInt++;
				}catch (Exception x) {
					break;
				}
			}

			String fileName = "GPS.jpeg";
			try{
					FileOutputStream outputStream = new FileOutputStream(fileName);
			//Converting int to byte and inserting bytes to image arraylist

				for(int i = 0 ; i < countInt ; i++){
					outputStream.write(test.get(i));
				}
				outputStream.close();
			}
			catch(IOException ex){
				System.out.println("error writing file");
			}





		modem.close();
	}


	//END GPS

	//START NACKACK

	public void NackAck(){

		int[] stringCode = new int[16];
		int[] numCode = new int[3];
		int ackRequestCode,nackRequestCode,nextLoop = 1,flag = 0,countNack = 0,countStringCode,countNumCode,k,temp,countLoopD=0;
		int distanceCorrect,flagLoop,numCodeNumericValue = 0,countWrong,countTimes;
		long tStartTimeLoop,tEndTimeLoop,tDeltaTimeLoop,tStartInterval,tEndInterval,tDeltaInterval;
		String demoCorrect,demoWrong;
		float ber,L =0,prop;
		String stringBer = "";



		ArrayList<Integer> checkCorrect = new ArrayList<Integer>();
		ArrayList<Long> sample = new ArrayList<Long>();
		ArrayList<Integer> stringCodeList = new ArrayList<Integer>();
		ArrayList<Integer> repeatTimes = new ArrayList<Integer>();
		ArrayList<String> save = new ArrayList<String>();

		Modem modem = new Modem();
		modem.setSpeed(80000);
		modem.setTimeout(3000);
		modem.write("atd2310ithaki\r".getBytes());

		for(;;){
			try{
				k=modem.read();
				if(k==-1) break;
				System.out.print((char)k);
			}catch (Exception x) {
				break;
			}
		}



		Scanner in = new Scanner(System.in);
		System.out.println("Enter the ACK request code QXXXX for this session: ");
		ackRequestCode = in.nextInt();
		System.out.println("Enter the NACK request code RXXXX for this session: ");
		nackRequestCode = in.nextInt();
		System.out.println("\r\n");

		tStartTimeLoop = System.currentTimeMillis();
		tEndTimeLoop = 0;
		tDeltaTimeLoop = 0;

		while(((tDeltaTimeLoop/1000.0) < 6*60)||(nextLoop == -1)){
			if(nextLoop == 1){
				modem.write(("Q"+Integer.toString(ackRequestCode)+"\r\n").getBytes());
			}else if(nextLoop == -1){
				modem.write(("R"+Integer.toString(nackRequestCode)+"\r\n").getBytes());
				countNack++;
			}
			tStartInterval = System.currentTimeMillis();
			tEndInterval = 0;
			tDeltaInterval = 0;
			countStringCode = 0;
			countNumCode = 0;
			flag = 0;

			for(;;){
				try{
					k=modem.read();
					stringBer += (char)k;
					if((flag == 1)&&(countStringCode < 16)){
						stringCode[countStringCode] = k;
						countStringCode++;
					}
					if((flag == 2)&&(countNumCode < 3)){
						numCode[countNumCode] = k;
						countNumCode++;

					}
					if((char)k == '<'){
						flag = 1;
					}else if(((char)k == ' ')&&(flag == 1)){
						flag = 2;
					}else if(((char)k == 'P')&&(flag == 2)){
						flag = 3;
					}else if(((char)k == 'P')&&(flag == 3)){
						tEndInterval = System.currentTimeMillis();
						tDeltaInterval = tEndInterval - tStartInterval;
						L = stringBer.getBytes("utf8").length;
						stringBer = "";
					}

					if(k==-1) break;
					System.out.print((char)k);
				}catch (Exception x) {
					break;
				}

			}
			for(int i = 0 ; i < 16; i++){
			stringCodeList.add(stringCode[i]);
			}

			temp = 0;
			for(int i = 0 ; i < 16 ; i++){
				temp = temp^stringCode[i];
			}

			numCodeNumericValue = 0;
			for(int i = 0;i < 3 ; i++){
				numCodeNumericValue += ((int)Math.pow(10,2-i))*Character.getNumericValue(numCode[i]);
			}
			if(temp == numCodeNumericValue){
				nextLoop = 1;//ACK
				checkCorrect.add(1);
			}else{
				nextLoop = -1;//NACK
				checkCorrect.add(0);
			}
			System.out.print("\r\n");
			System.out.print(tDeltaInterval + "\r\n");
			sample.add(tDeltaInterval);
			tEndTimeLoop = System.currentTimeMillis();
			tDeltaTimeLoop = tEndTimeLoop - tStartTimeLoop;
			countLoopD++;//size of arrayList checkCorrect and the times the loop enters


		}

		//BER start
		prop = (float)(countLoopD-countNack)/countLoopD;
		ber = (float)(1.0 - Math.pow(prop,1.0/L));
		System.out.print("Ber: " + ber);
		System.out.print("\r\n");
  	//BER end

		//Propability Of Success Start
		distanceCorrect = 0;
		flagLoop = 0;
		countWrong = 0;
		int maxRepeat = 1;
		for(int i = 0 ; i < countLoopD ; i++){

			if(checkCorrect.get(i) == 1){
				distanceCorrect = 1 + countWrong;
				countWrong = 0;
				repeatTimes.add(distanceCorrect);
				if(maxRepeat < distanceCorrect){
					maxRepeat = distanceCorrect;
				}
			}else if(checkCorrect.get(i) == 0){
				countWrong++;
			}
		}
		countTimes = 0;
		for(int i = 1 ; i <= maxRepeat ;i++){
			for(int j = 0; j < repeatTimes.size();j++){
				if(repeatTimes.get(j) == i){
					countTimes++;
				}
			}



			System.out.print("Send " + i + " time(s) " + countTimes + "packets.\r\n");
			save.add(""+i + " " + countTimes + " BER: " + ber);
			countTimes = 0;

		}
		//POS End

		//handle file 2nd time
		BufferedWriter bw = null;
		try{
			File file = new File("NackAck.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < countLoopD ; i++){
				bw.write(""+ sample.get(i));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}
		finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}
		//end handle file

		BufferedWriter nw = null;
		try{
			File file = new File("NackAckProp.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter lw = new FileWriter(file);
			nw = new BufferedWriter(lw);
			for(int i = 0 ; i < save.size() ; i++){
				nw.write(save.get(i));
				nw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}
		finally{
			try{
				if(nw != null) nw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}



		modem.close();
	}
	//END NACKACK
}
