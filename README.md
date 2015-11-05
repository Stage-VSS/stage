# Stage version 2

Stage is a MATLAB-based visual stimulus system for vision research.

## Clone

`git clone https://github.com/Stage-VSS/stage2.git --recursive`

**Note:** You must use the `--recursive` option to recursively clone all submodules.

## Requirements

- OS X 10.8+ or Windows 7 64-bit
- MATLAB 2013b+ 64-bit
- OpenGL 3.2+
- [Visual C++ Redistributable for Visual Studio 2012](http://www.microsoft.com/en-us/download/details.aspx?id=30679) (Windows only)

## Build

Matlab functions in the root directory are used to build the project. The scripts are named according to the build phase they execute. The phases include:

- `test`: run tests using the Matlab unit test framework
- `package`: package the project into a .mlappinstall file
- `install`: install the packaged product into Matlab

Similar to the [Maven Build Lifecycle](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html), each phase will execute all phases before it (i.e. running `install` will execute `test`, `package`, `install`)

## Directory Structure

The project directory structure generally follows the [Maven Standard Directory Layout](https://maven.apache.org/guides/introduction/introduction-to-the-standard-directory-layout.html).

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
