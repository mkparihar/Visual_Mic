clear;
close all;

% Adding data folder and functions folder to path
cpath = mfilename('fullpath');
path = fileparts(cpath);
datapath = fullfile(path,'data');
fpath = fullfile(path,'Functions');

addpath(path);
addpath(datapath);
addpath(fpath);
fprintf('Data and Functions folders added to path');

%Reading the input video
vidName = 'Chips1-2200Hz-Mary_Had-input.avi';
vr = VideoReader(fullfile(datapath, vidName));

%% Starting time counter
tic;
starttime = toc;


%setting parameters
%You can change the parameters depending on the accuracy required and the capability of your machine
%Higher scales, orientations and downsampling means higher accuracy.
%NOTE : nscales<=4	norientations<=5	downsampling<=1 
%samplingrate depends on the framerate of your highspeed camera
%NOTE: Use camera above samplingrate>1200	 
nscales = 4;
norientations =5;
dsamplefactor = 0.3;
samplingrate = 2200;
nFrames = vr.NumberOfFrames;

%Reading first frame of video and downsampling
fframe = vr.read(1);
fprintf('Successfully read first frame of video');
fframe = imresize(fframe,dsamplefactor);
%converting datpoints to single precision;
fullFrame = im2single(squeeze(mean(fframe,3)));
refFrame = fullFrame;
[h,w] = size(refFrame);

%Decomposing reference Frame into Complex Steerable pyramids
[pyrRef, pind] = buildSCFpyr(refFrame, nscales, norientations-1);

totalsignals = nscales*norientations;
framephases = zeros(nscales,norientations,nFrames);
frameamps = zeros(nscales,norientations,nFrames);



%Start comparing other frames with reference frames
for i=1:nFrames
	
	
	%Progress Indicator
	if(mod(i,floor(nFrames/100))==1)
		progress = i/nFrames;
		currenttime = toc;
		['Progress:' num2str(progress*100) '% done after ' num2str(currenttime-starttime) ' seconds.']
	end
	
	
	%Reading and decomposing incoming frames
	nextframe = vr.read(i);
	im = im2single(squeeze(mean(imresize(nextframe,dsamplefactor),3)));
	pyr = buildSCFpyr(im, nscales, norientations-1);
	
	pyrAmp = abs(pyr);
    pyrDeltaPhase = mod(pi+angle(pyr)-angle(pyrRef), 2*pi) - pi;
	
	for j= 1:nscales
		for k = 1:norientations
			bandnum = 1 + (j-1)*norientations + k;
			amp = pyrBand(pyrAmp, pind, bandnum);
            phase = pyrBand(pyrDeltaPhase, pind, bandnum);
			
			%giving phase points weights of their res. amplitude squared
			wphase = phase.*(abs(amp).^2);
			
			%Adding the amplitudes of all pixel points in a particular scale-orientation pair
			ampsum = sum(abs(amp(:)));
			frameamps(j,k,i) = ampsum;
			
			%Averaging phases in a particular scale-orientation pair
			framephases(j,k,i) = mean(wphase(:))/ampsum;
			
		end
	end
end




%Realigning the local signals and creating a global motion signal

Globalsig = zeros(nFrames,1);
for i=1:nscales
	for k=1:norientations
		[sigaligned, shiftam] = vmAlignAToB(squeeze(framephases(i,k,:)), squeeze(framephases(1,1,:)));
		Globalsig = Globalsig + sigaligned;
	end
end
		

%Denoising section
%First denoising using a Butterworth highpass filter
highpassfc = 0.05;
[b,a] = butter(3,highpassfc,'high');
Hfiltersig = filter(b,a,Globalsig);
%Butterworth doesn't fix the first few entries
Hfiltersig(1:10) = mean(Hfiltersig);

maxsx = max(Hfiltersig);
minsx = min(Hfiltersig);
if(maxsx~=1.0 || minsx ~= -1.0)
    range = maxsx-minsx;
    Hfiltersig = 2*Hfiltersig/range;
    newmx = max(Hfiltersig);
    offset = newmx-1.0;
    Hfiltersig = Hfiltersig-offset;
end		



%Plotting Graphs and Playing the recovered sound
window = 100;
overlap = 50;
gain = 1;
spectrogram(Hfiltersig,window,overlap);
sound(Hfiltersig*gain, samplingrate);
			

%% Plotting Local motion signal and listening to it
%%Select for which scale and orientation, whose local signal you want to plot
%%i is for scale, j is for orientation
%local = framephases(i,j,:);
%plot(local);
%spectrogram(local,window,overlap);
%sound(local)


%% Plotting Global motion signal and listening to it
%plot(Globalsig);
%spectrogram(Globalsig,window,overlap);
%sound(local)


%% Extracting the phase difference between i-th scale and j-th band of Reference frame and desired frame
%fn = 'frame number'      %Replace 'frame number' with number of desired frame
%imdesired = im2single(squeeze(mean(imresize(vr.read(fn),dsamplefactor),3)));
%pyrdesired = buildSCFpyr(imdesired, nscales, norientations-1);
%pyrDeltaPhasedesired = mod(pi+angle(pyrdesired)-angle(pyrRef), 2*pi) - pi;
%%Select which scale and orientation band you desired
%%i is for scale, j is for orientation
%band = 1 + (i-1)*norientations + j;
%phasediff = pyrBand(pyrDeltaPhasedesired, pind, band);
%%if you want weighted phasediff add the below two lines
%%ampdiff = pyrBand(pyrAmp, pind, bandnum);
%%phasediff = phasediff.*(abs(ampdiff).^2);
%%Now plot the 3D surface plot to get a 3D overview of the phase changes
%subplot(2,1,1);
%surf(phasediff);
%colormap(jet);
%%Now plot the contour plot to get a 2D pictorial overview of the phase changes
%subplot(2,1,2);
%contour(phasediff, 32);
%colormap default
%% 







