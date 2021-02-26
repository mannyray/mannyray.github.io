---
layout: post
title:  "Hunting for Cell Towers"
date:   2019-10-30 13:31:00
categories: programming
---


Hello! I have created an Android app that logs cell phone signal data. I used the app as part of a personal project to locate cell phone towers in the town that I am living in.


I came across [this post](https://math.stackexchange.com/questions/623977/applying-a-kalman-filter-to-a-wifi-power-signal?rq=1) discussing utilizing the Kalman filter for locating an device near Wifi signal. After briefly seeing if something similair can be done where I'm living I determined it wasn't given the space and tools present. Full of hope, I wanted to check if it possible to do something similar for cell signals. This provided the perfect excuse to create my very first android application that can be used to log the cell signal strength at your location along with the GPS location. Here are the two relevant app files:

`AndroidManifest.xml`
{% highlight xml %}
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.celltower">
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.READ_SMS" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>examp
    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/AppTheme">
        <activity android:name=".MainActivity"
            android:launchMode="singleTop">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
{% endhighlight %}

`MainActivity.java`
{% highlight java %}
package com.example.celltower;

import android.os.AsyncTask;
import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.os.Handler;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.location.Criteria;

import static android.Manifest.permission.ACCESS_COARSE_LOCATION;
import static android.Manifest.permission.ACCESS_FINE_LOCATION;
import static android.Manifest.permission.READ_PHONE_STATE;
import static android.Manifest.permission.READ_SMS;
import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

import android.util.Log;

import java.io.FileNotFoundException;
import java.util.Date;

import java.text.SimpleDateFormat;

import android.os.Environment;

import java.io.IOException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;

import android.telephony.TelephonyManager;
import android.widget.TextView;

import android.content.Intent;


public class MainActivity extends AppCompatActivity implements LocationListener {

    TextView textView;
    Context context;
    Location location;
    LocationManager locationManager;
    boolean GpsStatus = false;
    String Holder;
    Criteria criteria;


    Handler handler;
    Runnable test;

    @Override
    public void onLocationChanged(Location location) {
        // textViewLongitude.setText("Longitude:" + location.getLongitude());
        //textViewLatitude.setText("Latitude:" + location.getLatitude());
    }

    @Override
    public void onStatusChanged(String s, int i, Bundle bundle) {

    }

    @Override
    public void onProviderEnabled(String s) {

    }

    @Override
    public void onProviderDisabled(String s) {

    }

    public void CheckGpsStatus() {

        locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

        GpsStatus = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);

    }

    private boolean writtenTo = false;
    private String saveToFileName = "";

    private String writeToFile(String data) {//},Context context) {
        try {


            File extStore = Environment.getExternalStorageDirectory();
            //https://stackoverflow.com/questions/34111692/outputstreamwriter-append-not-appending-text-to-a-text-file-android-programming
            File file = new File(extStore.getAbsolutePath() + "/Download/" + saveToFileName);
            FileOutputStream fos = new FileOutputStream(file, writtenTo);
            OutputStreamWriter outputStreamWriter = new OutputStreamWriter(fos);

            outputStreamWriter.append(data + "\n");
            outputStreamWriter.close();


            Log.e("Exception", extStore.getAbsolutePath() + "/Download/" + saveToFileName);
            return context.getFilesDir().toString();

        } catch (IOException e) {
            Log.e("Exception", "File write failed: " + e.toString());
        }
        return "";
    }

    public boolean isExternalStorageWritable() {
        String state = Environment.getExternalStorageState();
        if (Environment.MEDIA_MOUNTED.equals(state)) {
            return true;
        }
        return false;
    }


    private static final int WRITE_REQUEST_CODE = 43;

    private Intent createFile(String mimeType, String fileName) {
        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);

        // Filter to only show results that can be "opened", such as
        // a file (as opposed to a list of contacts or timezones).
        intent.addCategory(Intent.CATEGORY_OPENABLE);

        // Create a file with the requested MIME type.
        intent.setType(mimeType);
        intent.putExtra(Intent.EXTRA_TITLE, fileName);
        startActivityForResult(intent, WRITE_REQUEST_CODE);
        Integer resultCode = 0;

        onActivityResult(WRITE_REQUEST_CODE, resultCode, intent);

        return intent;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        textView = findViewById(R.id.tv_details);

        Integer dd = 100;
        ActivityCompat.requestPermissions(this, new String[]{
                Manifest.permission.READ_PHONE_STATE,
                Manifest.permission.READ_SMS,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.WRITE_EXTERNAL_STORAGE}, dd);

        if (ActivityCompat.checkSelfPermission(this, READ_SMS) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(this, ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(this, READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {


            ActivityCompat.requestPermissions(this, new String[]{READ_SMS, READ_PHONE_STATE, ACCESS_COARSE_LOCATION, WRITE_EXTERNAL_STORAGE}, dd);
            final TelephonyManager telephonyManager = (TelephonyManager) this.getSystemService(Context.TELEPHONY_SERVICE);


            context = getApplicationContext();
            CheckGpsStatus();
            locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);
            criteria = new Criteria();
            Holder = locationManager.getBestProvider(criteria, false);
            if (GpsStatus == true) {
                if (Holder != null) {
                    if (ActivityCompat.checkSelfPermission(
                            MainActivity.this,
                            Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED
                            &&
                            ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_COARSE_LOCATION)
                                    != PackageManager.PERMISSION_GRANTED) {
                        return;
                    }
                    location = locationManager.getLastKnownLocation(Holder);
                    locationManager.requestLocationUpdates(Holder, 12000, 7, MainActivity.this);
                }
            }


            writtenTo = true;


            saveToFileName = new SimpleDateFormat("yyyyMMddHHmm'.txt'").format(new Date());
            saveToFileName = "measurements" + saveToFileName;
            final Intent intent = createFile("text/plain", saveToFileName);

            final boolean[] complete = {false};
            final Integer[] counter = {0};
            final String[] fileName = {""};
            handler = new Handler();
            test = new Runnable() {
                @Override
                public void run() {
                    if (complete[0]) {
                        counter[0] = counter[0] + 1;

                        String str = System.currentTimeMillis() + " " + counter[0] + " " + location.getLongitude() + " " + location.getLatitude() + telephonyManager.getAllCellInfo();
                            fileName[0] = writeToFile(str);
                            textView.setText(str);
                            handler.postDelayed(test, 1000);
                            if (counter[0] == 3600) {
                                textView.setText(fileName[0]);
                                handler.removeCallbacks(test);

                            }
                        }else{
                            Log.e("Exception", "waiting");
                            File extStore = Environment.getExternalStorageDirectory();
                            File file = new File(extStore.getAbsolutePath()+"/Download/"+saveToFileName);
                            complete[0] = file.exists();
                            Log.e("Exception",""+extStore.getAbsolutePath());
                            handler.postDelayed(test, 1000);
                        }
                    }
                };
                handler.postDelayed(test, 0);

        }else{
            ActivityCompat.requestPermissions(this, new String[]{READ_SMS, READ_PHONE_STATE,ACCESS_COARSE_LOCATION,ACCESS_FINE_LOCATION}, dd);
        }

    }
}
{% endhighlight %}

The application when run on your phone(tested on Android 6.0) immediately prompts to save a file to a directory(the default file name is to be left unmodified). After creating the file the app displays the text being appended every single second to the created file. The app has no real UI - I wanted to get to analysis ASAP and this stackoverflow assisted creation was sufficient for that objective. A sample logged line is below:

{% highlight plaintext %}
1569105778657 258 LAT LON[CellInfoLte:{mRegistered=YES mTimeStampType=oem_ril mTimeStamp=10331753480921ns CellIdentityLte:{ mMcc=302 mMnc=220 mCi=XXXXXX mPci=155 mTac=4340} CellSignalStrengthLte: ss=20 rsrp=-155 rsrq=-8 rssnr=14 cqi=255 ta=0}]
{% endhighlight %}

The first number is the timestamp and second number signifies that this line is the `258`th logged entry (approximately `258` seconds after starting the app). `LAT` and `LON` are place holders for the GPS location which have been anonymized (along with `mCI`) and the rest of the line is information on the cell signal. The relevant stuff are the CellSignalStrength and specifically `ss` measured in `dB`. The signal strength will be primarily used for finding the tower. Sometimes the cell phone will pick up multiple signals and so the there will be multiple `CellInfoLte` entries within the square brackets. Based on [this](https://www.cellmapper.net/CellMapper_CSV) some of the `CellIdentityLte` are identified as

{% highlight plaintext %}
mMcc: Mobile Country Code
mMnc: Mobile Network Code
mCi:  Mobile Cell ID
mPci: Physical Cell Identity 
{% endhighlight %}

These codes are used to identify the tower. The `CellSignalStrengthLte` is broken down [here](https://usatcorp.com/faqs/understanding-lte-signal-strength-values/):

{% highlight plaintext %}
ss:    Signal Strength
rsrp:  Reference Signal Receive Power: The average power received from a single Reference signal, and Its typical range is around -44dbm (good) to -140dbm(bad).
rsrq:  Reference Signal Recieved Quality: Indicates quality of the received signal, and its range is typically -19.5dB(bad) to -3dB (good).
rssnr: reference signal signal-to-noise ratio
cqi:   channel quality indicator 
ta:    Get the timing advance value for LTE, as a value in range of 0..1282
{% endhighlight %}

I used a python script (`parseCellData.py`) to analyze the text files

{% highlight python %}
import re
import numpy as np


class Recording:
    def __init__(self):
        self.latitude=0
        self.longitude=0
        self.time=0
        self.cells=[]
        self.ss=0

    def setLatitude(self,lat):
        self.latitude=lat
    def getLatitude(self):
        return self.latitude

    def setLongitude(self,lon):
        self.longitude=lon
    def getLongitude(self):
        return self.longitude

    def setCoordinateTime(self,time):
        self.time=time
    def addCell(self,cell):
        self.cells.append(cell)
    def getCells(self):
        return self.cells


class cellData:
    def __init__(self):
        self.ID=""
        self.time=0
        self.ss=0
        self.sp=0

    def setTime(self,time):
        self.time=time
    
    def setID(self,ID):
        self.ID=ID
    def getID(self):
        return self.ID
    
    def setSignalStrength(self,ss):
        #https://stackoverflow.com/questions/7201871/getgsmsignalstrength-return-values-that-are-out-of-range
        if(ss==99):
            self.ss=0#null
        else:
            self.ss=-113+2*ss

    def getSignalStrength(self):
        return self.ss
    
    def getSignalPower(self):
        return self.sp

    def setSignalPower(self,sp):
        self.sp=sp



class analyze:
    def __init__(self,coordinates):
        self.coordinates=coordinates

    def getLats(self):
        lats=[]
        for i in self.coordinates:
            lats.append(i.getLatitude())
        return lats

    def getLons(self):
        lons=[]
        for i in self.coordinates:
            lons.append(i.getLongitude())
        return lons
    def getUniqueTowers(self):
        tower=dict()
        for coord in self.coordinates:
            for cellTower in coord.getCells():
                if cellTower.getID() in tower:
                    tower[cellTower.getID()] = tower[cellTower.getID()] + 1
                else:
                    tower[cellTower.getID()] = 1
        return tower
    def getTowerCoords(self,towerID):
        lats=[]
        lons=[]
        for coord in self.coordinates:
            for cellTower in coord.getCells():
                if cellTower.getID() == towerID:
                    lats.append(coord.getLatitude())
                    lons.append(coord.getLongitude())
        return [lats,lons]

    def getAllTowerCoords(self):
        towers=self.getUniqueTowers()
        towerList=[]
        coords=[]
        for tower in towers:
            towerList.append(tower)
            coord=self.getTowerCoords(tower)
            coords.append(coord)
        return [towerList, coords]

    def getSignalStrengths(self,tower):
        signalStrengths=[]
        for coord in self.coordinates:
            for cellTower in coord.getCells():
                if cellTower.getID() == tower:
                    signalStrengths.append(cellTower.getSignalStrength())
        return signalStrengths

    def getSignalPowers(self,tower):
        signalPowers=[]
        for coord in self.coordinates:
            for cellTower in coord.getCells():
                if cellTower.getID() == tower:
                    signalPowers.append(cellTower.getSignalPower())
        return signalPowers


    def sortByIncreasingFrequency(self,towerCoords):
        arr=[]
        for i in towerCoords[1]:
            arr.append(len(i[0]))
        index=np.argsort(arr)
        copy=[]
        copyID=[]
        for i in range(0,len(index)):
            copy.append(towerCoords[1][index[i]])
            copyID.append(towerCoords[0][index[i]])
        return [copyID,copy]

class readCellInformation:
    def __init__(self):
        self.coordinates=[]
    def getCoordinates(self):
        return self.coordinates
    def read(self,fileName):
        f=open(fileName)
        lines=f.readlines()

        for x in lines:
            res = x.split('[',1);
            coordinate_data = res[0].split(' ')
            rec = Recording()
            rec.setLatitude(float(coordinate_data[3]))
            rec.setLongitude(float(coordinate_data[2]))
            rec.setCoordinateTime(float(coordinate_data[0]))
            res[1] = res[1].replace("CellInfoLte","CELL")
            res[1] = res[1].replace("CellInfoWcdma","CELL")
            res[1] = res[1].replace("CellInfoGsm","CELL")
            for y in res[1].split('CELL:'):
                if len(y)!=0:
 
                    time=int(re.search('mTimeStamp=(.*)ns',y).group(1))
                    mcc=int(re.search('mMcc=(.*) mMnc',y).group(1))
                    mnc=int(re.search('mMnc=(.*) (mCi|mLac)=',y).group(1))
                    mci=""
                    mpci=""
                    #mtac=int(re.search('mTac=(.*)} Cell',y).group(1))
                    tmp=""
                    tmp=(re.search('ss=(.*) rsrp=',y))
                    cell = cellData()
                    try:#LTE
                        mci=int(re.search('mCi=(.*) mPci=',y).group(1))
                        tmp=int(tmp.group(1))
                        rsrp=int(re.search('rsrp=(.*) rsrq=',y).group(1))
                        cell.setSignalPower(rsrp)
                    except:#WCDMA
                        tmp=(re.search(' ss=(.*) ber=',y))
                        try:
                            mci=int(re.search('mCid=(.*) mPsc=',y).group(1))
                        except:
                            mci=int(re.search('mCid=(.*)} CellSignalStrengthGsm',y).group(1))
                        tmp=int(tmp.group(1))
                    ss=tmp 
                    ID=str(mpci)+""+str(mci)
                    
                    cell.setTime(time)
                    cell.setID(ID)
                    cell.setSignalStrength(ss)
                    rec.addCell(cell)
            self.coordinates.append(rec)            
{% endhighlight %}

Useful posts for tracking cell phone towers based on cell signal strength:

1. [Engineering stack exchange](https://engineering.stackexchange.com/questions/10987/how-to-determine-signal-strength-verses-distance-for-lte-base-stations/11049) was one of the first discovered. It was discouraging to say the least. It looked like I needed to read a lot more and discover more parameters in order to find the cell tower. (related: [link](https://networkengineering.stackexchange.com/questions/60813/calculating-maximum-distance-for-receiving-lte-signal))
2. [Stack overflow](https://stackoverflow.com/questions/11217674/how-to-calculate-distance-from-wifi-router-using-signal-strength) discusses computing computing distances in the wifi context. The formulas looked simple enough, but wasn't sure how to extend it to my context.
3. [Stack overflow](https://stackoverflow.com/questions/10329877/how-to-properly-triangulate-gsm-cell-towers-to-get-a-location) Discussed computing an individual's location given that the cell tower locations and signal strengths are known. This gave inspiration for using the computer cell tower locations later on.
4. [Stack overflow](https://stackoverflow.com/questions/9630297/how-to-get-cell-tower-location-in-android#9630589),[Stack overflow](https://stackoverflow.com/questions/6668271/get-cell-tower-locations-android) discovered the cell tower locations by looking them up in a public database (given that they are even available). This seemed like a cop out. There were already resources listing displaying cell tower locations across Canada - I wanted to derive it myself.
5. [Free-space path loss](https://en.wikipedia.org/wiki/Free-space_path_loss) concept was mentioned in previous posts. The wikipedia article like the engineering stack exchange post left me with more questions than answers.
6. [These lecture slides notes](https://personal.utdallas.edu/~torlak/courses/ee4367/lectures/lectureradio.pdf) and [this](https://www.engeniustech.com/explaining-free-space-path-loss/) started to give me the sense that I needed to look more at Free-space path loss. 
7. [Paper 1](https://doi.org/10.1145/3308558.3313726), [Paper 2](https://ieeexplore.ieee.org/abstract/document/5683779/) gave more insight into using towers to locate cell phone location as well as signal strength maps(something that I am trying to recreate with my walks and car ride - could I reverse engineer somehow?)
8. [Paper 3](https://doi.org/10.1007/11853565_14) provided break through. The paper described creating a positioning system based on cell towers. Since they did not have access to cell tower locations had to locate themselves. To collect data, they drove over `4000km` - covering a `25km by 18km`. A lot more than I plan to do since I am stationed in a small town, but still daunting. They did not know the cell phone tower locations to begin with and ended up estimating their location based on "averaging  the  places  where  the  highest  signal  strengths  in  each  cell  was  observed".  This adhoc approach provided average error of `56m` and maximum `76m`. The error for positioning using the calculated cell towers was significant and for GPS would be unacceptable.
9. [Paper 4](https://doi.org/10.1145/1864349.1864384). The previous paper was dated 2006 - looking at authors who have cited the paper a 2010 entry was found. This described the process of recording data around town as wardriving!!! Lots of useful information to consider. There are two algorithms considered and compared - the average approach (from previous point) and another. The conclusion was "blindly applying these algorithms to estimate cell tower positions results in very large errors". They introduced approach to avoid the errors, but for the small town I'm in, I hope it will be unnecessary.
10. [Paper 5](http://ermis.tucserv.tuc.gr/techReportPFs.pdf) from 2013 provided another approach but it was not for me. 
11. [Stack overflow](https://stackoverflow.com/questions/13547085/approx-distance-to-nearest-mobile-mast) The new approach mentioning using `TA` parameter (time advance), but due to (apparent) tower difference this value was always zero for me and therefore not useful. [link](https://www.panix.com/~mpoly/android/antennas/r1.0/) mentioned Google building their database of cell tower locations via "crowdsourcing".
12. [Hata model](https://en.wikipedia.org/wiki/Hata_model) free-space path loss led me here. Models are used by telecom companies to predict areas where coverage is low/high in order to optimize tower placement. This led me to the idea that by matching these models to the data, I can estimate the tower locations based on signal decay rate.
13. [Model comparison](https://arxiv.org/pdf/1110.1519.pdf) - compared different models including Hata. I was unfamiliar with some of the terms so I sought an easier explanation: a [thesis](https://pdfs.semanticscholar.org/6901/8cae891d502eb9afdb6c7218bdee53104b10.pdf) on the topic (great source!!!).

