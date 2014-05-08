Pyku
====

Docker container for running a Pyku server.  Pyku is a python script I wrote to randomly generate haikus from the american-english dictionary included in most Linux distributions.

* [Pyku](https://github.com/clcollins/pyku)

Maintainer: Chris Collins \<collins.christopher@gmail.com\>

Updated: 2014-05-08

##Building and Running##

This is a [Docker](http://docker.io) container image.  You need to have Docker installed to build and run the container.

To build the image, change directories into the root of this repository, and run:

`docker build -t Pyku .`  <-- note the period on the end

Once it finishes building, you can run the container with:

`docker run -i -t -d -p 8080:80 Pyku`

Then, open your browser and navigate to [http://localhost:8080](http://localhost:8080) to see your randomly generated haiku.

To improve startup speed, this image will not update with the latest version of the Pyku software automatically once the initial image is built.  When a new update is released, run the `docker build` command from above to get the newest version.

##Acknowledgements##

Thanks to:

* Ian Meyer [https://github.com/imeyer](https://github.com/imeyer) for his Runit rpm spec file and build script for RHEL-based systems.

##Copyright Information##

Copyright (C) 2014 Chris Collins

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
