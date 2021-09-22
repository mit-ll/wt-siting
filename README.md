Supplementary materials for Radar-Aware Wind Turbine Siting paper by Brigada and
Ryvkina, submitted to IEEE Transactions on Sustainable Energy, 2021.

Includes core wind turbine alignment function in Layout.m and a GUI to adjust
settings and visualize output in LayoutTest.m.

Proof of concept.

Tries to align in a streamwise/spanwise grid, even when the given wind farm
won't fit with that orientation.  The location adjustment via Newton iteration
causes this to explode when there's no solution.  A robust implementation
would try to move turbine locations to different grid locations to attempt a
proper fit.

Does not account for terrain, wind turbine height, radar height, or Earth
curvature.

Requires MATLAB and the MATLAB Mapping Toolbox; licenses are available from
https://www.mathworks.com/

Distribution Statement A.  Approved for public release.  Distribution is
unlimited.

This material is based upon work supported by the Department of Energy under
Air Force Contract No. FA8702-15-D-0001. Any opinions, findings, conclusions
or recommendations expressed in this material are those of the author(s) and
do not necessarily reflect the views of the Department of Energy .

© 2021 Massachusetts Institute of Technology.

The software/firmware is provided to you on an As-Is basis

Subject to FAR52.227-11 Patent Rights - Ownership by the contractor (May 2014)

Delivered to the U.S. Government with Unlimited Rights, as defined in DFARS
Part 252.227-7013 or 7014 (Feb 2014). Notwithstanding any copyright notice,
U.S. Government rights in this work are defined by DFARS 252.227-7013 or DFARS
252.227-7014 as detailed above. Use of this work other than as specifically
authorized by the U.S. Government may violate any copyrights that exist in
this work.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY MIT LINCOLN LABORATORY "AS IS" AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL MIT LINCOLN LABORATORY BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.
