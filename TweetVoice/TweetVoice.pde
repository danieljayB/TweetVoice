/*
______            _      _     ___              ______           _                     _____  _____  __   _____  
|  _  \          (_)    | |   |_  |             | ___ \         | |                   / __  \|  _  |/  | |____ | 
| | | |__ _ _ __  _  ___| |     | | __ _ _   _  | |_/ / ___ _ __| |_ _ __   ___ _ __  `' / /'| |/' |`| |     / / 
| | | / _` | '_ \| |/ _ \ |     | |/ _` | | | | | ___ \/ _ \ '__| __| '_ \ / _ \ '__|   / /  |  /| | | |     \ \ 
| |/ / (_| | | | | |  __/ | /\__/ / (_| | |_| | | |_/ /  __/ |  | |_| | | |  __/ |    ./ /___\ |_/ /_| |_.___/ / 
|___/ \__,_|_| |_|_|\___|_| \____/ \__,_|\__, | \____/ \___|_|   \__|_| |_|\___|_|    \_____/ \___/ \___/\____/  
                                          __/ |                                                                  
                                         |___/                                                                   
Chicago Dialogues source code. Utilizes Androids SpeechRecognizer class to process speech, then post to twitter.  
 
 
 This work is licensed under the Creative Commons Attribution 4.0 International License. 
 To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/.
 
 
 */
import java.util.*;
 
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.speech.RecognitionListener;
import   android.view.View;
import android.app.Activity;
import android.os.Handler;
import android.os.Message;
import android.widget.TextView;
import android.view.View.OnClickListener;
import android.widget.Button;
import java.util.ArrayList;
import android.util.Log;



import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

//your credentials from your twitter app
static String OAuthConsumerKey = "";
static String OAuthConsumerSecret = "";
static String AccessToken = "";
static String AccessTokenSecret = "";

Twitter twitter = new TwitterFactory().getInstance();


PFont androidFont;
String [] fontList;
int VOICE_RECOGNITION_REQUEST_CODE = 1234;
Intent intent;
//RecognitionListner listenVal;
boolean mIsListening = false; 
final static int DIM = 20, DELAY = 1000;

int nextTimer, counter;
public SpeechRecognizer sr;
boolean post = false;


void setup() {
  size(displayWidth, displayHeight);
  //orientation(LANDSCAPE);
  fontList = PFont.list();
  androidFont = createFont(fontList[0], 18, true);
  textFont(androidFont);
  loginTwitter();

}


void loginTwitter() {
  twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
  AccessToken accessToken = loadAccessToken();
  twitter.setOAuthAccessToken(accessToken);
}

private static AccessToken loadAccessToken() {
  return new AccessToken(AccessToken, AccessTokenSecret);
}

/************************************************************************
 
 --------------------------------  DRAW ---------------------------------
 
 *************************************************************************/
 
void draw() {
  
  if (millis() < nextTimer)   return;

  nextTimer = millis() + DELAY;
  print(++counter + " - ");
  
  if(counter == 3){
    
      runOnUiThread(new Runnable() {
    //@ Override
    public void run() {
      //Initialize the recognizer on the UI thread
      initRecognizer();
    }
  });
  counter =0;
    
  }



}
/************************************************************************
 
 --------------------------------  EVENTS ---------------------------------
 
 *************************************************************************/
 
void mousePressed() {

  
}


void initRecognizer() {

  
 sr = SpeechRecognizer.createSpeechRecognizer(this);
          sr.setRecognitionListener(new listener());

                Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);        
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                intent.putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE,"voice.recognition.test");
 
                intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,5); 
                     sr.startListening(intent);
 
  
}

 
/*************RECOGNITION LISTENER CLASS*************************/
 
 
  public class listener implements RecognitionListener          
   {
            public void onReadyForSpeech(Bundle params)
            {
                     println( "onReadyForSpeech");
            }
            public void onBeginningOfSpeech()
            {
                     println( "onBeginningOfSpeech");
            }
            public void onRmsChanged(float rmsdB)
            {
                   //  println( "onRmsChanged");
            }
            public void onBufferReceived(byte[] buffer)
            {
                     println( "onBufferReceived");
            }
            public void onEndOfSpeech()
            {
                     println( "onEndofSpeech");
            }
            public void onError(int error)
            {
                     println( "error " +  error);
                   //  mText.setText("error " + error);
            }
            public void onResults(Bundle results)                   
            {
                  background(0);

              ArrayList<String> data = results.getStringArrayList(
        SpeechRecognizer.RESULTS_RECOGNITION);
        String s[] = (String[]) data.toArray(new String[data.size()]);
    fill(255);
    for (int i=0; i<s.length; i++) {
      //textAlign(CENTER);
      textSize(24);
      text(s[0], 10,20, displayWidth, displayHeight);
    println("results = " + s[0]);
    
    String msgOut = "";
  
      msgOut = s[0];
      
    
    int resultLength = s[0].length();
          println("RESULTS Character Length = " + resultLength);


    if(resultLength <= 139){
                            postMsg(msgOut); //send a tweet
println("tweet sent");
      
    }
    
    
  }
    
              
      
            }
            public void onPartialResults(Bundle partialResults)
            {
                     println( "onPartialResults");
            }
            public void onEvent(int eventType, Bundle params)
            {
                     println( "onEvent " + eventType);
            }
   }



void postMsg(String s) {
  try {
    Status status = twitter.updateStatus(s);
    println("new tweet --:{ " + status.getText() + " }:--");
  }
  catch(TwitterException e) {
    println("Status Error: " + e + "; statusCode: " + e.getStatusCode());
  }
}

void compareMsg(String s) {
  // compare new msg against latest tweet to avoid reTweets
  java.util.List statuses = null;
  String prevMsg = "";
  String newMsg = s;
  try {
    statuses = twitter.getUserTimeline();
  }
  catch(TwitterException e) {
    println("Timeline Error: " + e + "; statusCode: " + e.getStatusCode());
  }
  Status status = (Status)statuses.get(0);
  prevMsg = status.getText();
  String[] p = splitTokens(prevMsg);
  String[] n = splitTokens(newMsg);
  //println("("+p[0]+") -> "+n[0]); // debug
  if (p[0].equals(n[0]) == false) {
    postMsg(newMsg);
  }
  //println(s); // debug
}


