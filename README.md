# Visual_Mic

Hello, Welcome to my project **Visual Mic**.   
Note: This project invovles Image Processing and Speech Processing. It was entirely developed in MATLAB.

#### Abstract  
When sound hits an object, it causes small vibrations of the object’s surface. The objective of this project is to extract 
those minute vibrations partially recover the sound that produced them, by using just a high-speed video of the object. This method
converts the vibrations caused by sound falling on an object back to sound signal, potentially converting everyday objects into microphones.
Thus, the name Visual Mic. 

#### Note 
This project is a from-scratch recreation of the work done by Dr. Abe Davis and his Team at MIT. Please check out his work on his 
[website](http://people.csail.mit.edu/mrub/VisualMic/) and his [paper](http://people.csail.mit.edu/mrub/papers/VisualMic_SIGGRAPH2014.pdf).  
The motivation for this project was a video published by the Youtube channel *Veritasium* which you can check out [here](https://www.youtube.com/watch?v=eUzB0L0mSCI&feature=youtu.be).

## Recovering Sound from Video
The below figure gives a high-level overview of how the visual_mic works. An input sound (the signal we want to recover) consists of
fluctuations in air pressure at the surface of some object. These fluctuations cause the object to move, resulting in a pattern of displacement
over time that we film with a camera. We then process the recorded video with our algorithm to recover an output sound.  
We proceed in 4 steps:  
- ***Decomposition*** : We use Complex Steerable pyramids to decompose the video frames into spatial subbands corresponding to different orientations θ
and scales r. This step is done to obtain phase variations from the complex subbands.  
- ***Local Motion Computation*** : The local motion signals are calculated by monitoring the phase changes caused by the vibrations for every
scale and orienation. So, if we have *m* scales and *n* orientations, we get *m*x*n* local signals.  
- ***Global Motion Computation*** : We combine these local motion signals through a sequence of averaging and alignment operations to produce a single
global motion signal for the object.
- ***Denoising*** : The extracted Globa signal has a lot of background noise. This signal is denoised using various denoising techniques.  

![](data/Additional%20Photos/image.png)  

<br>
The input video is high framerate video, a glimpse of the video dataset used in this presentation is given below.
<br>
<br>

[<p align="center"><img src="data/Additional%20Photos/Firstframeresized.png"></p>](https://drive.google.com/file/d/1lJ7rzbRWIsw-mL9GZV36TSZvMb3RwGro/view?usp=sharing)

<br>
You can listen to the background sound that was playing while the mute video was being captuted below. The waveform and spectrogram of 
sound is also shown for comparitive purposes.

[<p><img width="65" height="65" src="data/Additional%20Photos/playicon.png"></p>](https://drive.google.com/file/d/1JDY2tfL0G0A39BBwpYRsnTtS9FdAV02_/view?usp=sharing)
<p>
<img width="420" height="300" src="Background%20audio/Original-audio-plot.png">
<img width="420" height="300" src="Background%20audio/Original-audio-spectrogram.png">
</p>

The code for the algorithm is available in *vmalgo.m*. I have displayed 2 simulations by changing the parameters to show the efficacy of 
the code. The parameters that can be changed are *Number of Scales, Number of Orientations* and *Downsampling factor*. The parameters can 
be changed depending upon the required quality of recovered sound, and the capability of your machine.

## Simulation 1

#### Parameters:
- ***Number of Scales*** = 1
- ***Number of Orientations*** = 2
- ***Downsampling Factor*** = 0.1

With these parameters we decompose the video frames into complex steerable pyramid of 1 scale and 2 orientations.   
The phase changes caused by the vibrations between frame 1 and frame 2 is shown by the below 3D plot. A more visual representation of how 
the pixels are affected by the vibrations is shown in the contour plot. It shows how some pixels in the frame are more affected by the
vibrations than other pixels.
<img src="data/Simulation%201/Phasechanges-surfplot-S1-O2-D0.1.png">
<p align="center">
<img width="400" height="350" src="data/Simulation%201/Phasechanges-contourplot-S1-O2-D0.1.png">
<img width="400" height="350" src="data/Simulation%201/Phasechanges-contourplot-S1-O2-D0.1-01.jpeg">
</p>

Since, some pixels are affected adversely, we use amplitude-weighted phase averaging is used to create the local motion signal for a particular scale and orientation.

<img width="420" height="300" src="data/Simulation%201/Localsig-orientation2 -S1-O2-D0.1.png">

Realigning the local signals and adding them gives the Global motion signal. We can see that the global signal has more power than the local signal.

<img width="420" height="300" src="data/Simulation%201/Globalsig-S1-O2-D0.1.png">

The global signal is then filtered and we get our recovered signal. You can listen to the recovered sound of Simulation 1 below. You can compare the waveform 
and spectrogram of the recovered sound with the background given above.

[<p><img width="65" height="65" src="data/Additional%20Photos/playicon.png"></p>](https://drive.google.com/file/d/1q013G5YemoyyRHHNAN4v0u58ZHjZ6kyD/view?usp=sharing)
<p>
<img width="420" height="300" src="data/Simulation%201/Timewave-recovered-S1-O2-D0.1.png">
<img width="420" height="300" src="data/Simulation%201/Spectrogram-recovered-S1-O2-D0.1.png">
</p>

This simulation was executed on CPU-only system and took the below mentioned time. The time duration of the simulation will depend on the parameters and if the code is being
run on CPU or GPU.

<p align="center">
<img src="data/Simulation%201/Timedur-S1-O2-D0.1.png">
</p>

## Simulation 2

#### Parameters:
- ***Number of Scales*** = 3
- ***Number of Orientations*** = 5
- ***Downsampling Factor*** = 0.7

With these parameters we decompose the video frames into complex steerable pyramid of 3 scales and 5 orientations.   
<img width="350" height="350" src="data/Additional%20Photos/Steerablepyr1.png">

The phase changes caused by the vibrations between frame 1 and frame 2 is shown by the below 3D plot. A more visual representation of how 
the pixels are affected by the vibrations is shown in the contour plot. It shows how some pixels in the frame are more affected by the
vibrations than other pixels.
<img src="data/Simulation%202/Phasechanges-surfplot-S3-O5-D0.7.png">
<p align="center">
<img width="400" height="350" src="data/Simulation%202/Phasechanges-contourplot-S3-O5-D0.7.png">
<img width="400" height="350" src="data/Simulation%202/Phasechanges-contourplot-S3-O5-D0.7-01.jpeg">
</p>

Since, some pixels are affected adversely, we use amplitude-weighted phase averaging is used to create the local motion signal for a particular scale and orientation.

<img width="420" height="300" src="data/Simulation%202/Localsig-scale2orientation3 -S3-O5-D0.7.png">

Realigning the local signals and adding them gives the Global motion signal. We can see that the global signal has more power than the local signal.

<img width="420" height="300" src="data/Simulation%202/Globalsig-S3-O5-D0.7.png">

The global signal is then filtered and we get our recovered signal. You can listen to the recovered sound of Simulation 2 below. You can compare the waveform 
and spectrogram of the recovered sound with the background given above.

[<p><img width="65" height="65" src="data/Additional%20Photos/playicon.png"></p>](https://drive.google.com/file/d/1GV-mIzUGu619BV249HeWgad8KynZl9Dp/view?usp=sharing)
<p>
<img width="420" height="300" src="data/Simulation%202/Timewave-recovered-S3-O5-D0.7.png">
<img width="420" height="300" src="data/Simulation%202/Spectrogram-recovered-S3-O5-D0.7.png">
</p>

This simulation was executed on CPU-only system and took the below mentioned time. The time duration of the simulation will depend on the parameters and if the code is being
run on CPU or GPU.

<p align="center">
<img src="data/Simulation%202/Timedur-S3-O5-D0.7.png">
</p>

## Conclusion

As shown in the results above, we were successful in partially recovering background sound from a high speed video of a nearby object.  

For easier result comparisions, please refer the below table.

Background sound | Recovered Sim1 | Recovered Sim2
---------------- | -------------- | --------------
![](Background%20audio/Original-audio-plot.png) | ![](data/Simulation%201/Timewave-recovered-S1-O2-D0.1.png) | ![](data/Simulation%202/Timewave-recovered-S3-O5-D0.7.png)

As we can see clearly, that having more datapoints to work with i.e having higher scales, orientations and especially higher downsampling 
factor.  

For a much detailed explanation, please visit Abe Davis's [website](http://people.csail.mit.edu/mrub/VisualMic/)  

Thank you for your interest in my project. For any more information, feel free to contact me or check out my personal [website](http://mkparihar.github.io).  

**Namaste.** :pray:



