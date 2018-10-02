%% Image Correlation Spectroscopy Calculation
clc; clear
%% Create a simulated image series with the following characteristics: 
%256 x 256 pixels with 100 images, 10 particles per um^2, 1 s per image, 0.1 um/pixel,
%particles with a quantum yield of 1, a Gaussian convolving function with an e^-2 radius of 0.4 um, 
%with particles diffusing at 0.01 um^2/s, and no noise

%simulation = simul8tr(sizeX,sizeY,sizeT,density,bleachType,bleachDecay,qYield,pixelsize,
%timesize,PSFType,PSFSize,PSFZ,noBits,diffCoeff,flowX,flowY,flowZ, countingNoise,backgroundNoise);

% imageSeriesDiff = simul8tr(256,256,100,10,'none',0,1,0.1,1,'g',0.4,0,12,0.01,0,0,0,0,0);

% imagesc(imageSeriesDiff(:,:,1))
% axis image
% colormap(gray) imread
%% 
particlesPerBeamArea = 0;
beamArea = 0;
density = 0;
%% Load images
filename = 'C:\Users\lfang\Desktop\Slice_by_slice_more_vs_less_clustered_comparison\less clustered.tif';
% image_data=rd_img16(filename); %Option 1 - load 16-bit fluoview tiff images.
for mm = 1:22
image_data(:,:,mm) = imread(filename,mm);
%filename is a string which contains the filename to load. 
%(e.g., 'C:\MyData\ImageSeries.tif'.)

% filename = 'C:\Users\lfang\Desktop\test-ICS.tif';
% sizex = 1000;
% sizey = 1000;
% numimg = 41;
% image_data=rd_imgser(filename,sizex,sizey,numimg); %Option 2 - load 8-bit RAW files
%sizex and sizey are the dimensions of an image
%numimg is the number of images in the series.

%If the file is a Fluoview TIFF and the image series was collected on 
%an Olympus microscope, FluoInfo can extract data collection parameters from the file header:
%filename = 'C:\Users\lfang\Desktop\test.czi';
% [XDim,YDim,TDim, PMTVoltage, PMTOffset, PMTGain, LaserPower] = FluoInfo(filename);
%XDim and YDim are the pixel sizes, in um, in the X and Y directions
%TDim is the time between images, in seconds. 
%PMTVoltage, PMTOffset, and PMTGain, give the PMT settings
%LaserPower is the laser intensity, in percent.
% imagesc(image_data)
% % imagesc(image_data(:,:,1))
% axis image
% colormap(gray)
%% Background subtraction
imageDataCorrected = wnCorr(image_data(:,:,mm)); % 

%You will be prompted to select a background region. 
%Its mean will be subtracted from the image series.
%% Cropping region of interest(ROI)
%An image series can be cropped to select a region of interest using serimcrop:

% croppedImageSeries = serimcrop(imageSeries);
%You will be prompted to interactively select the ROI.
%% Calculate a 2D spatial autocorrelation function (SACF) for each image 
%in the simulation which we created earlier:
ICS2DCorr = corrfunc(imageDataCorrected);
% 
% figure(1)
% s=surf(ICS2DCorr(:,:,1));
% axis tight
% colormap(jet)
% xlabel('\eta','FontSize',12)
% ylabel('\xi','FontSize',12)
% zlabel('r(\xi,\eta)','FontSize',12)
% set(s,'LineStyle','none')
% title('Spatial Autocorrelation Function')
%% Crop the stack of SACFs around the central peak, since the fitting algorithms 
%work better when the noise at higher spatial lags is removed.
ICS2DCorrCrop = autocrop(ICS2DCorr,10);
% 
% figure(2)
% s=surf(ICS2DCorrCrop(:,:,1));
% axis tight
% colormap(jet)
% xlabel('\eta','FontSize',12)
% ylabel('\xi','FontSize',12)
% zlabel('r(\xi,\eta)','FontSize',12)
% set(s,'LineStyle','none')
% title('Cropped Spatial Autocorrelation Function')
%% These cropped SACFs are fit to a 2D Gaussian
a = gaussfit(ICS2DCorrCrop,'2d',0.1,'n');
% 
% plotgaussfit(a(1,1:6),ICS2DCorrCrop(:,:,1),0.1,'n')
%% Calculate the average cluster density using the amplitudes of the fitted Gaussians
% particlesPerBeamArea = 1/(mean(a(:,1)))
% beamArea = pi*mean(a(:,2))*mean(a(:,3))
% density = particlesPerBeamArea/beamArea
particlesPerBeamArea = particlesPerBeamArea + 1/(mean(a(:,1)));
beamArea = beamArea + pi*mean(a(:,2))*mean(a(:,3));
density = density + particlesPerBeamArea/beamArea;

end
particlesPerBeamArea = particlesPerBeamArea/22;
beamArea = beamArea/22;
density = density/22;