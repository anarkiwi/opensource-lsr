# Introduction #
The Opensource-LSR is an evolving project to enable MPLS LSR functionality in opensource hardware, providing an innovative platform from which opensource networking software can be developed.

# Details #
Originally the Opensource-LSR was a systems integration project involving several other OSS projects and an opensource hardware project.  mpls-linux provides MPLS support in the linux kernel, quagga-ldp provided LDP extensions for [quagga](http://www.nongnu.org/quagga/), [NetFPGA](http://netfpga.org/) provided a hardware platform that can be programmed using
OpenFlow, and finally some glue to plumb control-plane changes from user-space quagga down to the hardware forward table.

Currently the NetFPGA hardware has been reprogrammed to support all necessary LSR functionality.  This functionality is documented at http://algo-logic.com/lsr/ and should allow software development supporting MPLS network stack functionality to proceed independently from kernel or quagga dependencies.

In the future this LSR hardware support via NetFPGA should be able to work underneath an OpenFlow agent, underneath a [RouteFlow](http://sites.google.com/site/routeflow/) instance, with new extensions to quagga or similar OSS, or as a standalone device.