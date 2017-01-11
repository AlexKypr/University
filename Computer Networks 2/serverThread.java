import java.net.*;
import java.io.*;
import java.util.Scanner;
import java.util.ArrayList;//For array list
import javax.sound.sampled.*;//For write and play for audio
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class serverThread{

	public static void main(String []param){

		(new serverThread()).menu();

	}


	public void menu(){
		for(;;){
			int choice;
			Scanner in = new Scanner(System.in);
			System.out.print(" User Application: \r\n");
			System.out.print(" 1.Echo Request Code \r\n");
			System.out.print(" 2.Image Request Code\r\n");
			System.out.print(" 3.Sound Request Code(DPCM)\r\n");
			System.out.print(" 4.Sound Request Code(AQDPCM)\r\n");
			System.out.print(" 5.Ithakicopter TCP\r\n");
			System.out.print(" 6.Exit\r\n");
			System.out.print("Choose an application: ");
			try{
				choice = in.nextInt();
				if(choice == 1){
					echo();
				}else if(choice == 2){
					image();
				}else if(choice == 3){
					soundDPCM();
				}else if(choice == 4){
					soundAQDPCM();
				}else if(choice == 5){
					Ithakicopter();
				}else if(choice == 6){
					return;
				}else{
					System.out.print(" WARNING:\r\n");
					System.out.print("You gave an unacceptable character try again!\r\n");
				}
			}
			catch(Exception x){
				System.out.print(" WARNING:\r\n");
				System.out.print("You gave an unacceptable character try again!\r\n");
			}



		}
}





	public void echo() throws SocketException,IOException,UnknownHostException{
		int echoRequestCode,serverPort,clientPort,countPackets = 0,option,index = -1,counter = 0;
		float counterInterval = 0;
		long tStartTimeLoop = 0,tEndTimeLoop = 0,tDeltaTimeLoop = 0;
		long tStartInterval = 0,tEndInterval = 0,tDeltaInterval = 0;
		long sumInterval = 0;
		String message = "",packetInfo = "";
		ArrayList<Long> sample = new ArrayList<Long>();
		ArrayList<String> temp = new ArrayList<String>();
		ArrayList<Float> counters = new ArrayList<Float>();
		ArrayList<Long> sums = new ArrayList<Long>();


		System.out.println("Enter the echo request code EXXXX for this session: ");
		Scanner in = new Scanner(System.in);
		echoRequestCode = in.nextInt();
		Scanner ch = new Scanner(System.in);
		System.out.println("Choose mode: \r\n");
		System.out.println("1.Echo with delay");
		System.out.println("2.Echo without delay");

		option = ch.nextInt();
		if(option == 1){
			packetInfo = "E" + Integer.toString(echoRequestCode) +"\r";
		}else if(option == 2){
			packetInfo = "E0000\r";
		}
		byte[] txbuffer = packetInfo.getBytes();
		DatagramSocket socketClientSend = new DatagramSocket();
		System.out.println("Enter the server Port for this session: ");
		Scanner sPort = new Scanner(System.in);
		serverPort = sPort.nextInt();
		byte[] hostIP = { (byte)155,(byte)207,(byte)18,(byte)208 };
		InetAddress hostAddress = InetAddress.getByAddress(hostIP);
		DatagramPacket packetClientToServer = new DatagramPacket(txbuffer,txbuffer.length,hostAddress,serverPort);
		System.out.println("Enter the client Port for this session: ");
		Scanner cPort = new Scanner(System.in);
		clientPort = cPort.nextInt();
		DatagramSocket socketClientReceive = new DatagramSocket(clientPort);
		byte[] rxbuffer = new byte[2048];
		DatagramPacket packetServetToClient = new DatagramPacket(rxbuffer,rxbuffer.length);

		tStartTimeLoop = System.currentTimeMillis();
		while((tDeltaTimeLoop/1000.0) < 6*60){
			socketClientSend.send(packetClientToServer);
			tStartInterval = System.currentTimeMillis();
			tEndInterval = 0;
			tDeltaInterval = 0;
			socketClientReceive.setSoTimeout(3200);
			for (;;) {
				try {
					socketClientReceive.receive(packetServetToClient);
					tEndInterval = System.currentTimeMillis();
					tDeltaInterval = tEndInterval - tStartInterval;
					message = new String(rxbuffer,0,packetServetToClient.getLength());
					System.out.println(new String(rxbuffer));
					break;
				}catch (Exception x) {
					System.out.println(x);
					break;
				}

			}
			System.out.print("\r\n");
			System.out.print(tDeltaInterval + "\r\n");
			countPackets++;
			sample.add(tDeltaInterval);
			counter++;
			tEndTimeLoop = System.currentTimeMillis();
			tDeltaTimeLoop = tEndTimeLoop - tStartTimeLoop;
			

		}
		for(int i = 0; i < sample.size();i++){
			int j = i;
			while((sumInterval/1000.0 < 8)&&(j < sample.size())){
				sumInterval += sample.get(j);
				counterInterval++;
				j++;
			}
			counterInterval = counterInterval/8;
			counters.add(counterInterval);
			sums.add(sumInterval);
			counterInterval = 0;
			sumInterval = 0;
		}


		System.out.print("Count: " + countPackets);
		System.out.print("\r\n");
		System.out.print("Loop Time: "+tDeltaTimeLoop);
		System.out.print("\r\n");
		for(int i = 0 ; i < countPackets ; i++){
			System.out.print("Sample " + i + " "+ sample.get(i) +"\r\n");
		}

		BufferedWriter bw = null;
		try{
			File file = new File("Time2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < countPackets ; i++){
				bw.write("" + sample.get(i));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

		BufferedWriter kw = null;
		try{
			File file = new File("Sums2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			kw = new BufferedWriter(fw);
			for(int i = 0 ; i < counters.size(); i++){
				kw.write("" + counters.get(i));
				kw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(kw != null) kw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}


	}

	public void image() throws SocketException,IOException,UnknownHostException{
		int imageRequestCode,option,serverPort,clientPort;
		String message = "",packetInfo = "";
		String fileName = "image2.jpeg";

		System.out.println("Enter the image request code MXXXX for this session: ");
		Scanner in = new Scanner(System.in);
		imageRequestCode = in.nextInt();
		Scanner ch = new Scanner(System.in);
		System.out.println("Choose mode: \r\n");
		System.out.println("1.Image CAM1");
		System.out.println("2.Image CAM2");
		option = ch.nextInt();
		if(option == 1){
			packetInfo = "M" + Integer.toString(imageRequestCode) +"\r";
		}else if(option == 2){
			packetInfo = "M" + Integer.toString(imageRequestCode) + " " + "CAM=PTZ" + "\r";
		}


		byte[] txbuffer = packetInfo.getBytes();
		DatagramSocket socketClientSend = new DatagramSocket();
		System.out.println("Enter the server Port for this session: ");
		Scanner sPort = new Scanner(System.in);
		serverPort = sPort.nextInt();
		byte[] hostIP = { (byte)155,(byte)207,(byte)18,(byte)208 };
		InetAddress hostAddress = InetAddress.getByAddress(hostIP);
		DatagramPacket packetClientToServer = new DatagramPacket(txbuffer,txbuffer.length,hostAddress,serverPort);
		System.out.println("Enter the client Port for this session: ");
		Scanner cPort = new Scanner(System.in);
		clientPort = cPort.nextInt();
		DatagramSocket socketClientReceive = new DatagramSocket(clientPort);
		byte[] rxbuffer = new byte[2048];
		DatagramPacket packetServetToClient = new DatagramPacket(rxbuffer,rxbuffer.length);

		socketClientSend.send(packetClientToServer);
		socketClientReceive.setSoTimeout(3200);
		FileOutputStream outputStream = new FileOutputStream(fileName);
		for(;;){
			try{
				socketClientReceive.receive(packetServetToClient);
				if (rxbuffer == null) break;
				for(int i = 0 ; i <= 127 ; i++){
				outputStream.write(rxbuffer[i]);
				}
			}catch (IOException ex) {
				System.out.println("error writing file");
				break;
			}
		}
		outputStream.close();

	}


	public void soundDPCM() throws SocketException,IOException,UnknownHostException,LineUnavailableException{
		int soundRequestCode,option,serverPort,clientPort,numPackets = 999,mask1 = 15,mask2 = 240,beta = 4,rx;
		int soundSample1 = 0,soundSample2 = 0;
		int nibble1,nibble2,sub1,sub2,sample1 = 0,sample2 = 0,counter = 0;
		String message = "",packetInfo = "";
		ArrayList<Integer> subs = new ArrayList<Integer>();
		ArrayList<Integer> samples = new ArrayList<Integer>();

		System.out.println("Enter the sound request code VXXXX for this session: ");
		Scanner in = new Scanner(System.in);
		soundRequestCode = in.nextInt();
		Scanner ch = new Scanner(System.in);
		System.out.println("Choose mode: \r\n");
		System.out.println("1.Song DPCM");
		System.out.println("2.Frequency DPCM");
		option = ch.nextInt();
		if(option == 1){
			packetInfo = "V" + Integer.toString(soundRequestCode) + "F999";
		}else if(option == 2){
			packetInfo = "V" + Integer.toString(soundRequestCode) + "T999";
		}



		byte[] txbuffer = packetInfo.getBytes();
		DatagramSocket socketClientSend = new DatagramSocket();
		System.out.println("Enter the server Port for this session: ");
		Scanner sPort = new Scanner(System.in);
		serverPort = sPort.nextInt();
		byte[] hostIP = { (byte)155,(byte)207,(byte)18,(byte)208 };
		InetAddress hostAddress = InetAddress.getByAddress(hostIP);
		DatagramPacket packetClientToServer = new DatagramPacket(txbuffer,txbuffer.length,hostAddress,serverPort);
		System.out.println("Enter the client Port for this session: ");
		Scanner cPort = new Scanner(System.in);
		clientPort = cPort.nextInt();
		DatagramSocket socketClientReceive = new DatagramSocket(clientPort);
		byte[] rxbuffer = new byte[128];
		DatagramPacket packetServetToClient = new DatagramPacket(rxbuffer,rxbuffer.length);

		socketClientSend.send(packetClientToServer);

			byte[] song = new byte[256*numPackets];
			for(int i = 1;i < numPackets;i++){
				try{
					socketClientReceive.receive(packetServetToClient);
					for (int j = 0;j <= 127;j++){
						rx = rxbuffer[j];
						nibble1 = rx & mask1;
						nibble2 = ((rx & mask2)>>4);
						sub1 = (nibble1-8);
						subs.add(sub1);
						sub1 = sub1*beta;
						sub2 = (nibble2-8);
						subs.add(sub2);
						sub2 = sub2*beta;
						sample1 = sample2 + sub1;
						samples.add(sample1);
						sample2 = sample1 + sub2;
						samples.add(sample2);
						song[counter] = (byte)sample1;
						song[counter + 1] = (byte)sample2;
						counter += 2;
					}
			}catch (Exception ex){
				System.out.println("Error" + ex);
			}
			System.out.println(i);
		}

		System.out.println("Starting Playing...");

		AudioFormat pcm = new AudioFormat(8000,8,1,true,false);
		SourceDataLine playsong = AudioSystem.getSourceDataLine(pcm);
		playsong.open(pcm,32000);
		playsong.start();
		playsong.write(song,0,256*numPackets);
		playsong.stop();
		playsong.close();

		BufferedWriter bw = null;
		try{
			File file = new File("DPCMsubF.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < subs.size() ; i += 2){
				bw.write("" + subs.get(i) + " " + subs.get(i+1));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

		BufferedWriter mw = null;
		try{
			File file = new File("DPCMsamplesF.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			mw = new BufferedWriter(fw);
			for(int i = 0 ; i < samples.size() ; i += 2){
				mw.write("" + samples.get(i) + " " + samples.get(i+1));
				mw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(mw != null) mw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

	}

	public void soundAQDPCM() throws SocketException,IOException,UnknownHostException,LineUnavailableException{
		int soundRequestCode,option,serverPort,clientPort,numPackets = 999,rx;
		String message = "",packetInfo = "";
		int soundSample1 = 0,soundSample2 = 0;
		int nibble1,nibble2,sub1,sub2,sample1 = 0,sample2 = 0,counter = 4,mean,beta,hint = 0;
		ArrayList<Integer> means = new ArrayList<Integer>();
		ArrayList<Integer> betas = new ArrayList<Integer>();
		ArrayList<Integer> subs = new ArrayList<Integer>();
		ArrayList<Integer> samples = new ArrayList<Integer>();


		System.out.println("Enter the sound request code VXXXX for this session: ");
		Scanner in = new Scanner(System.in);
		soundRequestCode = in.nextInt();
		Scanner ch = new Scanner(System.in);
		System.out.println("Choose mode: \r\n");
		System.out.println("1.Song AQDPCM");
		System.out.println("2.Frequency AQDPCM");
		option = ch.nextInt();
		if(option == 1){
			packetInfo = "V" + Integer.toString(soundRequestCode) + "AQF999";
		}else if(option == 2){
			packetInfo = "V" + Integer.toString(soundRequestCode) + "AQT999";
		}


		byte[] txbuffer = packetInfo.getBytes();
		DatagramSocket socketClientSend = new DatagramSocket();
		System.out.println("Enter the server Port for this session: ");
		Scanner sPort = new Scanner(System.in);
		serverPort = sPort.nextInt();
		byte[] hostIP = { (byte)155,(byte)207,(byte)18,(byte)208 };
		InetAddress hostAddress = InetAddress.getByAddress(hostIP);
		DatagramPacket packetClientToServer = new DatagramPacket(txbuffer,txbuffer.length,hostAddress,serverPort);
		System.out.println("Enter the client Port for this session: ");
		Scanner cPort = new Scanner(System.in);
		clientPort = cPort.nextInt();
		DatagramSocket socketClientReceive = new DatagramSocket(clientPort);
		byte[] rxbuffer = new byte[132];
		DatagramPacket packetServetToClient = new DatagramPacket(rxbuffer,rxbuffer.length);

		socketClientSend.send(packetClientToServer);
			byte[] meanB = new byte[4];
			byte[] betta = new byte[4];
			byte sign;
			byte[] song = new byte[256*2*numPackets];
			for(int i = 1;i < numPackets;i++){
				System.out.println(i);
				try{
					socketClientReceive.receive(packetServetToClient);
					sign = (byte)( ( rxbuffer[1] & 0x80) !=0 ? 0xff : 0x00);//converting byte[2] to int
					meanB[3] = sign;
					meanB[2] = sign;
					meanB[1] = rxbuffer[1];
					meanB[0] = rxbuffer[0];
					mean = ByteBuffer.wrap(meanB).order(ByteOrder.LITTLE_ENDIAN).getInt();
					means.add(mean);
					sign = (byte)( ( rxbuffer[3] & 0x80) !=0 ? 0xff : 0x00);
					betta[3] = sign;
					betta[2] = sign;
					betta[1] = rxbuffer[3];
					betta[0] = rxbuffer[2];
					beta = ByteBuffer.wrap(betta).order(ByteOrder.LITTLE_ENDIAN).getInt();
					betas.add(beta);

					for (int j = 4;j <= 131;j++){
						rx = rxbuffer[j];
						nibble1 = (int)(rx & 0x0000000F);
						nibble2 = (int)((rxbuffer[j] & 0x000000F0)>>4);
						sub1 = (nibble2-8);
						subs.add(sub1);
						sub2 = (nibble1-8);
						subs.add(sub2);
						sub1 = sub1*beta;
						sub2 = sub2*beta;
						sample1 = hint + sub1 + mean;
						samples.add(sample1);
						sample2 = sub1 + sub2 + mean;
						hint = sub2;
						samples.add(sample2);
						counter += 4;
						song[counter] = (byte)(sample1 & 0x000000FF);
						song[counter + 1] = (byte)((sample1 & 0x0000FF00)>>8);
						song[counter + 2] = (byte)(sample2 & 0x000000FF);
						song[counter + 3] = (byte)((sample2 & 0x0000FF00)>>8);


					}
			}catch (Exception ex){
				System.out.println("Error" + ex);
			}
		}
		System.out.println("Starting Playing...");

		AudioFormat aqpcm = new AudioFormat(8000,16,1,true,false);
		SourceDataLine playsong = AudioSystem.getSourceDataLine(aqpcm);
		playsong.open(aqpcm,32000);
		playsong.start();
		playsong.write(song,0,256*2*numPackets);
		playsong.stop();
		playsong.close();

		BufferedWriter bw = null;
		try{
			File file = new File("AQDPCMsubsF2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < subs.size() ; i += 2){
				bw.write("" + subs.get(i) + " " + subs.get(i+1));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

		BufferedWriter mw = null;
		try{
			File file = new File("AQDPCMsamplesF2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			mw = new BufferedWriter(fw);
			for(int i = 0 ; i < samples.size() ; i += 2){
				mw.write("" + samples.get(i) + " " + samples.get(i+1));
				mw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(mw != null) mw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

		BufferedWriter pw = null;
		try{
			File file = new File("AQDPCMmeanF2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			pw = new BufferedWriter(fw);
			for(int i = 0 ; i < means.size() ; i += 2){
				pw.write("" + means.get(i));
				pw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(pw != null) pw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

		BufferedWriter kw = null;
		try{
			File file = new File("AQDPCMbetasF2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			kw = new BufferedWriter(fw);
			for(int i = 0 ; i < betas.size() ; i ++){
				kw.write("" + betas.get(i));
				kw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(kw != null) kw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}

	}


public void Ithakicopter() throws SocketException,IOException,UnknownHostException,LineUnavailableException,ClassNotFoundException {
	int serverPort = 38048,clientPort = 48038;
	int copterRequestCode;
	String message = "",packetInfo = "";
	ArrayList<String> messages = new ArrayList<String>();

	byte[] hostIP = { (byte)155,(byte)207,(byte)18,(byte)208 };

	System.out.println("Enter the copter request code QXXXX for this session: ");
	Scanner in = new Scanner(System.in);
	copterRequestCode = in.nextInt();
	packetInfo = "Q" + Integer.toString(copterRequestCode) +"\r";

	byte[] txbuffer = packetInfo.getBytes();
	DatagramSocket socketClientSend = new DatagramSocket();
	InetAddress hostAddress = InetAddress.getByAddress(hostIP);
	DatagramPacket packetClientToServer = new DatagramPacket(txbuffer,txbuffer.length,hostAddress,serverPort);
	DatagramSocket socketClientReceive = new DatagramSocket(clientPort);
	byte[] rxbuffer = new byte[5000];
	DatagramPacket packetServetToClient = new DatagramPacket(rxbuffer,rxbuffer.length);

	for (int i = 1;i <= 60 ; i++){
		socketClientSend.send(packetClientToServer);
		socketClientReceive.receive(packetServetToClient);
		message = new String(rxbuffer,0,packetServetToClient.getLength());
		messages.add(message);
		System.out.println(new String(rxbuffer));
	}

	BufferedWriter bw = null;
		try{
			File file = new File("Ithakicopter2.txt");
			if(!file.exists()){
				file.createNewFile();
			}
			FileWriter fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
			for(int i = 0 ; i < messages.size(); i++){
				bw.write("" + messages.get(i));
				bw.newLine();
			}

		}catch(IOException ioe){
			ioe.printStackTrace();
		}finally{
			try{
				if(bw != null) bw.close();
			}catch(Exception ex){
				System.out.println("Error in closing the BufferedWriter" + ex);
			}
		}



}





}
