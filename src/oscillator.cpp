//
//  oscillator.cpp
//  musicPrints-iOS-openFrameworks
//
//  Created by Johann Diedrick on 12/13/14.
//
//
//class referenced from ofZach's week two course at avsys 2012
//https://github.com/ofZach/avsys2012/tree/master/week2_oscillatorTypes

#include "oscillator.h"

void oscillator::setup (int sampRate){
    phase = 0;
    sampleRate = sampRate;
    type = sineWave;
}

void oscillator::setFrequency(float freq){
    frequency = freq;
    //phaseAdder = (float)(frequency * TWO_PI) / (float)sampleRate; //for getSample() method
    phaseAdder = (float)frequency  / (float)sampleRate; // for getWavetableSample() method

}

void oscillator::setVolume(float vol){
    volume = vol;
}

float oscillator::getFrequency(){
    return frequency;
}

float oscillator::getSample(){
    phase += phaseAdder;
    while (phase>TWO_PI) {
        phase-=TWO_PI;
    }
    
    if (type == sineWave) {
        return sin(phase) * volume;
    } else if (type==squareWave){
        return (sin(phase) > 0 ? 1 : -1) * volume;
    } else if (type==triangleWave){
        float pct = phase / TWO_PI;
        return (pct < 0.5 ? ofMap(pct, 0, 0.5, -1, 1) : ofMap(pct, 0.5, 1.0, 1, -1)) * volume;
    } else if (type==sawWave){
        float pct = phase / TWO_PI;
        return ofMap (pct, 0, 1, -1, 1) * volume;
    } else if (type==inverseSawWave){
        float pct = phase / TWO_PI;
        return ofMap(pct, 0, 1, 1, -1) * volume;
    }
}



void oscillator::updateWaveform(int waveformResolution){
    waveform.resize(waveformResolution);
    float waveformStep = (M_PI * 2.) / (float) waveform.size();
    for(int i = 0; i < waveform.size(); i++) {
        waveform[i] = sin(i * waveformStep);        
    }
}


float oscillator::getWavetableSample(){
    phase += phaseAdder;
    int waveformIndex = (int)(phase * waveform.size()) % waveform.size();
    return waveform[waveformIndex] * volume;
}