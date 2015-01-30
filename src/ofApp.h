#pragma once

#include "ofMain.h"
#include "ofxiOS.h"
#include "ofxiOSExtras.h"
#include "ofxOpenCv.h"
#include "oscillator.h"
#include "ofxiPhoneTorch.h"
#include "ofxUI.h"

class ofApp : public ofxiOSApp {
	
    public:
        void setup();
        void update();
        void draw();
    
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);

        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
        //video and opencv
        int camW;
        int camH;
        ofVideoGrabber grabber;
        ofxCvColorImage	colorImg;
        ofxCvGrayscaleImage grayImage;
        unsigned char* grayImagePixels;
        std::vector<int> grayscaleVerticalLine;
        std::vector<int> grayScaleVerticalLineSmall;
        void setupCamera();
        int thresholdVal;

    
        //audio
        void setupAudio();
        void audioOut(float * input, int bufferSize, int nChannels);
        ofSoundStream stream;
        std::vector<oscillator> oscillators;
        void printOscillators();
    
        //torch
        ofxiPhoneTorch flashlight;
        void toggleFlashlight();
    
        //ofxui
        ofxUICanvas *gui;
        void setupUI();
        void exit();
        void guiEvent(ofxUIEventArgs &e);
    
        //orientation handling
        void resetForDefault();
        void resetForUpsideDown();
        void resetForLandscapeLeft();
        void resetForLandscapeRight();
    
        void drawForDefault();
        void drawForUpsideDown();
        void drawForLandscapeLeft();
        void drawForLandscapeRight();
    
        void updateForDefault();
        void updateForUpsideDown();
        void updateForLandscapeLeft();
        void updateForLandscapeRight();
    
        bool isDefault;
        bool isUpsideDown;
        bool isLandscapeLeft;
        bool isLandscapeRight;
};


