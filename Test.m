function Test()

screen = Screen(0);

gamma = (0:1/255:1).^1;
mglSetGammaTable(gamma);
mglFlush();

rect1 = Rectangle();
rect1.size = [200, 200];
rect1.position = [100, 100];
rect1.orientation = 45;
rect1.color = 1; %[0 50/255 0];
rect1.antiAliasing = true;

viewport = Viewport(screen, {rect1});
viewport.projection = OrthographicProjection(0, screen.size(1)*2, 0, screen.size(2));

presentation = Presentation({viewport}, 1);

%presentation.addController(rect1, 'orientation', @(s)s.frame);
%presentation.addController(rect1, 'position', @(s)[s.frame * 2, s.frame]);

presentation.play();

screen.close();

end