/*

______            _      _     ___              ______           _                     _____  _____  __   _____ 
|  _  \          (_)    | |   |_  |             | ___ \         | |                   / __  \|  _  |/  | |____ |
| | | |__ _ _ __  _  ___| |     | | __ _ _   _  | |_/ / ___ _ __| |_ _ __   ___ _ __  `' / /'| |/' |`| |     / /
| | | / _` | '_ \| |/ _ \ |     | |/ _` | | | | | ___ \/ _ \ '__| __| '_ \ / _ \ '__|   / /  |  /| | | |     \ \
| |/ / (_| | | | | |  __/ | /\__/ / (_| | |_| | | |_/ /  __/ |  | |_| | | |  __/ |    ./ /___\ |_/ /_| |_.___/ /
|___/ \__,_|_| |_|_|\___|_| \____/ \__,_|\__, | \____/ \___|_|   \__|_| |_|\___|_|    \_____/ \___/ \___/\____/ 
                                          __/ |                                                                 
                                         |___/                                                                  
 


 Android API SpeechRecognizer class integrated with Twitter API. 
 
 This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
 To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/.
 
 
 
 */
 import java.util.*;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.speech.RecognizerIntent;
import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;



static String OAuthConsumerKey = "";
static String OAuthConsumerSecret = "";
static String AccessToken = "";
static String AccessTokenSecret = "";

Twitter twitter = new TwitterFactory().getInstance();

/************************************************************************
 
 --------------------------------  DATAS ---------------------------------
 
 *************************************************************************/
PFont androidFont;
String [] fontList;
int VOICE_RECOGNITION_REQUEST_CODE = 1234;

/************************************************************************
 
 --------------------------------  SETUP ---------------------------------
 
 *************************************************************************/
void setup() {
  orientation(LANDSCAPE);
  fontList = PFont.list();
  androidFont = createFont(fontList[0], 18, true);
  textFont(androidFont);
  loginTwitter();


  PackageManager pm = getPackageManager();
  ArrayList<ResolveInfo> activities = (ArrayList<ResolveInfo>)pm.queryIntentActivities(
  new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH), 0);
  if (activities.size() != 0) {
   // text("il y a un recognizer!", 20, 60);
  } 
  else {
    //text("Recognizer not present", 20, 60);
  }
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
}
/************************************************************************
 
 --------------------------------  EVENTS ---------------------------------
 
 *************************************************************************/
 
void mousePressed() {
  startVoiceRecognitionActivity();
}

void startVoiceRecognitionActivity() {
  Intent intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
  intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
  intent.putExtra(RecognizerIntent.EXTRA_PROMPT, "Speech recognition demo");
  startActivityForResult(intent, VOICE_RECOGNITION_REQUEST_CODE);
}

void onActivityResult(int requestCode, int resultCode, Intent data) {
  if (requestCode == VOICE_RECOGNITION_REQUEST_CODE && resultCode == RESULT_OK) {
    background(0);
    // Fill the list view with the strings the recognizer thought it could have heard
    ArrayList<String>  matches = data.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS);
    String s[] = (String[]) matches.toArray(new String[matches.size()]);
    fill(255);
    for (int i=0; i<s.length; i++) {
      text(s[0], 60, 20);
      //println(s[i]);
      
        String msgOut = "";
  
      msgOut = s[0];
    
    
    compareMsg(msgOut); // this step is optional
    int lengthText = msgOut.length();
     for(int counter = 0; counter < lengthText; counter++){
       
     if(counter <= 150){
            postMsg(msgOut);
     }
       
     }
     
     
     
    }
  }

  super.onActivityResult(requestCode, resultCode, data);
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




