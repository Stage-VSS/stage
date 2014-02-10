# Stage

Stage is a MATLAB-based visual stimulus system for vision research.

## Requirements

- OS X 10.8+ or Windows 7 64-bit
- MATLAB 2013b+ 64-bit
- OpenGL 3.2+
- [Visual C++ Redistributable Packages for Visual Studio 2013](http://www.microsoft.com/en-us/download/details.aspx?id=40784) (Windows only)

## Install

1. Run `git clone https://github.com/cafarm/Stage --recursive` in Terminal.app or Git Bash.
2. Add the Stage folder and it's subfolders to the Matlab path.

## FAQ

**Why am I seeing odd timing behavior and/or screen tearing?**

On Windows Vista and later you must use the Windows Basic or Classic theme. The Windows Aero theme is not supported by Stage and will cause performance and timing issues.

Some drivers also allow users to override an application's request to wait for vertical refresh (vsync). Ensure that your drivers do not override this setting or Stage will be unable to synchronize with your monitors refresh interval.

**Why do I receive an error claiming "Invalid MEX-file ... The specified module could not be found."?**

Make sure you have installed the latest OS updates and the Visual C++ Redistributable Packages listed under requirements. If that fails to fix the issue open the problematic mex file with [Dependency Walker](http://www.dependencywalker.com) and look for any missing DLLs.

**Why do I receive an error claiming "Undefined function or variable ..."**

Make sure you are using a 64-bit version of MATLAB and that you included the `--recursive` flag when cloning the Stage repository during installation. If you recently updated Stage via `git pull` also ensure that you have run `git submodule update` within the Stage directory.

**How do I update Stage to the latest version?**

In Terminal.app or Git Bash navigate to the Stage directory. Run `git pull` and then `git submodule update`.

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.