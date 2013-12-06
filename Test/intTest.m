function intTest(canvas)

%% Setup
% canvas.projection.setIdentity();
% canvas.projection.orthographic(0, canvas.size(1)*2, 0, canvas.size(2));

presentation = Presentation(canvas, 5);

%% Stimuli
rect1 = Rectangle();
rect1.size = [100, 200];
rect1.position = [200, 200];
%rect1.orientation = 10;
rect1.color = 1;
rect1.opacity = 1;
presentation.addStimulus(rect1);

presentation.addController(rect1, 'orientation', @(s)s.time*60);
% presentation.addController(rect1, 'position', @(s)[s.time*100, 200]);
% presentation.addController(rect1, 'opacity', @(s)s.time*0.2);
% presentation.addController(rect1, 'color', @(s)[s.time*0.2 s.time*0.1 s.time*0.3]);
% 
% rect2 = Rectangle();
% rect2.size = [100, 200];
% rect2.position = [300, 300];
% rect2.color = [0 1 0];
% rect2.opacity = 0.3;
% presentation.addStimulus(rect2);
% % 
% presentation.addController(rect2, 'position', @(s)[100, s.time*100]);
% presentation.addController(rect2, 'orientation', @(s)-s.time*60);
% 
ellip = Ellipse();
ellip.radiusX = 50;
ellip.radiusY = 100;
ellip.position = [300, 300];
ellip.color = [1 0 0];
presentation.addStimulus(ellip);

presentation.addController(ellip, 'orientation', @(s)-s.time*120);
%
mask = Mask2D('gaussian');
img = Image('Test/checkerboard.jpg');
img.setMask(mask);
img.size = [200, 200];
img.position = [500, 200];
%img.opacity = 0.5;
presentation.addStimulus(img);
% % 
% presentation.addController(img, 'size', @(s)[s.time*100 s.time*100]);
% presentation.addController(img, 'orientation', @(s)s.time*60);
% 
% img2 = Image('Test/rieke.png');
% img2.size = [300, 300];
% img2.position = [400, 400];
% img2.mask = Mask2D();
% presentation.addStimulus(img2);
% 
% presentation.addController(img2, 'orientation', @(s)s.time*30);

mask = Mask2D('circle');
grat = Grating('square');
grat.setMask(mask);
grat.position = [200, 300];
grat.size = [200, 200];
grat.spatialFreq = 1/100;
grat.contrast = 0.5;
grat.phase = 180;
presentation.addStimulus(grat);

%presentation.addController(grat, 'spatialFreq', @(s)1/(100/s.time));
%presentation.addController(grat, 'phase', @(s)s.time*360);
%presentation.addController(grat, 'contrast', @(s)s.time*1/5);
%presentation.addController(grat, 'size', @(s)[s.time*100 s.time*100]);
%presentation.addController(grat, 'orientation', @(s)s.time*50);

% mask = Mask2D('circle');
% grat2 = Grating('square');
% grat2.setMask(mask);
% grat2.position = [200, 300];
% grat2.size = [200, 200];
% grat2.spatialFreq = 1/100;
% grat2.contrast = 0.5;
% grat2.phase = 180;
% grat2.orientation = 90;
% grat2.opacity = 0.5;
% presentation.addStimulus(grat2);

%% PLAY!
presentation.play();

end